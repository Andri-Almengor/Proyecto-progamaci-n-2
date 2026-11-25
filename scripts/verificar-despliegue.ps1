# Diagnostico de la aplicacion desplegada. No modifica archivos ni MySQL.
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verificar-despliegue.ps1
param(
    [string]$Url = 'http://localhost:8080/BracketArena/app?view=inicio'
)

$ErrorActionPreference = 'Stop'
$expected = '2026-11-25-navbar-r2'
Write-Host ''
Write-Host 'BRACKET ARENA - Verificador del encabezado publicado' -ForegroundColor Cyan
Write-Host ('URL consultada: ' + $Url)
try {
    $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -Headers @{
        'Cache-Control' = 'no-cache'
        'Pragma' = 'no-cache'
    } -TimeoutSec 15
} catch {
    Write-Host ('No se pudo abrir la aplicacion: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'Revisa que Tomcat este encendido y que la URL/puerto sean los correctos.'
    exit 3
}
$serverVersion = [string]$response.Headers['X-Bracket-Arena-UI']
$html = [string]$response.Content
$hasMarkup = $html.Contains('data-arena-shell="' + $expected + '"')
$headerMatch = [regex]::Match($html, '(?is)<header\b[^>]*>.*?</header>')
$header = $headerMatch.Value
$oldWidgets = [regex]::IsMatch($header,
    '(?i)DATOS ACTUALIZADOS|SIN INICIAR SESI|SERVIDORES ONLINE|Alex Mercer|<select\b')
$hasLogin = $header.Contains('data-arena-login')
$hasAdminLink = $header.Contains('data-path="admin"')

Write-Host ('Estado HTTP: ' + [int]$response.StatusCode)
Write-Host ('Version esperada: ' + $expected)
Write-Host ('Version devuelta: ' + $(if ($serverVersion) { $serverVersion } else { '[sin identificador: despliegue anterior]' }))
Write-Host ('JSP nueva detectada: ' + $hasMarkup)
Write-Host ('Boton de login para visitante: ' + $hasLogin)
Write-Host ('Enlace admin expuesto al visitante: ' + $hasAdminLink)
Write-Host ('Controles ficticios antiguos: ' + $oldWidgets)

if ($serverVersion -eq $expected -and $hasMarkup -and $hasLogin -and -not $hasAdminLink -and -not $oldWidgets) {
    Write-Host ''
    Write-Host 'CORRECTO: Tomcat sirve el encabezado nuevo del proyecto.' -ForegroundColor Green
    Write-Host 'Si el navegador muestra otra cosa, comproba que usas la misma URL y fuerza Ctrl+Shift+R.'
    exit 0
}
Write-Host ''
Write-Host 'INCORRECTO: La URL no esta mostrando el encabezado nuevo esperado.' -ForegroundColor Yellow
Write-Host '1. Abri la carpeta del repo correcta en NetBeans y ejecuta git pull origin main.'
Write-Host '2. Detene Tomcat. En el proyecto, ejecuta Clean and Build y luego Run.'
Write-Host '3. Si continua, elimina SOLO el despliegue antiguo de BracketArena y los JSP cacheados'
Write-Host '   en CATALINA_BASE/webapps/BracketArena y CATALINA_BASE/work/Catalina/localhost/BracketArena.'
Write-Host '4. No borres ni reinicies MySQL: el problema es el WAR/JSP del servidor.'
Write-Host 'Guia: docs/DESPLIEGUE_NETBEANS.md'
exit 2
