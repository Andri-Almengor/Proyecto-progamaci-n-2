package com.torneo;

import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;
import java.sql.SQLException;

/** Mensajes públicos seguros para fallas frecuentes de MySQL. */
public class DatabaseErrorTest {

    @Test
    void classifiesLoginFailureWithoutExposingCredentials() {
        SQLException error = new SQLException("Access denied for user", "28000", 1045);
        assertEquals("DB_AUTH", DB.publicErrorCode(error));
        assertEquals(true, DB.publicErrorMessage(error).contains("DB_PASSWORD"));
    }

    @Test
    void classifiesMissingDatabaseAndSchema() {
        assertEquals("DB_NOT_FOUND",
                DB.publicErrorCode(new SQLException("Unknown database", "42000", 1049)));
        assertEquals("DB_SCHEMA",
                DB.publicErrorCode(new SQLException("Table missing", "42S02", 1146)));
    }

    @Test
    void classifiesNestedTransportFailureAndAccessDenied() {
        SQLException socket = new SQLException("Communications failure", "08S01");
        SQLException outer = new SQLException("Wrapped error", socket);
        assertEquals("DB_CONNECTION", DB.publicErrorCode(outer));
        assertEquals("DB_PERMISSIONS",
                DB.publicErrorCode(new SQLException("Permission denied", "42000", 1142)));
    }
}
