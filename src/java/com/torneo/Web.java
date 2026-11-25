package com.torneo;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.net.URI;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Utilidades HTTP comunes: usuario autenticado, CSRF y validación de contenido.
 * Ninguna de estas comprobaciones debe depender únicamente de JavaScript.
 */
public final class Web {

    private static final SecureRandom RNG = new SecureRandom();

    private Web() {
        // Clase utilitaria: no se instancia.
    }

    /** Escapa texto de usuarios antes de insertarlo en HTML. */
    public static String esc(String text) {
        if (text == null) {
            return "";
        }
        return text.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    /**
     * Devuelve el token CSRF asociado a la sesión. Si aún no existe,
     * lo crea con 32 bytes criptográficamente aleatorios.
     */
    public static String token(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        String current = (String) session.getAttribute("csrf");
        if (current == null) {
            byte[] random = new byte[32];
            RNG.nextBytes(random);
            current = Base64.getUrlEncoder().withoutPadding().encodeToString(random);
            session.setAttribute("csrf", current);
        }
        return current;
    }

    /** Verifica que el formulario POST pertenece a la sesión actual. */
    public static boolean csrfValid(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        String expected = session == null ? null : (String) session.getAttribute("csrf");
        String received = request.getParameter("csrf");
        return expected != null && received != null && expected.equals(received);
    }

    /**
     * Acepta solo URLs HTTP/HTTPS con host, sin credenciales embebidas.
     * La imagen se carga desde una URL; no se almacena como BLOB.
     */
    public static String image(String raw) {
        if (raw == null || raw.isBlank()) {
            return "";
        }
        try {
            URI uri = URI.create(raw.trim());
            String scheme = uri.getScheme();
            boolean http = "https".equalsIgnoreCase(scheme)
                    || "http".equalsIgnoreCase(scheme);

            if (uri.getHost() == null || uri.getUserInfo() != null
                    || !http || raw.length() > 1024) {
                return "";
            }
            return raw.trim();
        } catch (IllegalArgumentException ex) {
            return "";
        }
    }

    /** Distingue una URL vacía (opcional) de una URL no válida. */
    public static String requiredImage(String raw) throws Store.RuleException {
        if (raw == null || raw.trim().isEmpty()) {
            return "";
        }
        String validUrl = image(raw);
        if (validUrl.isEmpty()) {
            throw new Store.RuleException(
                    "La imagen debe tener una URL http o https válida.");
        }
        return validUrl;
    }

    /** Obtiene el usuario autenticado o null si no existe sesión. */
    public static Store.User user(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (Store.User) session.getAttribute("user");
    }
}
