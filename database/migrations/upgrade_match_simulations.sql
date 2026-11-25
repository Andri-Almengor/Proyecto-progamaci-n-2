-- Ejecutar una sola vez sobre una instalación existente, sin borrar datos.
USE torneos;

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
