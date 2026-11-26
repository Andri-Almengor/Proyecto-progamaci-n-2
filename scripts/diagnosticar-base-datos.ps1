# Diagnóstico de solo lectura para Bracket Arena y MySQL.
# No se solicitan ni imprimen contraseñas.
param(
    [string]$BaseUrl = 'http://localhost:8080/BracketArena'
)

$ErrorActionPreference = 'Stop'
$endpoint = $BaseUrl.TrimEnd('/') + '/arena-data'
Write-Host '--- Diagnóstico Bracket Arena / MySQL ---' -ForegroundColor Cyan
Write-Host ('API: ' + $endpoint)
Write-Host 'Este script NO modifica la base de datos ni las variables de entorno.'

$raw = $null
try {
    $response = Invoke-WebRequest -Uri $endpoint -UseBasicParsing -TimeoutSec 15
    $raw = $response.Content
} catch {
    $http = $_.Exception.Response
    if ($null -eq $http) {
        Write-Host ('No se pudo contactar a Tomcat: ' + $_.Exception.Message) -ForegroundColor Red
        Write-Host 'Comprobá que Tomcat está iniciado y que la URL corresponde al proyecto actual.'
        exit 3
    }
    $stream = $http.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
    try { $raw = $reader.ReadToEnd() } finally { $reader.Dispose() }
}

try {
    $data = $raw | ConvertFrom-Json
} catch {
    Write-Host 'La URL no devolvió JSON. Comprobá que la aplicación actual está desplegada.' -ForegroundColor Red
    exit 3
}
if ($data.ok -eq $true) {
    Write-Host 'Conexión de la aplicación y consultas a MySQL: CORRECTAS.' -ForegroundColor Green
    Write-Host ('Equipos recibidos: ' + @($data.teams).Count)
    if ($data.live.migrationRequired -eq $true) {
        Write-Host 'Falta tournament_live_runs para habilitar el modo en vivo.' -ForegroundColor Yellow
        Write-Host 'En MySQL Workbench ejecutá database/migrations/upgrade_live_tournaments.sql.'
        exit 2
    }
    exit 0
}
Write-Host ('Código: ' + [string]$data.code) -ForegroundColor Yellow
Write-Host ('Mensaje: ' + [string]$data.error)
Write-Host ''
Write-Host 'Variables configuradas en tu perfil de Windows (sin mostrar valores):'
foreach ($name in @('DB_URL', 'DB_USER', 'DB_PASSWORD')) {
    $value = [Environment]::GetEnvironmentVariable($name, 'User')
    Write-Host ('  ' + $name + ': ' + $(if ([string]::IsNullOrEmpty($value)) {'SIN CONFIGURAR'} else {'CONFIGURADA'}))
}
Write-Host 'Recordá reiniciar NetBeans y Tomcat al cambiar variables de entorno.'
Write-Host 'Si la cuenta torneos_app funciona en Workbench pero no en Tomcat, revisá DB_USER y DB_PASSWORD.'
exit 2
