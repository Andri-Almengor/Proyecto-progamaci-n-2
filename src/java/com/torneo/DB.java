package com.torneo;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Configuración de conexión JDBC con MySQL 8+.
 *
 * <p>Las credenciales se leen de variables de entorno para no guardar contraseñas en el código ni
 * en GitHub. En el README de database/ se explica cómo crear el usuario de la aplicación.
 */
public final class DB {

    private DB() {
        // Clase utilitaria: no se instancia.
    }

    /** Usa un valor local predeterminado si la variable está ausente o vacía. */
    private static String env(String key, String fallback) {
        String value = System.getenv(key);
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }

    /**
     * Abre una conexión nueva. El método que la llama debe cerrarla con try-with-resources para
     * liberar recursos incluso si ocurre una excepción.
     */
    public static Connection open() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ex) {
            throw new SQLException("No se encontró el controlador JDBC MySQL.", ex);
        }

        String url =
                env(
                        "DB_URL",
                        "jdbc:mysql://localhost:3306/torneos?useSSL=false"
                                + "&allowPublicKeyRetrieval=true&serverTimezone=UTC"
                                + "&characterEncoding=UTF-8");

        String username = env("DB_USER", "root");
        String password = System.getenv().getOrDefault("DB_PASSWORD", "");
        return DriverManager.getConnection(url, username, password);
    }
    /**
     * Mensajes breves y seguros para identificar problemas comunes de MySQL.
     * La excepción original completa permanece en los registros de Tomcat;
     * nunca exponemos la contraseña ni la URL privada al navegador.
     */
    public static String publicErrorCode(SQLException exception) {
        for (Throwable cause = exception; cause != null; cause = cause.getCause()) {
            if (!(cause instanceof SQLException sql)) {
                continue;
            }
            switch (sql.getErrorCode()) {
                case 1045: return "DB_AUTH";
                case 1044: case 1142: return "DB_PERMISSIONS";
                case 1049: return "DB_NOT_FOUND";
                case 1146: return "DB_SCHEMA";
                case 2002: case 2003: return "DB_CONNECTION";
                default: break;
            }
            String sqlState = sql.getSQLState();
            if (sqlState != null && sqlState.startsWith("08")) {
                return "DB_CONNECTION";
            }
        }
        return "DB_ERROR";
    }

    /** Instrucción que acompaña al código de error, sin datos confidenciales. */
    public static String publicErrorMessage(SQLException exception) {
        return switch (publicErrorCode(exception)) {
            case "DB_AUTH" -> "MySQL rechazó el usuario o la contraseña. "
                    + "Revisá DB_USER y DB_PASSWORD configurados para NetBeans/Tomcat.";
            case "DB_PERMISSIONS" -> "El usuario MySQL no tiene permisos sobre torneos. "
                    + "Revisá los privilegios de la cuenta torneos_app.";
            case "DB_NOT_FOUND" -> "No existe la base de datos torneos. "
                    + "Ejecutá database/schema/torneos.sql desde MySQL Workbench.";
            case "DB_SCHEMA" -> "Falta una tabla necesaria en torneos. "
                    + "Revisá las migraciones y el esquema en database/.";
            case "DB_CONNECTION" -> "No se puede conectar con el servidor MySQL. "
                    + "Comprobá que esté iniciado y que DB_URL tenga el host y puerto correctos.";
            default -> "No fue posible consultar MySQL. Revisá los registros de Tomcat "
                    + "y las variables DB_URL, DB_USER y DB_PASSWORD.";
        };
    }

}
