package com.torneo;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/** Configuración JDBC por variables de entorno, sin credenciales en el repositorio. */
public final class DB {
    private DB() {}
    private static String env(String key, String fallback) {
        String v = System.getenv(key);
        return v == null || v.trim().isEmpty() ? fallback : v.trim();
    }
    public static Connection open() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ex) {
            throw new SQLException("No se encontró el controlador JDBC MySQL.", ex);
        }
        String url = env("DB_URL", "jdbc:mysql://localhost:3306/torneos?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8");
        return DriverManager.getConnection(url, env("DB_USER", "root"), System.getenv().getOrDefault("DB_PASSWORD", ""));
    }
}
