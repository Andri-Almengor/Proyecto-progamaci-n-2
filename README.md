# 🏆 Bracket Arena — Sistema de Gestión de Torneos Eliminatorios

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

## Instalación

1. Abrí MySQL Workbench o consola y ejecutá **database/torneos.sql**. El script es idempotente en la definición de tablas, pero NO borra registros existentes.
2. Opcional: ejecutá **database/demo_16_equipos.sql** para cargar 16 equipos aprobados de práctica. Si querés probar inscripciones desde cero, **no lo ejecutes**.
3. Configurá las variables de entorno del proceso Tomcat/NetBeans si no usás el MySQL local en puerto 3306:
   - DB_URL: jdbc:mysql://localhost:3306/torneos?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8
   - DB_USER: root (valor local predeterminado; preferible usar usuario MySQL con permisos específicos)
   - DB_PASSWORD: contraseña del MySQL local (valor predeterminado vacío)
4. Abrí el directorio como proyecto en NetBeans, elegí Tomcat, y ejecutá **Clean and Build** / **Run**.
5. Entrá a la URL desplegada, por ejemplo http://localhost:8080/BracketArena/app

**Administrador de prueba**: admin@torneo.local / AdminExamen2026! (solo uso académico; cambiá la contraseña antes de publicar). Los registros nuevos siempre son USUARIO; únicamente ADMIN administra aprobaciones, crea torneos y registra marcadores.

## Flujo para la demostración

1. Registrá usuarios normales e iniciá sesión con ellos.
2. En Equipos, registrá escudo (URL http(s)), nombre y teléfono. Los equipos quedan **PENDIENTES**.
3. Entrá como administrador. Aprobá **exactamente 16** equipos (no se permite aprobar 17).
4. En Administración, completá nombre, imagen (URL), fechas, premio en colones y verificá las **16 selecciones**.
5. Crear torneo sortea equipos y guarda 15 partidos con sus cuatro rondas.
6. En cada partido habilitado, escribí exclusivamente los dos marcadores y confirmá. Nunca se permiten empates ni editar resultados finalizados.
7. Los ganadores avanzan sin editar llaves. Tras la final aparece la celebración del campeón y el estado FINALIZADO.

## Arquitectura

- src/java/com/torneo/DB.java: conexión por variables de entorno.
- src/java/com/torneo/Passwords.java: contraseñas PBKDF2-HMAC-SHA256 con salt aleatoria.
- src/java/com/torneo/Store.java: consultas, objetos de datos y transacciones.
- src/java/com/torneo/AppServlet.java: rutas GET/POST, autorización, protección CSRF y validación.
- src/java/com/torneo/Web.java: sanitización de HTML/URLs y sesión.
- web/WEB-INF/views/: vistas JSP (sin acceso directo por URL).
- web/css/arena.css y web/js/arena.js: experiencia visual y validación del cliente.
- database/torneos.sql: esquema con llaves primarias/foráneas, índices y restricciones.

Las reglas cruciales se aplican en el servidor y en la base; JavaScript solo ayuda a la usabilidad. Se usa PreparedStatement contra inyección SQL y escape HTML en contenido proveniente de usuarios.

## Notas

- Los escudos y la portada se almacenan como **URL de imagen**, no como archivos binarios. Esto mantiene la aplicación ligera y compatible con MySQL/JSP.
- Las llaves de un torneo iniciado no se pueden reorganizar ni cambiar de equipo.
- Se permite crear un torneo nuevo cuando el anterior ya terminó. Los anteriores permanecen en MySQL como historial, pero la interfaz muestra el más reciente.
- Si se muestra la advertencia de conexión, verificá que MySQL esté iniciado y que el script se haya ejecutado.
- El proyecto también incluye un archivo pom.xml opcional para compilación con Maven y validación automática en GitHub Actions.
- No se puede ejecutar un motor MySQL dentro de GitHub Pages: para probar el sistema es necesario Tomcat + MySQL.


## Simulación opcional y resumen deportivo

- En **Crear torneo**, la casilla **Simular los 15 partidos** permite iniciar y finalizar una copa ficticia en un clic. Dejándola desactivada se conserva el flujo clásico.
- Durante un torneo activo, el administrador puede usar **Simular automáticamente** en un partido habilitado, **Simular todos los partidos pendientes**, o ingresar los marcadores manuales.
- Al cerrar un partido se guardan dos tiempos, porcentajes de posesión, pases, tiros, tiros a puerta, ataques peligrosos (dominio ofensivo), córners, faltas, goles con minuto y cambios con minuto. El total calcula los sumatorios de ambos tiempos.
- La ficha de cualquier partido finalizado permite **Reproducir**, **Pausar**, **Saltar animación**, elegir **Primer tiempo**, **Segundo tiempo** o **Partido completo**. El resumen es público, incluso para el rol USUARIO, sin permiso para editar.
- **IMPORTANTE:** las estadísticas, los números de los jugadores, los minutos y los cambios son datos sintéticos ilustrativos. No se afirma que reflejen partidos reales; el simulador utiliza nombres genéricos «Jugador #N» porque no existen plantillas de futbolistas en la base.
- En una base que ya ejecutó `database/torneos.sql` anteriormente, ejecutar **`database/upgrade_match_simulations.sql`** una vez antes de actualizar la aplicación. En instalaciones nuevas solo ejecutar `database/torneos.sql` actualizado. No se borran torneos anteriores; sus informes estadísticos se reconstruyen al abrirlos por primera vez y se identifican como tal.
