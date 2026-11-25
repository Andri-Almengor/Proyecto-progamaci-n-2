# Base de datos de Bracket Arena (MySQL 8+)

Aquí está **todo lo necesario** para instalar el esquema, crear una cuenta MySQL exclusiva, cargar **20 equipos de demostración 2026**, actualizar instalaciones existentes y verificar los resultados. El sistema utiliza **9 tablas** y conserva los partidos, resultados y estadísticas de cada torneo.

## Estructura de carpetas

- `schema/`: tablas e índices.
- `seeds/`: datos ficticios de práctica.
- `migrations/`: cambios para instalaciones existentes.
- `setup/`: usuario MySQL restringido.
- `diagnostics/`: consultas de solo lectura.
- Los scripts `instalacion_completa_2026.sql` y `generar_instalador.py` permanecen en `database/` para acceso rápido.

## Archivos

| Archivo | Para qué sirve | ¿Modifica datos existentes? |
|---|---|---|
| `instalacion_completa_2026.sql` | **Instalación rápida**: crea base, 9 tablas, administrador web y 20 equipos | No borra; agrega solamente los que faltan |
| `schema/torneos.sql` | Estructura completa + administrador de prueba | No borra; crea solo lo faltante |
| `seeds/demo_20_equipos.sql` | Agrega 20 equipos sin duplicar; hasta 16 aprobados | Inserta nombres que faltan; no edita existentes |
| `setup/usuario_aplicacion.sql` | Crea `torneos_app` con permisos mínimos de lectura/escritura | Crea/autoriza usuario MySQL; la contraseña es un placeholder |
| `diagnostics/comprobaciones.sql` | Diagnóstico de tablas, cuentas, equipos, torneo, partidos y simulaciones | Solo lectura |
| `migrations/upgrade_match_simulations.sql` | Añade tablas de estadísticas a una **base antigua** que ya tenga las tablas iniciales | No borra |
| `seeds/demo_16_equipos.sql` | Semilla histórica alternativa con 16 equipos | Inserta sus equipos; **no combinar con la de 20** |
| `generar_instalador.py` | Regenera el instalador único a partir del esquema y la semilla de 20 equipos | Solo escribe archivo del repositorio |

## Opción A. Instalar desde cero en MySQL Workbench

1. Abrí MySQL Workbench con una cuenta de MySQL que tenga permisos para crear bases de datos.
2. Abrí **`database/instalacion_completa_2026.sql`** usando *File → Open SQL Script*.
3. Presioná el rayo para ejecutar **todo el archivo**.
4. Vas a tener la base `torneos`, sus nueve tablas, el administrador de demostración y los equipos de prueba.

En una base realmente vacía el resultado es:

| Estado | Equipos |
|---|---:|
| APROBADO | **16** |
| PENDIENTE | **4** |
| Total | **20** |

También podés hacerlo desde la terminal de Windows **CMD** (ubicado en el directorio del proyecto y con MySQL en PATH):

```bat
mysql -u root -p < database\instalacion_completa_2026.sql
```

**Alternativa equivalente:** ejecutar **primero** `schema/torneos.sql` y **después** `seeds/demo_20_equipos.sql`. No hace falta ejecutar los tres.

## Opción B. Ya tenés una base con datos

1. **Hacé un respaldo antes de actualizar.** En CMD:

   ```bat
   mysqldump -u root -p --databases torneos > respaldo_torneos.sql
   ```

2. Ejecutá `database/schema/torneos.sql` para asegurar las tablas actuales. Si la base es muy antigua, podés usar `migrations/upgrade_match_simulations.sql` en lugar de recrear el esquema.
3. Ejecutá `database/seeds/demo_20_equipos.sql` para agregar **solo** los nombres que no existan.

**Comportamiento de la semilla:**

- No borra ni cambia los equipos ya registrados.
- Si hay un torneo activo, **no inserta ninguno**.
- Si ya hay equipos aprobados, solo aprueba los nuevos necesarios para llegar a **16 en total**; los demás quedan pendientes.
- Si alguno de los 20 nombres ya existe, se conserva su registro original y no se repite.
- Si ya existe un equipo pendiente de los 20, seguirá pendiente. Podés gestionarlo desde Administración.
- No crea partidos ni cambia resultados. El sistema debe generar los emparejamientos.

**Atención:** el diseño de tablas usa `CREATE TABLE IF NOT EXISTS`. Eso no transforma columnas de esquemas incompatibles; para instalaciones mucho más antiguas, respalda y revisá antes de aplicar cambios. El archivo `migrations/upgrade_match_simulations.sql` está destinado específicamente a sumar las tres tablas de simulación.

## Crear un usuario MySQL para Tomcat/NetBeans

Ejecutá **`database/setup/usuario_aplicacion.sql`** como administrador de MySQL tras crear `torneos`, pero **cambiá la contraseña de ejemplo del archivo antes de usarlo**.

El script otorga solo `SELECT`, `INSERT`, `UPDATE` y `DELETE` sobre `torneos.*`; la aplicación **no** necesita permisos para modificar la estructura.

Configurá las siguientes variables de entorno en Windows para el proceso de NetBeans/Tomcat:

```text
DB_URL=jdbc:mysql://localhost:3306/torneos?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8
DB_USER=torneos_app
DB_PASSWORD=TU_CONTRASENA_PRIVADA
```

Cerrá **completamente** NetBeans y reinicialo si cambiaste variables de entorno. **No guardés contraseñas reales en GitHub, código Java o capturas.**

La cuenta del sistema web es distinta del usuario MySQL. La cuenta académica inicial es `admin@torneo.local` y su clave de demostración es `AdminExamen2026!`. Cambiá esas credenciales antes de publicar el proyecto.

## Verificar todo

Ejecutá `database/diagnostics/comprobaciones.sql` o, como mínimo:

```sql
USE torneos;
SHOW TABLES;
SELECT status, COUNT(*) AS cantidad FROM teams GROUP BY status;
SELECT COUNT(*) AS usuarios FROM users;
SELECT id, name, status FROM tournaments ORDER BY id DESC LIMIT 5;
```

## Generar un torneo en la aplicación

1. Iniciá sesión con el administrador web.
2. Verificá que haya **exactamente 16 equipos aprobados**.
3. Entrá a **Administración → Crear torneo** e indicá nombre, fechas y premio.
4. La aplicación sortea los **8 octavos, 4 cuartos, 2 semifinales y 1 final**, registrando 15 partidos.
5. Ingresá resultados o utilizá la simulación. Sus informes se guardan en `match_simulations`, `match_half_stats` y `match_events`.

**No insertés un torneo activo directamente con SQL:** el código Java coordina las 16 plazas, los partidos, el avance de ganadores y el campeón con transacciones.

## Mantener el instalador sincronizado

El instalador único es el contenido de `schema/torneos.sql` seguido por `seeds/demo_20_equipos.sql`. Después de editar cualquiera de los dos, corré:

```bash
python database/generar_instalador.py
```

El flujo de GitHub Actions verifica que el instalador esté sincronizado y prueba la carga de 20 equipos y su reejecución sin duplicados.


## Migración del modo de transmisión en vivo (noviembre de 2026)

**Si tu base de datos ya existe**, esta actualización incorpora una tabla nueva:

1. Realizá un respaldo de la base `torneos`.
2. Abrí y ejecutá `database/migrations/upgrade_live_tournaments.sql` como administrador de MySQL.
3. Actualizá el repositorio con `git pull origin main` cuando el PR se fusione, reiniciá NetBeans/Tomcat y ejecutá el proyecto.
4. En Administración podés seleccionar el modo **Manual**, **Instantáneo** o **Transmisión en vivo**.

La tabla `tournament_live_runs` guarda la secuencia actual, el inicio del encuentro, el siguiente inicio y un plan deportivo determinista. No guarda contraseñas. Las tablas `matches`, `match_simulations`, `match_half_stats` y `match_events` conservan los resultados definitivos.

El modo en vivo tarda aproximadamente **19 minutos y 40 segundos** en disputar los 15 partidos si empieza con los octavos sin interrupciones: 60 segundos por encuentro y 20 segundos entre encuentros. La sesión del administrador puede cerrarse sin detener la secuencia. Para evitar cargas innecesarias, no se mantienen conexiones persistentes con todos los visitantes: cada navegador realiza consultas periódicas al servidor.
