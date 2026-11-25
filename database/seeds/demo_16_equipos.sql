-- DATOS OPCIONALES para probar las llaves sin crear 16 usuarios.
-- Ejecutar DESPUÉS de torneos.sql en una instalación nueva. No usar en producción.
USE torneos;
INSERT INTO users(full_name,email,password_hash,role)
VALUES ('Organizador de Pruebas','demo@torneo.local',
'pbkdf2_sha256$210000$x2IbTQIHnbhTkOV8I6kUug==$VbyecpPh3SlMoIB/isclwFCkWGzVxQcOweMf0odDrgQ=','USUARIO')
ON DUPLICATE KEY UPDATE email=email;
INSERT INTO teams(name,shield_url,phone,owner_id,status)
SELECT nombres.name, '', '8888-8888', u.id, 'APROBADO'
FROM (
SELECT 'Halcones del Norte' name UNION ALL SELECT 'Leones Dorados' UNION ALL
SELECT 'Tigres de Acero' UNION ALL SELECT 'Toros Rojos' UNION ALL
SELECT 'Lobos del Valle' UNION ALL SELECT 'Dragones FC' UNION ALL
SELECT 'Águilas Reales' UNION ALL SELECT 'Titanes del Sur' UNION ALL
SELECT 'Panteras Negras' UNION ALL SELECT 'Cóndores FC' UNION ALL
SELECT 'Guerreros Azules' UNION ALL SELECT 'Estrellas United' UNION ALL
SELECT 'Tormenta FC' UNION ALL SELECT 'Fénix Deportivo' UNION ALL
SELECT 'Centuriones' UNION ALL SELECT 'Atléticos del Este'
) nombres CROSS JOIN users u
WHERE u.email='demo@torneo.local'
ON DUPLICATE KEY UPDATE name=name;
