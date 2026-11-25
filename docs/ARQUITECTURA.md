# Arquitectura y carpetas de Bracket Arena

Guía de dónde está cada parte del proyecto **Java 21 + JSP + MySQL 8**.
Se ordena el código sin modificar las reglas del torneo de 16 participantes.

## Estructura principal

```text
BracketArena/
├── .github/workflows/build.yml          # Integración continua
├── archive/legacy-ui/                   # Interfaz antigua, fuera del WAR
├── database/
│   ├── README.md                        # Guía completa de SQL
│   ├── instalacion_completa_2026.sql     # Instalación rápida
│   ├── generar_instalador.py            # Mantener SQL combinado actualizado
│   ├── schema/torneos.sql               # Tablas e índices
│   ├── seeds/                           # Semillas de 16 o 20 equipos
│   ├── migrations/                      # Actualizaciones de BD existentes
│   ├── setup/                           # Usuario MySQL con privilegios CRUD
│   └── diagnostics/                     # Consultas de verificación
├── docs/ARQUITECTURA.md                 # Esta guía
├── src/java/com/torneo/
│   ├── AppServlet.java                  # GET/POST, rutas y permisos
│   ├── ArenaDataServlet.java            # JSON para el diseño Stitch
│   ├── Store.java                       # Reglas de negocio y transacciones
│   ├── MatchSimulation.java             # Estadísticas ilustrativas
│   ├── DB.java                          # Conexión JDBC con variables
│   ├── Passwords.java                   # Hash y validación de claves
│   └── Web.java                         # Sesiones, CSRF y escape HTML
├── test/com/torneo/                     # Pruebas automatizadas
├── web/
│   ├── WEB-INF/views/arena/             # Las ocho pantallas activas Stitch
│   │   ├── home.jsp                     # Inicio y estadísticas
│   │   ├── bracket.jsp                  # Llaves
│   │   ├── teams.jsp                    # Equipos
│   │   ├── admin.jsp                    # Administración
│   │   ├── create.jsp                   # Crear torneo
│   │   ├── match.jsp                    # Informe del partido
│   │   ├── login.jsp                    # Ingresar
│   │   └── register.jsp                 # Crear usuario
│   ├── css/stitch.css                   # Estilos compilados originales
│   ├── css/stitch-bridge.css            # Skeletons y animaciones
│   └── js/stitch-runtime.js             # Datos dinámicos del torneo
├── nbproject/                            # Configuración generada NetBeans
├── pom.xml                              # Build Maven
└── build.xml                            # Build NetBeans/Ant
```

## Flujo de una página

```text
Navegador → GET /app → AppServlet → JSP en views/arena/
    → stitch-runtime.js → GET /arena-data
    → ArenaDataServlet → Store → MySQL
    → Datos JSON → Tarjetas, llaves, goleadores y estadísticas
```

La interfaz muestra skeletons durante la consulta, y revela sus secciones
progresivamente al recibir los datos. Cuando no existe torneo activo,
presenta el estado vacío en lugar de marcadores inventados.

## Responsabilidades de Java

| Clase | Función |
|---|---|
| `AppServlet` | Controla navegación, formularios POST, roles y mensajes flash |
| `ArenaDataServlet` | Convierte datos persistidos a JSON para la vista |
| `Store` | Acceso a MySQL, cupo de 16, aprobación y avance transaccional |
| `MatchSimulation` | Genera/recupera reportes deportivos ficticios |
| `DB` | Abre conexiones usando `DB_URL`, `DB_USER`, `DB_PASSWORD` |
| `Passwords` | Protege y verifica contraseñas con PBKDF2 |
| `Web` | Escapa contenido, verifica tokens CSRF y obtiene sesión |

Se conserva el paquete `com.torneo` por compatibilidad con NetBeans y las
pruebas. La separación está en las responsabilidades de cada clase.

## Seguridad y reglas del torneo

- El administrador puede aprobar, crear torneos y registrar resultados.
- El usuario común puede inscribir equipos y consultar simulaciones.
- Cada torneo tiene exactamente 16 equipos aprobados, 15 partidos y un campeón.
- Las reglas se verifican del lado del servidor, nunca solo en JavaScript.
- Las operaciones protegidas usan sesión y token CSRF.
- Las contraseñas de MySQL no deben guardarse en GitHub.
- Las tarjetas amarillas/rojas no se inventan: todavía no existe esa tabla.

## Base de datos y pruebas

Para instalar todo desde cero, ejecutá `database/instalacion_completa_2026.sql`.
Para actualizar, hacer respaldo y elegir otros scripts, consultá
[database/README.md](../database/README.md).

Después de modificar el esquema o la semilla de equipos:

```bash
python database/generar_instalador.py
python database/generar_instalador.py --check
```

Para compilar y ejecutar las pruebas unitarias:

```bash
mvn clean verify
```

**Importante:** las pruebas de integración con `RUN_DB_TESTS=true` crean
datos reales de práctica; usá exclusivamente una base de pruebas descartable.
GitHub Actions levanta MySQL 8.4 y Tomcat 11 para ejecutar el flujo completo.

## Convenciones para contribuir

- Java propio: cuatro espacios y comentarios que explican reglas, no cada línea.
- JavaScript y CSS: dos espacios y comentarios por módulo funcional.
- SQL: separar esquema, seeds, migraciones, usuarios y consultas.
- El HTML generado por Stitch se conserva fiel al diseño original:
  un embellecedor automático podría alterar el espaciado entre etiquetas.
- Los archivos de `archive/legacy-ui` son referencia histórica, no páginas activas.

## Herramientas de formato para futuros cambios

En este PR se utilizaron herramientas de formato automático **sobre código propio**:

- Google Java Format, modalidad `--aosp` (4 espacios), para `src/java/com/torneo/*.java` y `test/com/torneo/*.java`.
- Prettier 3.6.2 para `web/js/stitch-runtime.js` y `web/css/stitch-bridge.css`.

Si necesitás volver a formatear el JavaScript/CSS desde la raíz:

```bash
npx --yes prettier@3.6.2 --write web/js/stitch-runtime.js web/css/stitch-bridge.css
```

Para Java, descargá el `google-java-format-1.24.0-all-deps.jar` de la
distribución oficial y ejecutá con **JDK 21**:

```bash
java -jar google-java-format-1.24.0-all-deps.jar --aosp --replace src/java/com/torneo/*.java test/com/torneo/*.java
```

No se agregaron dependencias a la ejecución de Tomcat. La carpeta de vistas
`web/WEB-INF/views/arena/` mantiene la salida original de Stitch para
evitar diferencias inesperadas de espaciado en el diseño.
