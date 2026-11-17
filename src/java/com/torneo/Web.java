package com.torneo;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.net.URI;
import java.security.SecureRandom;
import java.util.Base64;

public final class Web {
    private static final SecureRandom RNG = new SecureRandom();
    private Web() {}
    public static String esc(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
    public static String token(HttpServletRequest req) {
        HttpSession session = req.getSession(true);
        String current = (String) session.getAttribute("csrf");
        if (current == null) {
            byte[] bits = new byte[32];
            RNG.nextBytes(bits);
            current = Base64.getUrlEncoder().withoutPadding().encodeToString(bits);
            session.setAttribute("csrf", current);
        }
        return current;
    }
    public static boolean csrfValid(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        String expected = s == null ? null : (String) s.getAttribute("csrf");
        String actual = req.getParameter("csrf");
        return expected != null && actual != null && expected.equals(actual);
    }
    public static String image(String raw) {
        if (raw == null || raw.isBlank()) return "";
        try {
            URI uri = URI.create(raw.trim());
            String scheme = uri.getScheme();
            if (uri.getHost() == null || uri.getUserInfo() != null ||
                scheme == null || !("https".equalsIgnoreCase(scheme) || "http".equalsIgnoreCase(scheme)) ||
                raw.length() > 1024) return "";
            return raw.trim();
        } catch (IllegalArgumentException e) { return ""; }
    }
    public static String requiredImage(String raw) throws Store.RuleException {
        if (raw == null || raw.trim().isEmpty()) return "";
        String value = image(raw);
        if (value.isEmpty()) throw new Store.RuleException("La imagen debe tener una URL http o https válida.");
        return value;
    }
    public static Store.User user(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (Store.User) session.getAttribute("user");
    }
}
