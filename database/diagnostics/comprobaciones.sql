-- BRACKET ARENA | Consultas de diagnóstico de solo lectura
USE torneos;

-- Verificar tablas necesarias (9 en total).
SHOW TABLES;

-- Conteo de cuentas, equipos por estado y cantidad de aprobados.
SELECT role, COUNT(*) AS cantidad FROM users GROUP BY role;
SELECT status, COUNT(*) AS cantidad FROM teams GROUP BY status;
SELECT
  (SELECT COUNT(*) FROM teams WHERE status = 'APROBADO') AS aprobados,
  (SELECT COUNT(*) FROM teams WHERE status = 'PENDIENTE') AS pendientes,
  (SELECT COUNT(*) FROM teams) AS equipos_totales;

-- Verificar administrador de la aplicación (sin mostrar el hash).
SELECT id, full_name, email, role, active FROM users
WHERE email = 'admin@torneo.local';

-- Ver la edición más reciente y su estado.
SELECT id, name, start_date, end_date, prize_crc, status, champion_team_id
FROM tournaments ORDER BY id DESC LIMIT 5;

-- Ver rondas y encuentros de la última edición.
SELECT m.round_no, m.match_no, a.name AS equipo_a, b.name AS equipo_b,
       m.score_a, m.score_b, m.status
FROM matches m
LEFT JOIN teams a ON a.id = m.team_a_id
LEFT JOIN teams b ON b.id = m.team_b_id
WHERE m.tournament_id = (SELECT MAX(id) FROM tournaments)
ORDER BY m.round_no, m.match_no;

-- Contabilizar los reportes de simulación existentes.
SELECT mode, COUNT(*) AS informes
FROM match_simulations GROUP BY mode;
