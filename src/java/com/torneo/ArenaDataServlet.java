package com.torneo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.*;

/** Provee exclusivamente datos persistidos en MySQL para las vistas originales de Stitch. */
@WebServlet("/arena-data")
public final class ArenaDataServlet extends HttpServlet {
    private static Map<String,Object> obj(Object... pairs) {
        Map<String,Object> map = new LinkedHashMap<>();
        for (int i = 0; i < pairs.length; i += 2) map.put((String)pairs[i], pairs[i+1]);
        return map;
    }
    private static String safe(String s) { return s == null ? "" : s; }
    private static Map<String,Object> half(MatchSimulation.Half h) {
        return obj("period", h.number, "possessionA", h.possessionA, "possessionB", 100-h.possessionA,
            "passesA", h.passesA,"passesB", h.passesB,
            "shotsA",h.shotsA,"shotsB",h.shotsB,"onA",h.onA,"onB",h.onB,
            "dangerousA",h.dangerousA,"dangerousB",h.dangerousB,
            "cornersA",h.cornersA,"cornersB",h.cornersB,
            "foulsA",h.foulsA,"foulsB",h.foulsB,
            "goalsA",h.goalsA,"goalsB",h.goalsB);
    }
    private static void json(StringBuilder out,Object data) {
        if (data == null) { out.append("null"); return; }
        if (data instanceof Number || data instanceof Boolean) { out.append(data); return; }
        if (data instanceof Map<?,?> m) {
            out.append('{'); boolean first=true;
            for (Map.Entry<?,?> e : m.entrySet()) {
                if(!first)out.append(',');first=false;
                json(out,String.valueOf(e.getKey()));out.append(':');json(out,e.getValue());
            }out.append('}');return;
        }
        if (data instanceof Iterable<?> it) {
            out.append('[');boolean first=true;
            for(Object element:it){if(!first)out.append(',');first=false;json(out,element);}
            out.append(']');return;
        }
        out.append('"');
        for (char c : data.toString().toCharArray()) {
            switch(c) {
                case '"':out.append("\\\"");break;
                case '\\':out.append("\\\\");break;
                case '\n':out.append("\\n");break;
                case '\r':out.append("\\r");break;
                case '\t':out.append("\\t");break;
                case '<':out.append("\\u003c");break;
                case '>':out.append("\\u003e");break;
                case '&':out.append("\\u0026");break;
                default: if(c < 0x20 || c == 0x2028 || c == 0x2029)
                    out.append(String.format("\\u%04x",(int)c)); else out.append(c);
            }
        }
        out.append('"');
    }
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        res.setContentType("application/json;charset=UTF-8");
        res.setHeader("Cache-Control","no-store");
        try {
            Store.State s = Store.load();
            Store.User user = Web.user(req);
            List<Object> teams = new ArrayList<>(), matches = new ArrayList<>(), scorers = new ArrayList<>();
            Map<String,Map<String,Object>> scorerIndex = new HashMap<>();
            int totalGoals=0,totalFouls=0;
            for (Store.Team t : s.teams) {
                teams.add(obj("id",t.id,"name",t.name,"shield",safe(t.shield),"status",t.status,
                    "owner",t.owner,"phone",user != null && (user.admin() || user.id == t.ownerId) ? t.phone : "","participant",s.participantIds.contains(t.id)));
            }
            for (Store.Match m : s.matches) {
                Map<String,Object> match = obj("id",m.id,"round",m.round,"position",m.position,
                    "aId",m.aId,"bId",m.bId,"aName",safe(m.aName),"bName",safe(m.bName),
                    "aShield",safe(m.aShield),"bShield",safe(m.bShield),"scoreA",m.scoreA,
                    "scoreB",m.scoreB,"winnerId",m.winnerId,"done",m.done(),
                    "ready",!m.done() && m.aId!=null && m.bId!=null);
                if (m.done()) {
                    Store.MatchDetail detail=Store.loadMatchDetail(m.id);
                    MatchSimulation.Report report=detail.report;
                    if(report!=null) {
                        Map<String,Object> reportJson = obj("mode",report.mode,
                            "first",half(report.first),"second",half(report.second),"total",half(report.total()));
                        List<Object> events=new ArrayList<>();
                        for (MatchSimulation.Event e:report.events) {
                            Long teamId="A".equals(e.side) ? m.aId : m.bId;
                            String teamName="A".equals(e.side) ? safe(m.aName) : safe(m.bName);
                            events.add(obj("minute",e.minute,"type",e.type,"side",e.side,
                                "player",e.player,"outgoing",e.outgoing,"team",teamName));
                            if ("GOL".equals(e.type) && teamId != null) {
                                String key=teamId+"/"+e.player;
                                Map<String,Object> score=scorerIndex.get(key);
                                if (score==null) {
                                    score=obj("player",e.player,"team",teamName,"teamId",teamId,"goals",0,"matches",0);
                                    scorerIndex.put(key,score);
                                }
                                score.put("goals",((Number)score.get("goals")).intValue()+1);
                            }
                        }
                        reportJson.put("events",events);
                        match.put("report",reportJson);
                        totalGoals+=m.scoreA+m.scoreB;
                        totalFouls+=report.total().foulsA+report.total().foulsB;
                    }
                }
                matches.add(match);
            }
            for (Map<String,Object> score:scorerIndex.values()) {
                long teamId=((Number)score.get("teamId")).longValue();
                long games=s.matches.stream().filter(m -> m.done() && (Long.valueOf(teamId).equals(m.aId)||Long.valueOf(teamId).equals(m.bId))).count();
                score.put("matches",games);
                scorers.add(score);
            }
            scorers.sort((a,b)-> {
                Map<?,?> x=(Map<?,?>)a,y=(Map<?,?>)b;
                int cmp=Integer.compare(((Number)y.get("goals")).intValue(),((Number)x.get("goals")).intValue());
                return cmp != 0 ? cmp : String.valueOf(x.get("player")).compareTo(String.valueOf(y.get("player")));
            });
            Map<String,Object> tournament=null;
            if (s.tournament!=null) {
                Store.Tournament t=s.tournament;
                tournament=obj("id",t.id,"name",t.name,"image",safe(t.image),
                    "start",t.start.toString(),"end",t.end.toString(),
                    "prize",t.prize,"status",t.status,"championName",safe(t.championName),
                    "championId",t.championId,"championShield",safe(t.championShield));
            }
            Map<String,Object> currentUser=user==null?null:obj("id",user.id,"name",user.name,"role",user.role,"admin",user.admin());
            Map<String,Object> root=obj("ok",true,"year",2026,"tournament",tournament,"user",currentUser,
                "csrf",Web.token(req),"approved",s.approved,"pending",s.pending,
                "finalized",s.finalized,"totalMatches",15,"totalGoals",totalGoals,"totalFouls",totalFouls,
                "teams",teams,"matches",matches,"scorers",scorers,
                "discipline",obj("fouls",totalFouls,"yellow",null,"red",null,
                    "explanation","El sistema registra faltas simuladas, pero todavía no registra tarjetas amarillas o rojas."));
            StringBuilder json=new StringBuilder(19000);
            json(json,root);
            res.getWriter().write(json.toString());
        } catch(SQLException e) {
            log("Error preparando los datos del tablero de Stitch",e);
            res.setStatus(503);
            res.getWriter().write("{\"ok\":false,\"error\":\"No se pudo consultar MySQL. Verificá DB_URL, DB_USER y DB_PASSWORD.\"}");
        }
    }
}