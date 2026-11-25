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
}
