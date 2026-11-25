-- BRACKET ARENA | Modo de simulación secuencial en vivo (MySQL 8+).
-- Ejecutar una vez en bases ya instaladas, antes de desplegar la versión nueva.
-- También se incluye en database/schema/torneos.sql y en el instalador completo.
-- Un registro por torneo: reloj, partido actual y plan reproducible del partido.
-- Los resultados definitivos permanecen en matches y los informes en match_*.
USE torneos;

CREATE TABLE IF NOT EXISTS tournament_live_runs (
    tournament_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
    status ENUM('RUNNING', 'FINISHED') NOT NULL DEFAULT 'RUNNING',
    current_match_id BIGINT UNSIGNED NULL,
    match_started_at DATETIME(3) NULL,
    next_start_at DATETIME(3) NOT NULL,
    planned_score_a SMALLINT UNSIGNED NULL,
    planned_score_b SMALLINT UNSIGNED NULL,
    rng_seed BIGINT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_live_tournament FOREIGN KEY (tournament_id)
        REFERENCES tournaments(id) ON DELETE RESTRICT,
    CONSTRAINT fk_live_match FOREIGN KEY (current_match_id)
        REFERENCES matches(id) ON DELETE RESTRICT,
    CONSTRAINT chk_live_plan CHECK (
        (current_match_id IS NULL AND match_started_at IS NULL
            AND planned_score_a IS NULL AND planned_score_b IS NULL AND rng_seed IS NULL)
        OR
        (current_match_id IS NOT NULL AND match_started_at IS NOT NULL
            AND planned_score_a IS NOT NULL AND planned_score_b IS NOT NULL
            AND rng_seed IS NOT NULL AND planned_score_a <> planned_score_b)
    )
) ENGINE=InnoDB;
