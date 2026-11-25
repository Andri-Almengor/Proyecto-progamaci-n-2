-- BRACKET ARENA | 20 equipos de demostración, edición 2026
-- Requisitos: MySQL 8+, database/schema/torneos.sql aplicado previamente.
-- Ejecutar con una cuenta administradora de MySQL, NO con el usuario CRUD de la app.
-- Es seguro repetirlo: NO borra equipos, NO modifica equipos existentes
-- y NO inserta nada si hay un torneo ACTIVO.
--
-- Reglas de aprobación:
-- * Base nueva: 16 APROBADOS, 4 PENDIENTES.
-- * Base con otros aprobados: solo aprueba los nuevos que falten para llegar a 16.
-- * Equipos que ya existan conservan nombre, estado, dueño y demás datos.
-- * Un torneo se crea desde la aplicación, no directamente por este script.

USE torneos;

DROP TEMPORARY TABLE IF EXISTS _bracket_demo20;
CREATE TEMPORARY TABLE _bracket_demo20 (
  numero TINYINT UNSIGNED NOT NULL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

INSERT INTO _bracket_demo20 (numero, nombre) VALUES
  (1, 'Leones del Valle'),
  (2, 'Aguilas Doradas FC'),
  (3, 'Halcones del Sur'),
  (4, 'Toros de Acero'),
  (5, 'Pumas de la Montana'),
  (6, 'Titanes del Norte'),
  (7, 'Guerreros del Sol'),
  (8, 'Panteras Negras'),
  (9, 'Rayos de Occidente'),
  (10, 'Dragones Rojos'),
  (11, 'Lobos de la Capital'),
  (12, 'Centuriones FC'),
  (13, 'Huracanes del Pacifico'),
  (14, 'Deportivo Olimpo'),
  (15, 'Fenix United'),
  (16, 'Estrellas del Caribe'),
  (17, 'Academia Aurora'),
  (18, 'Atletico Horizonte'),
  (19, 'Union Esmeralda'),
  (20, 'Real Tempestad');

-- El mismo candado que usa Java para inscripciones/aprobaciones.
START TRANSACTION;
SELECT lock_id FROM system_lock WHERE lock_id = 1 FOR UPDATE;

SET @aprobados_antes := (SELECT COUNT(*) FROM teams WHERE status = 'APROBADO');
SET @torneo_activo := (SELECT COUNT(*) FROM tournaments WHERE status = 'ACTIVO');

-- Calculamos las posiciones únicamente de los equipos que faltan.
DROP TEMPORARY TABLE IF EXISTS _bracket_demo20_faltantes;
CREATE TEMPORARY TABLE _bracket_demo20_faltantes AS
SELECT d.numero, d.nombre,
       ROW_NUMBER() OVER (ORDER BY d.numero) AS prioridad
FROM _bracket_demo20 AS d
LEFT JOIN teams AS existentes ON existentes.name = d.nombre
WHERE existentes.id IS NULL;

INSERT INTO teams (name, shield_url, phone, owner_id, status)
SELECT f.nombre, '', '00000000', u.id,
       CASE WHEN @aprobados_antes + f.prioridad <= 16
            THEN 'APROBADO' ELSE 'PENDIENTE' END
FROM _bracket_demo20_faltantes AS f
JOIN users AS u
  ON u.email = 'admin@torneo.local' AND u.role = 'ADMIN'
WHERE @torneo_activo = 0
ORDER BY f.numero;

COMMIT;
DROP TEMPORARY TABLE IF EXISTS _bracket_demo20_faltantes;
DROP TEMPORARY TABLE IF EXISTS _bracket_demo20;

-- Confirmación (no crea el torneo: lo hace la aplicación).
SELECT CASE WHEN @torneo_activo > 0
  THEN 'No se agregaron equipos porque ya existe un torneo activo.'
  ELSE 'Carga finalizada. Revisar cantidad de aprobados y pendientes.'
END AS mensaje;

SELECT status, COUNT(*) AS cantidad
FROM teams
GROUP BY status
ORDER BY status;

SELECT id, name, status, owner_id
FROM teams
WHERE name IN ('Leones del Valle', 'Aguilas Doradas FC', 'Halcones del Sur', 'Toros de Acero', 'Pumas de la Montana', 'Titanes del Norte', 'Guerreros del Sol', 'Panteras Negras', 'Rayos de Occidente', 'Dragones Rojos', 'Lobos de la Capital', 'Centuriones FC', 'Huracanes del Pacifico', 'Deportivo Olimpo', 'Fenix United', 'Estrellas del Caribe', 'Academia Aurora', 'Atletico Horizonte', 'Union Esmeralda', 'Real Tempestad')
ORDER BY id;
