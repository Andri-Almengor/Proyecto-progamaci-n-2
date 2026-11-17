package com.torneo;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/** Hash PBKDF2-HMAC-SHA256 con sal individual y comparación de tiempo constante. */
public final class Passwords {
    private static final int ITERATIONS = 210000;
    private static final SecureRandom RNG = new SecureRandom();
    private Passwords() {}
    public static String hash(String password) {
        byte[] salt = new byte[16];
        RNG.nextBytes(salt);
        return "pbkdf2_sha256$" + ITERATIONS + "$" +
                Base64.getEncoder().encodeToString(salt) + "$" +
                Base64.getEncoder().encodeToString(derive(password, salt, ITERATIONS));
    }
    private static byte[] derive(String password, byte[] salt, int iterations) {
        PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, iterations, 256);
        try {
            return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
        } catch (Exception ex) {
            throw new IllegalStateException("No se pudo generar el hash", ex);
        } finally {
            spec.clearPassword();
        }
    }
    public static boolean verify(String password, String encoded) {
        if (password == null || encoded == null) return false;
        try {
            String[] parts = encoded.split("\\$", -1);
            if (parts.length != 4 || !"pbkdf2_sha256".equals(parts[0])) return false;
            int n = Integer.parseInt(parts[1]);
            if (n < 100000 || n > 1000000) return false;
            byte[] salt = Base64.getDecoder().decode(parts[2]);
            byte[] expected = Base64.getDecoder().decode(parts[3]);
            if (salt.length < 16 || expected.length != 32) return false;
            return MessageDigest.isEqual(expected, derive(password, salt, n));
        } catch (RuntimeException ex) {
            return false;
        }
    }
}
