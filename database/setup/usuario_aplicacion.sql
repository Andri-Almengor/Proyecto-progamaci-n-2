-- BRACKET ARENA | Usuario MySQL exclusivo para la aplicación
-- PASO 1: Ejecutar database/schema/torneos.sql (o instalacion_completa_2026.sql).
-- PASO 2: REEMPLAZAR el texto CAMBIAR_ESTA_CONTRASENA_LARGA_Y_UNICA
--         por una contraseña privada, distinta de la cuenta administrador web.
-- PASO 3: Ejecutar este archivo CON UN ADMINISTRADOR DE MYSQL (root).
-- IMPORTANTE: CREATE USER IF NOT EXISTS NO CAMBIA una clave preexistente.

CREATE USER IF NOT EXISTS 'torneos_app'@'localhost'
  IDENTIFIED BY 'CAMBIAR_ESTA_CONTRASENA_LARGA_Y_UNICA';

-- La aplicación solo necesita operaciones de datos; no DDL ni GRANT.
GRANT SELECT, INSERT, UPDATE, DELETE
  ON torneos.* TO 'torneos_app'@'localhost';

SHOW GRANTS FOR 'torneos_app'@'localhost';

-- Si la cuenta ya existe y olvidaste/cambiaste su contraseña,
-- ejecutá MANUALMENTE la siguiente instrucción con una NUEVA clave privada:
-- ALTER USER 'torneos_app'@'localhost' IDENTIFIED BY 'TU_NUEVA_CLAVE';
--
-- Variables de entorno del proceso NetBeans/Tomcat:
-- DB_USER=torneos_app
-- DB_PASSWORD=<contraseña que elegiste>
-- DB_URL=jdbc:mysql://localhost:3306/torneos?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8
