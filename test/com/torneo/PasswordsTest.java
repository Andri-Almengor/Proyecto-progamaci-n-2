package com.torneo;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

public class PasswordsTest {
    @Test
    void passwordsAreSaltedAndVerified() {
        String a = Passwords.hash("ClaveSegura123!");
        String b = Passwords.hash("ClaveSegura123!");
        assertNotEquals(a, b, "Cada hash requiere una sal aleatoria");
        assertTrue(Passwords.verify("ClaveSegura123!", a));
        assertFalse(Passwords.verify("contraseña incorrecta", a));
        assertFalse(Passwords.verify(null, a));
        assertFalse(Passwords.verify("ClaveSegura123!", "formato_incorrecto"));
    }

    @Test
    void demoAdminHashWorks() {
        String hash =
                "pbkdf2_sha256$210000$x2IbTQIHnbhTkOV8I6kUug==$VbyecpPh3SlMoIB/isclwFCkWGzVxQcOweMf0odDrgQ=";
        assertTrue(Passwords.verify("AdminExamen2026!", hash));
    }
}
