# Solución: se sigue mostrando «VISITANTE» o «DATOS ACTUALIZADOS»

El encabezado con **VISITANTE**, **SIN INICIAR SESIÓN**, el ícono de persona ficticio y **DATOS ACTUALIZADOS** pertenece a **una versión anterior** de la interfaz Stitch.

Desde la versión `2026-11-26-tactics-r5`, las ocho pantallas activas usan el mismo archivo
`web/WEB-INF/views/arena/partials/header.jspf`. No existen esos objetos en
el encabezado vigente: el visitante ve únicamente **Iniciar sesión** a la
derecha; al autenticarse ve su nombre y **Salir**, y únicamente un ADMIN ve la
pestaña Administración.

## 1. Comprobar qué versión ejecuta Tomcat

Desde PowerShell, ubicado en la carpeta **raíz** del proyecto:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verificar-despliegue.ps1
```

La verificación consulta `http://localhost:8080/BracketArena/app?view=inicio`.
Si tu proyecto utiliza otra dirección, pasala como argumento:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verificar-despliegue.ps1 -Url "http://localhost:8080/OTRO_CONTEXTO/app?view=inicio"
```

El resultado indica si el servidor devuelve `X-Bracket-Arena-UI:
2026-11-26-tactics-r5` y si el HTML realmente contiene la barra actualizada. **No
necesita conectarse a MySQL ni publicar contraseñas.** Un error al conectar
significa que Tomcat, el puerto o la URL necesitan revisión.

También podés abrir las herramientas de desarrollador (F12), pestaña
**Network/Red** → petición `app?view=inicio` → **Response Headers**. Buscá
`X-Bracket-Arena-UI`. Si no existe, Tomcat todavía no ejecuta esta versión
del servlet.

## 2. Actualizar y volver a desplegar desde NetBeans

1. Ubicate en la carpeta del repositorio que realmente abrís en NetBeans.
2. Comprobá que utilizás este proyecto y la rama correcta:
   ```bat
   git remote -v
   git branch --show-current
   git log -1 --oneline
   ```
3. Actualizá la rama principal:
   ```bat
   git switch main
   git pull --ff-only origin main
   ```
4. En NetBeans, **detené el servidor Tomcat** desde **Servicios → Servidores**.
5. Sobre el proyecto **BracketArena**, ejecutá **Clean and Build**.
6. Iniciá nuevamente Tomcat y elegí **Run** sobre el proyecto.
7. Abrí exactamente la URL del nuevo despliegue (normalmente
   `http://localhost:8080/BracketArena/app?view=inicio`). Evitá abrir una
   aplicación vieja con otro nombre de contexto, por ejemplo
   `/WebApplication1/`.
8. Presioná **Ctrl + Shift + R** en el navegador, o probá una ventana privada.
9. Volvé a ejecutar `scripts/verificar-despliegue.ps1`.

## 3. Si sigue apareciendo el diseño anterior

Puede haber una carpeta **expandida o compilaciones JSP obsoletas** en Tomcat:

1. **Detené Tomcat por completo** antes de borrar nada.
2. En la instancia de Tomcat que realmente usa NetBeans
   (`CATALINA_BASE`, que puede ser diferente de `CATALINA_HOME`), revisá:
   - `webapps/BracketArena/`
   - `webapps/BracketArena.war`
   - `work/Catalina/localhost/BracketArena/`
3. Respaldá si es necesario y eliminá **solo esas copias de despliegue**
   de BracketArena. No borrés otras aplicaciones ni carpetas de Tomcat.
4. Ejecutá **Clean and Build**, reiniciá Tomcat y desplegá de nuevo.
5. Si NetBeans sigue copiando vistas viejas, revisá **Compile on Save** y
   **Deploy on Save** en las propiedades del proyecto; desactivalos
   temporalmente para forzar una compilación/despliegue completos.

**No borrés ni recreés la base de datos `torneos`**: este problema corresponde
al HTML/CSS/JS servido por Tomcat, no a tus equipos o partidos.

## 4. Identificar la versión correcta

Una página actual debe tener lo siguiente en **View page source / Ver código
fuente**:

```html
<header data-arena-shell="2026-11-26-tactics-r5"
```

Y la respuesta HTTP de `/app?view=inicio` debe tener:

```text
X-Bracket-Arena-UI: 2026-11-26-tactics-r5
```

La primera comprobación identifica la JSP y la segunda el servlet. Si ninguna
aparece, el navegador no está conectado al WAR nuevo, independientemente del
`git pull` ejecutado.
