package com.torneo;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;

/**
 * Repositorio de datos y reglas transaccionales del torneo eliminatorio.
 *
 * <p>El acceso a MySQL se realiza con PreparedStatement y try-with-resources. Las operaciones que
 * asignan cupos o actualizan partidos usan transacciones para evitar resultados incompletos o
 * aprobaciones simultáneas.
 */
public final class Store {
    private Store() {}

    private static final SecureRandom RANDOM = new SecureRandom();

    /** Serializa las aprobaciones, inscripciones y la creación del torneo. */
    private static void lockCoordinator(Connection c) throws SQLException {
        try (PreparedStatement p =
                        c.prepareStatement(
                                "SELECT lock_id FROM system_lock WHERE lock_id=1 FOR UPDATE");
                ResultSet r = p.executeQuery()) {
            if (!r.next()) throw new SQLException("Falta la fila de control del torneo en MySQL.");
        }
    }

    public static final class RuleException extends Exception {
        public RuleException(String message) {
            super(message);
        }
    }

    /** Usuario autenticado: los permisos dependen del rol ADMIN o USUARIO. */
    public static final class User implements java.io.Serializable {
        private static final long serialVersionUID = 1L;
        public final long id;
        public final String name, email, role;

        User(long id, String name, String email, String role) {
            this.id = id;
            this.name = name;
            this.email = email;
            this.role = role;
        }

        public boolean admin() {
            return "ADMIN".equals(role);
        }
    }

    /** Equipo inscrito con su estado de aprobación y propietario. */
    public static final class Team {
        public final long id, ownerId;
        public final String name, shield, phone, owner, status;

        Team(ResultSet r) throws SQLException {
            id = r.getLong("id");
            ownerId = r.getLong("owner_id");
            name = r.getString("name");
            shield = r.getString("shield_url");
            phone = r.getString("phone");
            owner = r.getString("owner_name");
            status = r.getString("status");
        }
    }

    /** Datos visibles del torneo actual o de la edición más reciente. */
    public static final class Tournament {
        public final long id;
        public final String name, image, status, championName, championShield;
        public final LocalDate start, end;
        public final BigDecimal prize;
        public final Long championId;

        Tournament(ResultSet r) throws SQLException {
            id = r.getLong("id");
            name = r.getString("name");
            image = r.getString("image_url");
            status = r.getString("status");
            start = r.getDate("start_date").toLocalDate();
            end = r.getDate("end_date").toLocalDate();
            prize = r.getBigDecimal("prize_crc");
            long winner = r.getLong("champion_team_id");
            championId = r.wasNull() ? null : winner;
            championName = r.getString("champion_name");
            championShield = r.getString("champion_shield");
        }
    }

    /** Encuentro del cuadro: ocho octavos, cuatro cuartos, dos semis y final. */
    public static final class Match {
        public final long id, tournamentId;
        public final int round, position;
        public final Long aId, bId, winnerId;
        public final String aName, bName, aShield, bShield, status;
        public final Integer scoreA, scoreB;

        Match(ResultSet r) throws SQLException {
            id = r.getLong("id");
            tournamentId = r.getLong("tournament_id");
            round = r.getInt("round_no");
            position = r.getInt("match_no");
            aId = nullableLong(r, "team_a_id");
            bId = nullableLong(r, "team_b_id");
            winnerId = nullableLong(r, "winner_id");
            aName = r.getString("a_name");
            bName = r.getString("b_name");
            aShield = r.getString("a_shield");
            bShield = r.getString("b_shield");
            scoreA = nullableInt(r, "score_a");
            scoreB = nullableInt(r, "score_b");
            status = r.getString("status");
        }

        public boolean done() {
            return "FINALIZADO".equals(status);
        }
    }

    private static Long nullableLong(ResultSet rs, String col) throws SQLException {
        long value = rs.getLong(col);
        return rs.wasNull() ? null : value;
    }

    private static Integer nullableInt(ResultSet rs, String col) throws SQLException {
        int value = rs.getInt(col);
        return rs.wasNull() ? null : value;
    }

    /** Estado para renderizar la pantalla sin que cada JSP consulte MySQL. */
    public static final class State {
        public Tournament tournament;
        public final List<Team> teams = new ArrayList<>();
        public final List<Match> matches = new ArrayList<>();
        public final Set<Long> participantIds = new HashSet<>();
        public int approved, pending, finalized;

        public List<Match> round(int n) {
            List<Match> round = new ArrayList<>();
            for (Match m : matches) if (m.round == n) round.add(m);
            return round;
        }

        public List<Team> participants() {
            List<Team> list = new ArrayList<>();
            for (Team t : teams) if (participantIds.contains(t.id)) list.add(t);
            return list;
        }
    }

    /** Autentica a un usuario activo validando su hash PBKDF2; nunca se compara texto plano. */
    public static User login(String email, String password) throws SQLException {
        String sql =
                "SELECT id, full_name, email, role, password_hash FROM users WHERE email = ? AND"
                    + " active = 1";
        try (Connection c = DB.open();
                PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, email == null ? "" : email.trim().toLowerCase(Locale.ROOT));
            try (ResultSet r = p.executeQuery()) {
                if (r.next() && Passwords.verify(password, r.getString("password_hash"))) {
                    return new User(
                            r.getLong("id"),
                            r.getString("full_name"),
                            r.getString("email"),
                            r.getString("role"));
                }
            }
        }
        return null;
    }

    /** Registra una cuenta normal y aplica validaciones antes de guardar el hash. */
    public static void register(String name, String email, String password)
            throws SQLException, RuleException {
        name = name == null ? "" : name.trim().replaceAll("\\s+", " ");
        email = email == null ? "" : email.trim().toLowerCase(Locale.ROOT);
        if (name.length() < 3 || name.length() > 120)
            throw new RuleException("Ingresá un nombre completo de 3 a 120 caracteres.");
        if (email.length() > 190 || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"))
            throw new RuleException("Ingresá un correo electrónico válido.");
        if (password == null || password.length() < 8 || password.length() > 128)
            throw new RuleException("La contraseña debe contener entre 8 y 128 caracteres.");
        try (Connection c = DB.open();
                PreparedStatement p =
                        c.prepareStatement(
                                "INSERT INTO users (full_name, email, password_hash, role) VALUES"
                                    + " (?, ?, ?, 'USUARIO')")) {
            p.setString(1, name);
            p.setString(2, email);
            p.setString(3, Passwords.hash(password));
            try {
                p.executeUpdate();
            } catch (SQLIntegrityConstraintViolationException ex) {
                throw new RuleException("Ese correo ya tiene una cuenta registrada.");
            }
        }
    }

    /** Consulta la edición más reciente y reúne equipos, llaves y estado del torneo. */
    public static State load() throws SQLException {
        State s = new State();
        try (Connection c = DB.open()) {
            try (PreparedStatement p =
                            c.prepareStatement(
                                    "SELECT t.*, c.name champion_name, c.shield_url champion_shield"
                                        + " FROM tournaments t LEFT JOIN teams c ON"
                                        + " c.id=t.champion_team_id ORDER BY t.id DESC LIMIT 1");
                    ResultSet r = p.executeQuery()) {
                if (r.next()) s.tournament = new Tournament(r);
            }
            try (PreparedStatement p =
                            c.prepareStatement(
                                    "SELECT e.*, u.full_name owner_name FROM teams e JOIN users u"
                                        + " ON e.owner_id=u.id ORDER BY e.id DESC");
                    ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    Team team = new Team(r);
                    s.teams.add(team);
                    if ("APROBADO".equals(team.status)) s.approved++;
                    if ("PENDIENTE".equals(team.status)) s.pending++;
                }
            }
            if (s.tournament != null) {
                try (PreparedStatement p =
                        c.prepareStatement(
                                "SELECT team_id FROM tournament_teams WHERE tournament_id=?")) {
                    p.setLong(1, s.tournament.id);
                    try (ResultSet r = p.executeQuery()) {
                        while (r.next()) s.participantIds.add(r.getLong(1));
                    }
                }
                try (PreparedStatement p =
                        c.prepareStatement(
                                "SELECT m.*, a.name a_name, b.name b_name, a.shield_url a_shield,"
                                    + " b.shield_url b_shield FROM matches m LEFT JOIN teams a ON"
                                    + " a.id=m.team_a_id LEFT JOIN teams b ON b.id=m.team_b_id"
                                    + " WHERE m.tournament_id=? ORDER BY m.round_no, m.match_no")) {
                    p.setLong(1, s.tournament.id);
                    try (ResultSet r = p.executeQuery()) {
                        while (r.next()) {
                            Match match = new Match(r);
                            s.matches.add(match);
                            if (match.done()) s.finalized++;
                        }
                    }
                }
            }
        }
        return s;
    }

    /** Inscribe un equipo pendiente. El candado impide cambios durante un torneo activo. */
    public static void addTeam(User owner, String name, String phone, String shield)
            throws SQLException, RuleException {
        if (owner == null) throw new RuleException("Iniciá sesión para inscribir un equipo.");
        name = name == null ? "" : name.trim().replaceAll("\\s+", " ");
        phone = phone == null ? "" : phone.trim();
        shield = Web.requiredImage(shield);
        if (name.length() < 3 || name.length() > 100)
            throw new RuleException("El nombre del equipo debe tener entre 3 y 100 caracteres.");
        if (!phone.matches("^[+]?[0-9 ()-]{8,20}$"))
            throw new RuleException("Ingresá un número de teléfono válido.");
        try (Connection c = DB.open()) {
            c.setAutoCommit(false);
            try {
                lockCoordinator(c);
                try (PreparedStatement p =
                                c.prepareStatement(
                                        "SELECT id FROM tournaments WHERE status='ACTIVO' LIMIT 1"
                                            + " FOR UPDATE");
                        ResultSet r = p.executeQuery()) {
                    if (r.next())
                        throw new RuleException(
                                "Las inscripciones están cerradas durante un torneo activo.");
                }
                try (PreparedStatement p =
                        c.prepareStatement(
                                "INSERT INTO teams (name, shield_url, phone, owner_id) VALUES (?,"
                                    + " ?, ?, ?)")) {
                    p.setString(1, name);
                    p.setString(2, shield);
                    p.setString(3, phone);
                    p.setLong(4, owner.id);
                    try {
                        p.executeUpdate();
                    } catch (SQLIntegrityConstraintViolationException ex) {
                        throw new RuleException("Ya existe un equipo con ese nombre.");
                    }
                }
                c.commit();
            } catch (SQLException | RuleException e) {
                c.rollback();
                throw e;
            }
        }
    }

    /** Aprueba o rechaza con control transaccional del máximo de 16 aprobados. */
    public static void setApproval(long teamId, boolean approve)
            throws SQLException, RuleException {
        try (Connection c = DB.open()) {
            c.setAutoCommit(false);
            try {
                lockCoordinator(c);
                try (PreparedStatement p =
                                c.prepareStatement(
                                        "SELECT id FROM tournaments WHERE status='ACTIVO' LIMIT 1"
                                            + " FOR UPDATE");
                        ResultSet r = p.executeQuery()) {
                    if (r.next())
                        throw new RuleException(
                                "No se puede modificar la aprobación durante el torneo.");
                }
                String current = null;
                try (PreparedStatement p =
                        c.prepareStatement("SELECT status FROM teams WHERE id=? FOR UPDATE")) {
                    p.setLong(1, teamId);
                    try (ResultSet r = p.executeQuery()) {
                        if (r.next()) current = r.getString(1);
                    }
                }
                if (current == null) throw new RuleException("No se encontró el equipo.");
                if (approve) {
                    int count;
                    try (PreparedStatement p =
                                    c.prepareStatement(
                                            "SELECT COUNT(*) FROM teams WHERE status='APROBADO'");
                            ResultSet r = p.executeQuery()) {
                        r.next();
                        count = r.getInt(1);
                    }
                    if (!"APROBADO".equals(current) && count >= 16)
                        throw new RuleException(
                                "Solo pueden existir 16 equipos aprobados para el siguiente"
                                    + " torneo.");
                }
                try (PreparedStatement p =
                        c.prepareStatement("UPDATE teams SET status=? WHERE id=?")) {
                    p.setString(1, approve ? "APROBADO" : "RECHAZADO");
                    p.setLong(2, teamId);
                    p.executeUpdate();
                }
                c.commit();
            } catch (SQLException | RuleException e) {
                c.rollback();
                throw e;
            }
        }
    }

    /** Inicia una copa con exactamente 16 equipos aprobados y genera sus 15 partidos. */
    public static void createTournament(
            String name,
            String image,
            LocalDate start,
            LocalDate end,
            BigDecimal prize,
            Set<Long> selected)
            throws SQLException, RuleException {
        name = name == null ? "" : name.trim();
        image = Web.requiredImage(image);
        if (name.length() < 3 || name.length() > 140)
            throw new RuleException("Ingresá el nombre del torneo (3 a 140 caracteres).");
        if (start == null || end == null || end.isBefore(start))
            throw new RuleException("Revisá las fechas de inicio y fin.");
        if (prize == null
                || prize.signum() < 0
                || prize.scale() > 2
                || prize.compareTo(new BigDecimal("999999999999.99")) > 0)
            throw new RuleException("Ingresá un premio válido en colones.");
        if (selected == null || selected.size() != 16)
            throw new RuleException("Tenés que seleccionar exactamente 16 equipos.");
        try (Connection c = DB.open()) {
            c.setAutoCommit(false);
            try {
                lockCoordinator(c);
                try (PreparedStatement p =
                                c.prepareStatement(
                                        "SELECT id FROM tournaments WHERE status='ACTIVO' LIMIT 1"
                                            + " FOR UPDATE");
                        ResultSet r = p.executeQuery()) {
                    if (r.next()) throw new RuleException("Ya existe un torneo activo.");
                }
                Set<Long> approved = new HashSet<>();
                try (PreparedStatement p =
                                c.prepareStatement(
                                        "SELECT id FROM teams WHERE status='APROBADO' ORDER BY id"
                                            + " FOR UPDATE");
                        ResultSet r = p.executeQuery()) {
                    while (r.next()) approved.add(r.getLong(1));
                }
                if (approved.size() != 16 || !approved.equals(selected))
                    throw new RuleException(
                            "Debe haber exactamente 16 equipos aprobados y todos deben estar"
                                + " seleccionados.");
                long tournamentId;
                try (PreparedStatement p =
                        c.prepareStatement(
                                "INSERT INTO tournaments (name, image_url, start_date, end_date,"
                                    + " prize_crc, status, active_slot) VALUES (?, ?, ?, ?, ?,"
                                    + " 'ACTIVO', 1)",
                                Statement.RETURN_GENERATED_KEYS)) {
                    p.setString(1, name);
                    p.setString(2, image);
                    p.setDate(3, java.sql.Date.valueOf(start));
                    p.setDate(4, java.sql.Date.valueOf(end));
                    p.setBigDecimal(5, prize);
                    p.executeUpdate();
                    try (ResultSet r = p.getGeneratedKeys()) {
                        r.next();
                        tournamentId = r.getLong(1);
                    }
                }
                try (PreparedStatement p =
                        c.prepareStatement(
                                "INSERT INTO tournament_teams (tournament_id, team_id) VALUES (?,"
                                    + " ?)")) {
                    for (long id : approved) {
                        p.setLong(1, tournamentId);
                        p.setLong(2, id);
                        p.addBatch();
                    }
                    p.executeBatch();
                }
                List<Long> shuffled = new ArrayList<>(approved);
                Collections.shuffle(shuffled, RANDOM);
                try (PreparedStatement p =
                        c.prepareStatement(
                                "INSERT INTO matches (tournament_id, round_no, match_no, team_a_id,"
                                    + " team_b_id) VALUES (?, ?, ?, ?, ?)")) {
                    for (int round = 1; round <= 4; round++) {
                        for (int pos = 1; pos <= (16 >> round); pos++) {
                            p.setLong(1, tournamentId);
                            p.setInt(2, round);
                            p.setInt(3, pos);
                            if (round == 1) {
                                p.setLong(4, shuffled.get((pos - 1) * 2));
                                p.setLong(5, shuffled.get((pos - 1) * 2 + 1));
                            } else {
                                p.setNull(4, Types.BIGINT);
                                p.setNull(5, Types.BIGINT);
                            }
                            p.addBatch();
                        }
                    }
                    p.executeBatch();
                }
                c.commit();
            } catch (SQLException | RuleException | RuntimeException e) {
                c.rollback();
                throw e;
            }
        }
    }

    /** Orden natural de los 15 encuentros; sirve para navegar la simulación sin obligar a verla. */
    /** Busca el siguiente partido en el orden natural de las cuatro rondas. */
    public static Long nextMatchId(Match match) throws SQLException {
        try (Connection c = DB.open();
                PreparedStatement p =
                        c.prepareStatement(
                                "SELECT id FROM matches WHERE tournament_id=? AND "
                                        + "(round_no>? OR (round_no=? AND match_no>?)) "
                                        + "ORDER BY round_no,match_no LIMIT 1")) {
            p.setLong(1, match.tournamentId);
            p.setInt(2, match.round);
            p.setInt(3, match.round);
            p.setInt(4, match.position);
            try (ResultSet r = p.executeQuery()) {
                return r.next() ? Long.valueOf(r.getLong(1)) : null;
            }
        }
    }

    public static final class MatchDetail {
        public final Match match;
        public final MatchSimulation.Report report;

        MatchDetail(Match match, MatchSimulation.Report report) {
            this.match = match;
            this.report = report;
        }
    }

    /** Reportes públicos: disponibles para jugadores, visitantes y administradores. */
    /** Recupera un partido y su ficha; puede reconstruir reportes históricos. */
    public static MatchDetail loadMatchDetail(long matchId) throws SQLException {
        if (matchId <= 0) return null;
        try (Connection c = DB.open()) {
            c.setAutoCommit(false);
            try {
                Match match = null;
                try (PreparedStatement p =
                        c.prepareStatement(
                                "SELECT m.*, a.name a_name, b.name b_name, a.shield_url a_shield,"
                                    + " b.shield_url b_shield FROM matches m LEFT JOIN teams a ON"
                                    + " a.id=m.team_a_id LEFT JOIN teams b ON b.id=m.team_b_id"
                                    + " WHERE m.id=? FOR UPDATE")) {
                    p.setLong(1, matchId);
                    try (ResultSet r = p.executeQuery()) {
                        if (r.next()) match = new Match(r);
                    }
                }
                if (match == null) {
                    c.commit();
                    return null;
                }
                MatchSimulation.Report report = null;
                if (match.done()) {
                    report = MatchSimulation.read(c, matchId);
                    if (report == null) {
                        // Permite consultar partidos jugados antes de instalar esta mejora.
                        // El informe reconstruido se distingue explícitamente del registro
                        // original.
                        report =
                                MatchSimulation.generate(
                                        match.scoreA, match.scoreB, "RECONSTRUIDA");
                        MatchSimulation.save(c, matchId, report);
                    }
                }
                c.commit();
                return new MatchDetail(match, report);
            } catch (SQLException | RuntimeException ex) {
                c.rollback();
                throw ex;
            }
        }
    }

    /** Registra el marcador manual de manera atómica con el avance del ganador. */
    public static void recordScore(long matchId, int scoreA, int scoreB)
            throws SQLException, RuleException {
        try (Connection c = DB.open()) {
            c.setAutoCommit(false);
            try {
                finishMatch(c, matchId, scoreA, scoreB, "MANUAL");
                c.commit();
            } catch (SQLException | RuleException | RuntimeException ex) {
                c.rollback();
                throw ex;
            }
        }
    }

    /** El administrador simula un encuentro individual y registra su resultado automáticamente. */
    /** Genera un resultado ilustrativo para un único partido habilitado. */
    public static void simulateMatch(long matchId) throws SQLException, RuleException {
        try (Connection c = DB.open()) {
            c.setAutoCommit(false);
            try {
                int[] scores = randomScore();
                finishMatch(c, matchId, scores[0], scores[1], "AUTOMATICA");
                c.commit();
            } catch (SQLException | RuleException | RuntimeException ex) {
                c.rollback();
                throw ex;
            }
        }
    }

    /** Simula todos los encuentros restantes en orden y en una sola transacción. */
    /** Simula en orden todos los partidos pendientes y devuelve cuántos finalizó. */
    public static int simulateRemaining() throws SQLException, RuleException {
        try (Connection c = DB.open()) {
            c.setAutoCommit(false);
            try {
                lockCoordinator(c);
                int total = 0;
                while (true) {
                    Long matchId = null;
                    try (PreparedStatement p =
                            c.prepareStatement(
                                    "SELECT m.id FROM matches m JOIN tournaments t ON"
                                        + " t.id=m.tournament_id WHERE t.status='ACTIVO' AND"
                                        + " m.status='PENDIENTE' AND m.team_a_id IS NOT NULL AND"
                                        + " m.team_b_id IS NOT NULL ORDER BY m.round_no,m.match_no"
                                        + " LIMIT 1")) {
                        try (ResultSet r = p.executeQuery()) {
                            if (r.next()) matchId = r.getLong(1);
                        }
                    }
                    if (matchId == null) break;
                    int[] scores = randomScore();
                    finishMatch(c, matchId, scores[0], scores[1], "AUTOMATICA");
                    total++;
                    if (total > 15)
                        throw new SQLException("Se excedió el número máximo de partidos.");
                }
                if (total == 0)
                    throw new RuleException("No hay encuentros pendientes para simular.");
                c.commit();
                return total;
            } catch (SQLException | RuleException | RuntimeException ex) {
                c.rollback();
                throw ex;
            }
        }
    }

    /** Produce un marcador sin empate porque el formato es eliminación directa. */
    private static int[] randomScore() {
        int a = RANDOM.nextInt(5), b = RANDOM.nextInt(5);
        if (a == b) b = (b + 1) % 5;
        return new int[] {a, b};
    }

    /** Único punto de escritura de resultados, ya sean manuales o simulados. */
    private static void finishMatch(Connection c, long matchId, int scoreA, int scoreB, String mode)
            throws SQLException, RuleException {
        if (scoreA < 0 || scoreB < 0 || scoreA > 999 || scoreB > 999)
            throw new RuleException("Los marcadores deben estar entre 0 y 999.");
        if (scoreA == scoreB)
            throw new RuleException("Los empates no están permitidos en eliminación directa.");
        long tournamentId, teamA, teamB;
        int round, pos;
        String status;
        try (PreparedStatement p =
                c.prepareStatement("SELECT tournament_id FROM matches WHERE id=?")) {
            p.setLong(1, matchId);
            try (ResultSet r = p.executeQuery()) {
                if (!r.next()) throw new RuleException("El partido no existe.");
                tournamentId = r.getLong(1);
            }
        }
        try (PreparedStatement p =
                c.prepareStatement("SELECT status FROM tournaments WHERE id=? FOR UPDATE")) {
            p.setLong(1, tournamentId);
            try (ResultSet r = p.executeQuery()) {
                if (!r.next() || !"ACTIVO".equals(r.getString(1)))
                    throw new RuleException("El torneo no está activo.");
            }
        }
        try (PreparedStatement p =
                c.prepareStatement(
                        "SELECT round_no, match_no, team_a_id, team_b_id, status FROM matches WHERE"
                            + " id=? FOR UPDATE")) {
            p.setLong(1, matchId);
            try (ResultSet r = p.executeQuery()) {
                if (!r.next()) throw new RuleException("El partido no existe.");
                round = r.getInt(1);
                pos = r.getInt(2);
                teamA = r.getLong(3);
                boolean hasA = !r.wasNull();
                teamB = r.getLong(4);
                boolean hasB = !r.wasNull();
                status = r.getString(5);
                if (!hasA || !hasB)
                    throw new RuleException("El partido todavía no tiene ambos clasificados.");
                if (!"PENDIENTE".equals(status))
                    throw new RuleException(
                            "Este resultado ya fue registrado y no puede editarse.");
            }
        }
        long winner = scoreA > scoreB ? teamA : teamB;
        try (PreparedStatement p =
                c.prepareStatement(
                        "UPDATE matches SET score_a=?, score_b=?, winner_id=?, status='FINALIZADO',"
                            + " played_at=CURRENT_TIMESTAMP WHERE id=? AND status='PENDIENTE'")) {
            p.setInt(1, scoreA);
            p.setInt(2, scoreB);
            p.setLong(3, winner);
            p.setLong(4, matchId);
            if (p.executeUpdate() != 1) throw new RuleException("El resultado ya fue registrado.");
        }
        // La ficha del encuentro y su cronología se guardan atómicamente con el marcador.
        MatchSimulation.save(c, matchId, MatchSimulation.generate(scoreA, scoreB, mode));
        if (round == 4) {
            try (PreparedStatement p =
                    c.prepareStatement(
                            "UPDATE tournaments SET champion_team_id=?, status='FINALIZADO',"
                                + " active_slot=NULL WHERE id=? AND status='ACTIVO'")) {
                p.setLong(1, winner);
                p.setLong(2, tournamentId);
                if (p.executeUpdate() != 1)
                    throw new RuleException("No se pudo finalizar el torneo.");
            }
        } else {
            String slot = pos % 2 == 1 ? "team_a_id" : "team_b_id";
            String sql =
                    "UPDATE matches SET "
                            + slot
                            + "=? WHERE tournament_id=? AND round_no=? AND match_no=? AND "
                            + slot
                            + " IS NULL";
            try (PreparedStatement p = c.prepareStatement(sql)) {
                p.setLong(1, winner);
                p.setLong(2, tournamentId);
                p.setInt(3, round + 1);
                p.setInt(4, (pos + 1) / 2);
                if (p.executeUpdate() != 1)
                    throw new RuleException("El siguiente enfrentamiento no está disponible.");
            }
        }
    }
}
