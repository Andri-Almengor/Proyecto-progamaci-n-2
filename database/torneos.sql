-- SISTEMA DE TORNEOS ELIMINATORIOS (MySQL 8+)
-- IMPORTANTE: este script reinicia SOLO la base "torneos".
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
