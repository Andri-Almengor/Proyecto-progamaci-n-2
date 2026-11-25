-- BRACKET ARENA | INSTALACION COMPLETA 2026 (MySQL 8+)
-- Un solo archivo para MySQL Workbench: esquema + 20 equipos.
-- No ejecuta DROP DATABASE ni borra registros existentes.
-- Usuario MySQL opcional: database/setup/usuario_aplicacion.sql

-- SISTEMA DE TORNEOS ELIMINATORIOS (MySQL 8+)
-- IMPORTANTE: este script NO reinicia ni elimina la base "torneos".
-- Crea las tablas que no existan; no modifica columnas de tablas antiguas.
CREATE DATABASE IF NOT EXISTS torneos CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE torneos;

-- Candado transaccional para garantizar cupo de 16 e inscripción coherente.
CREATE TABLE IF NOT EXISTS system_lock (lock_id TINYINT UNSIGNED PRIMARY KEY) ENGINE=InnoDB;
INSERT IGNORE INTO system_lock (lock_id) VALUES (1);

CREATE TABLE IF NOT EXISTS users (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
 full_name VARCHAR(120) NOT NULL,
 email VARCHAR(190) NOT NULL,
 password_hash VARCHAR(255) NOT NULL,
 role ENUM('ADMIN','USUARIO') NOT NULL DEFAULT 'USUARIO',
 active BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS teams (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 shield_url VARCHAR(1024) NOT NULL DEFAULT '',
 phone VARCHAR(20) NOT NULL,
 owner_id BIGINT UNSIGNED NOT NULL,
 status ENUM('PENDIENTE','APROBADO','RECHAZADO') NOT NULL DEFAULT 'PENDIENTE',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_teams_name (name),
 KEY idx_teams_status (status),
 CONSTRAINT fk_team_owner FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tournaments (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(140) NOT NULL,
 image_url VARCHAR(1024) NOT NULL DEFAULT '',
 start_date DATE NOT NULL,
 end_date DATE NOT NULL,
 prize_crc DECIMAL(14,2) NOT NULL,
 status ENUM('ACTIVO','FINALIZADO') NOT NULL,
 champion_team_id BIGINT UNSIGNED NULL,
 active_slot TINYINT UNSIGNED NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_one_active_tournament (active_slot),
 CONSTRAINT chk_dates CHECK (end_date >= start_date),
 CONSTRAINT chk_prize CHECK (prize_crc >= 0),
 CONSTRAINT chk_slot CHECK ((status='ACTIVO' AND active_slot=1 AND champion_team_id IS NULL) OR
                            (status='FINALIZADO' AND active_slot IS NULL AND champion_team_id IS NOT NULL)),
 CONSTRAINT fk_champion FOREIGN KEY (champion_team_id) REFERENCES teams(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tournament_teams (
 tournament_id BIGINT UNSIGNED NOT NULL,
 team_id BIGINT UNSIGNED NOT NULL,
 PRIMARY KEY (tournament_id, team_id),
 CONSTRAINT fk_part_tournament FOREIGN KEY (tournament_id) REFERENCES tournaments(id) ON DELETE RESTRICT,
 CONSTRAINT fk_part_team FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS matches (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
 tournament_id BIGINT UNSIGNED NOT NULL,
 round_no TINYINT UNSIGNED NOT NULL,
 match_no TINYINT UNSIGNED NOT NULL,
 team_a_id BIGINT UNSIGNED NULL,
 team_b_id BIGINT UNSIGNED NULL,
 score_a SMALLINT UNSIGNED NULL,
 score_b SMALLINT UNSIGNED NULL,
 winner_id BIGINT UNSIGNED NULL,
 status ENUM('PENDIENTE','FINALIZADO') NOT NULL DEFAULT 'PENDIENTE',
 played_at DATETIME NULL,
 UNIQUE KEY uq_match_position (tournament_id, round_no, match_no),
 KEY idx_match_round (tournament_id, round_no),
 CONSTRAINT chk_round CHECK (round_no BETWEEN 1 AND 4),
 CONSTRAINT chk_score CHECK (
   (status='PENDIENTE' AND score_a IS NULL AND score_b IS NULL AND winner_id IS NULL) OR
   (status='FINALIZADO' AND score_a IS NOT NULL AND score_b IS NOT NULL AND score_a <> score_b
    AND winner_id IS NOT NULL AND team_a_id IS NOT NULL AND team_b_id IS NOT NULL)
 ),
 CONSTRAINT fk_match_tournament FOREIGN KEY (tournament_id) REFERENCES tournaments(id) ON DELETE RESTRICT,
 CONSTRAINT fk_match_a FOREIGN KEY (team_a_id) REFERENCES teams(id) ON DELETE RESTRICT,
 CONSTRAINT fk_match_b FOREIGN KEY (team_b_id) REFERENCES teams(id) ON DELETE RESTRICT,
 CONSTRAINT fk_match_winner FOREIGN KEY (winner_id) REFERENCES teams(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Cuenta de demostración para laboratorio. ¡CAMBIAR antes de publicar!
-- Correo: admin@torneo.local | Contraseña: AdminExamen2026!
-- Hash PBKDF2-HMAC-SHA256 proveniente de la plantilla original.
INSERT INTO users (full_name, email, password_hash, role)
VALUES ('Administrador del Torneo','admin@torneo.local',
'pbkdf2_sha256$210000$x2IbTQIHnbhTkOV8I6kUug==$VbyecpPh3SlMoIB/isclwFCkWGzVxQcOweMf0odDrgQ=','ADMIN')
ON DUPLICATE KEY UPDATE email=email;


-- Informes de partidos simulados, guardados para reproducirlos cuando se desee.
-- Los resultados auténticos del torneo siguen en matches; estas estadísticas son ficticias.
CREATE TABLE IF NOT EXISTS match_simulations (
 match_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
 mode ENUM('MANUAL','AUTOMATICA','RECONSTRUIDA') NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_sim_match FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS match_half_stats (
 match_id BIGINT UNSIGNED NOT NULL,
 half_no TINYINT UNSIGNED NOT NULL,
 possession_a TINYINT UNSIGNED NOT NULL,
 passes_a SMALLINT UNSIGNED NOT NULL, passes_b SMALLINT UNSIGNED NOT NULL,
 shots_a SMALLINT UNSIGNED NOT NULL, shots_b SMALLINT UNSIGNED NOT NULL,
 on_target_a SMALLINT UNSIGNED NOT NULL, on_target_b SMALLINT UNSIGNED NOT NULL,
 dangerous_a SMALLINT UNSIGNED NOT NULL, dangerous_b SMALLINT UNSIGNED NOT NULL,
 corners_a SMALLINT UNSIGNED NOT NULL, corners_b SMALLINT UNSIGNED NOT NULL,
 fouls_a SMALLINT UNSIGNED NOT NULL, fouls_b SMALLINT UNSIGNED NOT NULL,
 PRIMARY KEY (match_id, half_no),
 CONSTRAINT fk_half_match FOREIGN KEY (match_id) REFERENCES match_simulations(match_id) ON DELETE CASCADE,
 CONSTRAINT chk_half_no CHECK (half_no IN (1, 2)),
 CONSTRAINT chk_possession CHECK (possession_a BETWEEN 0 AND 100),
 CONSTRAINT chk_shots_a CHECK (on_target_a <= shots_a),
 CONSTRAINT chk_shots_b CHECK (on_target_b <= shots_b)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS match_events (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
 match_id BIGINT UNSIGNED NOT NULL,
 minute_no TINYINT UNSIGNED NOT NULL,
 event_type ENUM('GOL','CAMBIO') NOT NULL,
 team_side ENUM('A','B') NOT NULL,
 player_name VARCHAR(80) NOT NULL,
 player_out VARCHAR(80) NULL,
 KEY idx_sim_timeline (match_id, minute_no, id),
 CONSTRAINT fk_event_match FOREIGN KEY (match_id) REFERENCES match_simulations(match_id) ON DELETE CASCADE,
 CONSTRAINT chk_event_minute CHECK (minute_no BETWEEN 1 AND 90)
) ENGINE=InnoDB;

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
