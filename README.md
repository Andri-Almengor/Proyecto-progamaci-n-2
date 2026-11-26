# Bracket Arena — Sistema de Gestión de Torneos Eliminatorios

Aplicación web **Java (JSP + Servlets + JDBC + MySQL)**, con panel administrativo y cuadro eliminatorio visual, responsivo y animado. Adaptada de la plantilla original CRUD en NetBeans.

## Funcionalidades y rúbrica

| Criterio | Implementación |
|---|---|
| Registro y autenticación (15%) | Nombre completo, correo único, contraseña PBKDF2, sesiones y roles ADMIN/USUARIO |
| Gestión de equipos (10%) | Nombre único, escudo vía URL, teléfono, dueño y aprobación |
| Torneo (10%) | Un torneo activo gracias a índice UNIQUE, solo con exactamente 16 equipos aprobados y seleccionados; nombre, imagen, fechas, premio CRC |
| Llaves (15%) | Sorteo aleatorio de 16 participantes, 8 + 4 + 2 + 1 encuentros inmutables |
| Resultados (20%) | Marcadores únicos sin empates, registro irreversible, ganador y avance automáticos en transacciones |
| Campeón (20%) | Resultado final genera campeón persistente y finaliza torneo |
| Consultas (10%) | Vista pública de equipos, clasificación, llaves, resultados, estado y campeón |

## Requisitos

- JDK 21 o superior
- Apache NetBeans con Java Web y Apache Tomcat **10.1 u 11** (Jakarta Servlet)
- MySQL 8 o superior
- Controlador JDBC ya incluido en lib/

## Instalación de MySQL y datos de prueba

**Nuevo:** todas las instrucciones, scripts de creación de tablas, usuario MySQL, instalación completa con **20 equipos 2026** y comprobaciones están en **[database/README.md](database/README.md)**.

**Para una instalación nueva**, abrí en MySQL Workbench el archivo **`database/instalacion_completa_2026.sql`** y ejecutá todas sus instrucciones. Crea la base `torneos`, las diez tablas, el administrador web de demostración y **16 equipos aprobados + 4 pendientes**. No necesitás ejecutar `torneos.sql` ni `demo_20_equipos.sql` por separado si usaste el instalador completo.

**Si ya tenés una base**, respaldala y ejecutá `database/seeds/demo_20_equipos.sql` para agregar solo equipos faltantes. Podés ejecutar `database/migrations/upgrade_match_simulations.sql` cuando tu esquema antiguo no tenga los informes deportivos. **No combinés** las semillas de 16 y de 20 equipos.

**Usuario para conectarse desde Java:** ejecutá opcionalmente `database/setup/usuario_aplicacion.sql` con un administrador de MySQL, reemplazando antes su contraseña de ejemplo; luego configurá `DB_URL`, `DB_USER`, `DB_PASSWORD` como variables de entorno del proceso NetBeans/Tomcat. No pongás tu contraseña real en el repositorio.

**Cuenta web inicial:** `admin@torneo.local` / `AdminExamen2026!` (solo para desarrollo; cambiar antes de producción). Los registros nuevos obtienen el rol USUARIO.

Abrí el directorio como proyecto en NetBeans, seleccioná Tomcat 10.1 u 11, ejecutá **Clean and Build** / **Run** y entrá a una URL como `http://localhost:8080/BracketArena/app`.

## Flujo para la demostración

1. Registrá usuarios normales e iniciá sesión con ellos.
2. En Equipos, registrá escudo (URL http(s)), nombre y teléfono. Los equipos quedan **PENDIENTES**.
3. Entrá como administrador. Aprobá **exactamente 16** equipos (no se permite aprobar 17).
4. En Administración, completá nombre, imagen (URL), fechas, premio en colones y verificá las **16 selecciones**.
5. Crear torneo sortea equipos y guarda 15 partidos con sus cuatro rondas.
6. En cada partido habilitado, escribí exclusivamente los dos marcadores y confirmá. Nunca se permiten empates ni editar resultados finalizados.
7. Los ganadores avanzan sin editar llaves. Tras la final aparece la celebración del campeón y el estado FINALIZADO.

## Arquitectura

Consulta [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) para el mapa de carpetas, rutas y responsabilidades de cada archivo. Las ocho páginas de Stitch están agrupadas en `web/WEB-INF/views/arena/`; la interfaz anterior se conserva en `archive/legacy-ui/`.

- src/java/com/torneo/DB.java: conexión por variables de entorno.
- src/java/com/torneo/Passwords.java: contraseñas PBKDF2-HMAC-SHA256 con salt aleatoria.
- src/java/com/torneo/Store.java: consultas, objetos de datos y transacciones.
- src/java/com/torneo/AppServlet.java: rutas GET/POST, autorización, protección CSRF y validación.
- src/java/com/torneo/Web.java: sanitización de HTML/URLs y sesión.
- web/WEB-INF/views/arena/: vistas JSP activas (sin acceso directo por URL).
- web/css/stitch.css, web/css/stitch-bridge.css y web/js/stitch-runtime.js: diseño Stitch, skeletons y render dinámico.
- database/schema/torneos.sql: esquema con llaves primarias/foráneas, índices y restricciones. Ver también database/README.md para la carga de 20 equipos.

Las reglas cruciales se aplican en el servidor y en la base; JavaScript solo ayuda a la usabilidad. Se usa PreparedStatement contra inyección SQL y escape HTML en contenido proveniente de usuarios.

## Notas

- Los escudos y la portada se almacenan como **URL de imagen**, no como archivos binarios. Esto mantiene la aplicación ligera y compatible con MySQL/JSP.
- Las llaves de un torneo iniciado no se pueden reorganizar ni cambiar de equipo.
- Se permite crear un torneo nuevo cuando el anterior ya terminó. Los anteriores permanecen en MySQL como historial, pero la interfaz muestra el más reciente.
- Si se muestra la advertencia de conexión, verificá que MySQL esté iniciado y que el script se haya ejecutado.
- El proyecto también incluye un archivo pom.xml opcional para compilación con Maven y validación automática en GitHub Actions.
- No se puede ejecutar un motor MySQL dentro de GitHub Pages: para probar el sistema es necesario Tomcat + MySQL.


## Simulación opcional y resumen deportivo

- En **Crear torneo**, la casilla **Simular los 15 partidos** permite iniciar y finalizar una copa ficticia en un clic. Al terminar abre la primera simulación, con navegación opcional a la siguiente, o salto directo al cuadro. Dejándola desactivada se conserva el flujo clásico.
- Durante un torneo activo, el administrador puede usar **Simular automáticamente** en un partido habilitado, **Simular todos los partidos pendientes**, o ingresar los marcadores manuales.
- Al cerrar un partido se guardan dos tiempos, porcentajes de posesión, pases, tiros, tiros a puerta, ataques peligrosos (dominio ofensivo), córners, faltas, goles con minuto y cambios con minuto. El total calcula los sumatorios de ambos tiempos.
- La ficha de cualquier partido finalizado permite **Reproducir**, **Pausar**, **Saltar animación**, elegir **Primer tiempo**, **Segundo tiempo** o **Partido completo**. El resumen es público, incluso para el rol USUARIO, sin permiso para editar.
- **IMPORTANTE:** las estadísticas, los números de los jugadores, los minutos y los cambios son datos sintéticos ilustrativos. No se afirma que reflejen partidos reales; el simulador utiliza nombres genéricos «Jugador #N» porque no existen plantillas de futbolistas en la base.
- En una base que ya ejecutó `database/schema/torneos.sql` anteriormente, ejecutar **`database/migrations/upgrade_match_simulations.sql`** una vez antes de actualizar la aplicación. En instalaciones nuevas solo ejecutar `database/schema/torneos.sql` actualizado. No se borran torneos anteriores; sus informes estadísticos se reconstruyen al abrirlos por primera vez y se identifican como tal.


## Diseño Stitch Tournament Monolith (edición 2026)

Las ocho vistas Java/JSP usan directamente las cuatro pantallas HTML suministradas por Stitch: inicio, cuadro simétrico, panel administrativo y simulación de partidos. Las pantallas de equipos, ingreso, registro y creación adoptan el mismo sistema visual (Space Grotesk, Inter, blanco/negro y ámbar). Los archivos fuente están en `web/WEB-INF/views/arena/*.jsp`, el CSS local compilado (no depende de Tailwind CDN) en `web/css/stitch.css`, el estilo de skeletons en `stitch-bridge.css`, y el cliente de datos en `web/js/stitch-runtime.js`.

El endpoint público de solo lectura `GET /arena-data` obtiene del servidor la edición actual, equipos, 15 partidos, resultados, informes de simulación, goleadores y faltas. Ningún dato de ejemplo se utiliza para el torneo. La tabla de goleadores identifica números de jugadores simulados. Como no existe registro de tarjetas rojas o amarillas en el esquema, esos campos muestran "Sin registro" en vez de inventar sanciones.

Al entrar, las secciones se ocultan tras tarjetas skeleton con shimmer; los datos se consultan y el contenido aparece en secuencia descendente con transiciones suaves. Se respetan `prefers-reduced-motion`, navegación por teclado y permisos del administrador.

**Rutas:** `/app?view=inicio`, `/app?view=cuadro`, `/app?view=equipos`, `/app?view=admin`, `/app?view=crear` (admin), `/app?view=partido&id=N`, `/app?view=login` y `/app?view=registro`.


## Transmisión simulada en vivo: 60 segundos por encuentro (2026)

Además del modo manual y el modo de resolución instantánea de los 15 partidos, el administrador puede elegir **Transmisión en vivo** al crear una copa, o iniciarla para un torneo activo desde Administración.

- Cada partido simulado dura **60 segundos reales** (minutos virtuales 0 a 90).
- Hay un **intervalo de 20 segundos** antes de comenzar el siguiente encuentro.
- Durante cada partido, los visitantes ven los goles, el cronómetro, los pases, los tiros, los córners y las faltas que corresponden al minuto visible.
- Al acabar, se guarda el marcador definitivo, el ganador avanza en el cuadro y el próximo encuentro empieza después del intervalo.
- Las pantallas **Inicio**, **Cuadro** y **Administración** consultan `GET /arena-data` periódicamente sin tener que recargar la página. El visitante puede entrar a mitad de un encuentro.
- La progresión se guarda en MySQL; **no necesita la pestaña del administrador abierta**. Si no hay visitantes, en la siguiente consulta se procesan los encuentros cuyos tiempos ya vencieron. No requiere un hilo temporizado dentro de Tomcat.
- El modo instantáneo anterior permanece disponible. El administrador no puede registrar marcadores manuales durante una transmisión activa.
- Son **partidos y estadísticas ficticios**, no una transmisión de encuentros deportivos reales.

**Importante para bases existentes:** ejecutar primero `database/migrations/upgrade_live_tournaments.sql` en MySQL Workbench después de actualizar el código. El instalador `database/instalacion_completa_2026.sql` ya lo incluye para instalaciones nuevas. No borra resultados.

### Encabezado según permisos

La barra superior es compartida por todas las páginas. Los visitantes reciben exclusivamente el acceso **Iniciar sesión**; los miembros autenticados ven su nombre y **Salir**. Solo los administradores reciben el enlace **Administración**, comprobado desde JSP y el controlador Java. La pestaña activa tiene un fondo claro y no se muestran roles ficticios ni el mensaje «Datos actualizados».


## Si aún aparece el encabezado viejo en NetBeans/Tomcat

Si ves «VISITANTE», «SIN INICIAR SESIÓN», un avatar ficticio o «DATOS ACTUALIZADOS», tu navegador probablemente está viendo un despliegue anterior. Ejecutá en PowerShell `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verificar-despliegue.ps1` y consultá **[docs/DESPLIEGUE_NETBEANS.md](docs/DESPLIEGUE_NETBEANS.md)**. El servidor actual debe devolver la cabecera `X-Bracket-Arena-UI: 2026-11-25-admin-r3`. No es necesario reinstalar MySQL.
