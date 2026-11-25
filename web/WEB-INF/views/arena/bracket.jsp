<%--
  BRACKET ARENA / PANTALLA: Cuadro eliminatorio de dieciséis equipos y cuatro rondas.
  Origen: HTML y clases originales de Stitch aportados al proyecto.
  Los datos y permisos se actualizan mediante /arena-data y stitch-runtime.js.
  La maquetación exportada se conserva sin reindentación para no cambiar su aspecto.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html class="light" lang="es"><head><meta charset="utf-8"/><meta content="width=device-width, initial-scale=1.0" name="viewport"/><meta content="web_standard" name="shell-type"/><link href="https://fonts.googleapis.com" rel="preconnect"/><link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&amp;family=Space+Grotesk:wght@600;700&amp;display=swap" rel="preload" as="style" onload="this.onload=null;this.rel='stylesheet'"/><link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="preload" as="style" onload="this.onload=null;this.rel='stylesheet'"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="preload" as="style" onload="this.onload=null;this.rel='stylesheet'"/><style>@layer base{html,body{margin:0;padding:0;}body{overscroll-behavior:none;}main>:first-child{margin-top:0!important;}main>:last-child{margin-bottom:0!important;}}::-webkit-scrollbar{display:none;}</style><link href="<%=request.getContextPath()%>/css/stitch.css" rel="stylesheet"/><link href="<%=request.getContextPath()%>/css/stitch-bridge.css" rel="stylesheet"/></head><body class="bg-background font-body-md text-body-md text-on-surface antialiased arena-loading" data-arena-page="bracket"><div aria-busy="true" aria-label="Cargando datos del torneo" id="arena-skeleton">
<div class="ske-nav"><div class="ske-block" style="width:160px;height:28px"></div><div class="ske-block" style="width:300px;height:16px"></div><div class="ske-block" style="width:120px;height:25px"></div></div>
<div class="ske-hero"><div><div class="ske-block" style="width:110px;height:14px"></div><div class="ske-block" style="width:80%;height:52px"></div><div class="ske-block" style="width:66%;height:18px"></div><div class="ske-block" style="width:73%;height:18px"></div><div class="ske-block" style="width:45%;height:35px"></div></div><div class="ske-block ske-cover"></div></div>
<div class="ske-cards"><div class="ske-block"></div><div class="ske-block"></div><div class="ske-block"></div><div class="ske-block"></div></div>
<div class="ske-panel"><div class="ske-block" style="width:35%;height:25px"></div><div class="ske-block" style="height:120px"></div><div class="ske-block" style="height:24px;width:70%"></div></div>
<div class="ske-panel"><div class="ske-block" style="width:42%;height:25px"></div><div class="ske-cards"><div class="ske-block"></div><div class="ske-block"></div></div></div>
</div><noscript><p style="padding:2rem;background:#fef3c7;color:#111">La interfaz necesita JavaScript para consultar los datos del torneo. Activá JavaScript para continuar.</p></noscript><%@ include file="partials/header.jspf" %><main class="w-full pt-28 bg-background min-h-screen" data-arena-main=""><% if (request.getAttribute("flash") != null) { %><div class="arena-flash <%= "error".equals(request.getAttribute("flashKind")) ? "error" : "" %>" role="status"><%=com.torneo.Web.esc(String.valueOf(request.getAttribute("flash")))%></div><% } %><div class="flex flex-col w-full">
<!-- Sub-bar & Tournament Stage Breadcrumb -->
<div class="w-full bg-surface-container-low px-margin py-space-sm flex flex-wrap items-center justify-between gap-space-md">
<div class="flex items-center gap-space-sm">
<span class="font-label-sm text-label-sm uppercase px-2 py-0.5 rounded bg-tertiary-container text-on-tertiary">Fase Eliminatoria</span>
<span class="text-on-surface-variant font-label-sm text-label-sm">/</span>
<span class="font-headline-md text-headline-md text-on-surface tracking-tight uppercase">Gran Copa Nacional 2026 - Cuadro Simétrico Oficial</span>
<span class="px-2 py-0.5 rounded text-[10px] font-bold bg-secondary-container text-on-secondary-container tracking-wider uppercase">16 Equipos • Knockout Directo</span>
</div>
<div class="flex items-center gap-space-sm">
<div class="flex items-center gap-1.5 px-3 py-1 bg-surface rounded-lg shadow-sm">
<span class="w-2 h-2 rounded-full bg-secondary animate-pulse"></span>
<span class="font-label-sm text-label-sm text-on-surface uppercase tracking-wider">Premio Mayor: ₡ 5,000,000</span>
</div>
<button class="px-3 py-1 bg-surface-container hover:bg-surface-container-high rounded font-label-sm text-label-sm uppercase text-on-surface flex items-center gap-1 transition-colors" id="btn-export-bracket">
<span class="material-symbols-outlined text-[15px]">file_download</span>
        Exportar SVG
      </button>
</div>
</div>
<!-- Interactive Controls Hub -->
<div class="w-full bg-surface px-margin py-space-md shadow-sm z-30 sticky top-20">
<div class="flex flex-wrap items-center justify-between gap-space-md">
<!-- Search Competitor & Filter Stage -->
<div class="flex items-center flex-wrap gap-space-sm">
<div class="relative w-72">
<span class="material-symbols-outlined absolute left-3 top-2.5 text-on-surface-variant text-[18px]">search</span>
<input class="w-full bg-surface-container-low pl-9 pr-3 py-1.5 rounded text-on-surface font-body-md text-body-md focus:outline-none focus:bg-surface transition-all placeholder:text-on-surface-variant/60" id="bracket-search" placeholder="Buscar equipo (ej. Saprissa, Herediano)..." type="text"/>
<button class="hidden absolute right-2.5 top-2 text-on-surface-variant hover:text-on-surface" id="clear-search">
<span class="material-symbols-outlined text-[16px]">close</span>
</button>
</div>
<div class="flex items-center bg-surface-container-low p-1 rounded">
<button class="filter-btn active-filter px-3 py-1 rounded bg-primary text-on-primary font-label-sm text-label-sm uppercase transition-all" data-filter="all">Todos</button>
<button class="filter-btn px-3 py-1 rounded text-on-surface-variant hover:text-on-surface font-label-sm text-label-sm uppercase transition-all" data-filter="octavos">Octavos</button>
<button class="filter-btn px-3 py-1 rounded text-on-surface-variant hover:text-on-surface font-label-sm text-label-sm uppercase transition-all" data-filter="cuartos">Cuartos</button>
<button class="filter-btn px-3 py-1 rounded text-on-surface-variant hover:text-on-surface font-label-sm text-label-sm uppercase transition-all" data-filter="semis">Semis</button>
<button class="filter-btn px-3 py-1 rounded text-on-surface-variant hover:text-on-surface font-label-sm text-label-sm uppercase transition-all" data-filter="final">Final</button>
</div>
</div>
<!-- Action Toggles: Toggle Scores, Zoom, Center, Reset -->
<div class="flex items-center gap-space-sm">
<button class="flex items-center gap-1.5 px-3 py-1.5 rounded bg-surface-container-low hover:bg-surface-container-high font-label-sm text-label-sm uppercase text-on-surface transition-colors" id="toggle-scores">
<span class="material-symbols-outlined text-[16px] text-secondary">visibility</span>
<span id="scores-label">Ocultar Marcadores (Modo Spoiler)</span>
</button>
<div class="h-6 w-px bg-surface-container-highest"></div>
<div class="flex items-center bg-surface-container-low rounded p-0.5">
<button class="w-8 h-8 flex items-center justify-center text-on-surface hover:bg-surface-container rounded transition-colors" id="zoom-out" title="Alejar Zoom">
<span class="material-symbols-outlined text-[18px]">zoom_out</span>
</button>
<span class="font-label-sm text-label-sm px-2 text-on-surface min-w-[48px] text-center font-bold" id="zoom-level">100%</span>
<button class="w-8 h-8 flex items-center justify-center text-on-surface hover:bg-surface-container rounded transition-colors" id="zoom-in" title="Acercar Zoom">
<span class="material-symbols-outlined text-[18px]">zoom_in</span>
</button>
<button class="w-8 h-8 flex items-center justify-center text-on-surface hover:bg-surface-container rounded transition-colors ml-1" id="zoom-reset" title="Centrar Cuadro">
<span class="material-symbols-outlined text-[18px]">center_focus_strong</span>
</button>
</div>
</div>
</div>
</div>
<!-- Legend & Live Bracket Meta Header -->
<div class="w-full bg-surface-bright px-margin py-2 flex flex-wrap items-center justify-between text-on-surface-variant text-[11px] font-label-sm uppercase tracking-wider">
<div class="flex items-center gap-space-md">
<div class="flex items-center gap-1.5">
<div class="w-2.5 h-2.5 bg-secondary rounded-sm"></div>
<span>Ganador Avanza</span>
</div>
<div class="flex items-center gap-1.5">
<div class="w-2.5 h-2.5 bg-primary rounded-sm"></div>
<span>Encuentro Definido</span>
</div>
<div class="flex items-center gap-1.5">
<div class="w-2.5 h-2.5 bg-surface-container-highest rounded-sm"></div>
<span>Eliminado</span>
</div>
<div class="flex items-center gap-1.5">
<span class="w-2 h-2 rounded-full bg-error animate-ping"></span>
<span class="text-error font-bold">Tiempo Extra (TE)</span>
</div>
</div>
<div class="flex items-center gap-space-sm">
<span>Estadio Nacional de Costa Rica • Domingo 20:00 CST</span>
<span>•</span>
<span class="text-on-surface font-bold">Árbitro Central: Juan Gabriel Calderón</span>
</div>
</div>
<!-- Main Bracket Panoramic Canvas Wrapper -->
<div class="w-full overflow-x-auto overflow-y-hidden bg-background relative cursor-grab active:cursor-grabbing select-none" id="bracket-viewport" style="min-height: 860px;">
<!-- Zoomable Inner Container -->
<div class="min-w-[1580px] w-full p-8 transition-transform duration-200 ease-out origin-top-center flex flex-col justify-center" id="bracket-stage">
<!-- Column Labels Header (Symmetric 7 Columns) -->
<div class="grid grid-cols-7 gap-4 mb-4 text-center items-center">
<div class="col-stage bg-surface-container-high py-2 rounded">
<span class="font-headline-md text-[13px] uppercase tracking-wider text-on-surface font-bold">Octavos Izquierda</span>
<p class="font-label-sm text-[10px] text-on-surface-variant">Sábado 15 Mar</p>
</div>
<div class="col-stage bg-surface-container-high py-2 rounded">
<span class="font-headline-md text-[13px] uppercase tracking-wider text-on-surface font-bold">Cuartos Izquierda</span>
<p class="font-label-sm text-[10px] text-on-surface-variant">Miércoles 19 Mar</p>
</div>
<div class="col-stage bg-surface-container-high py-2 rounded">
<span class="font-headline-md text-[13px] uppercase tracking-wider text-on-surface font-bold">Semifinal A</span>
<p class="font-label-sm text-[10px] text-on-surface-variant">Sábado 22 Mar</p>
</div>
<div class="col-stage bg-tertiary-container py-2 rounded shadow-sm">
<span class="font-headline-md text-[13px] uppercase tracking-wider text-secondary-fixed font-bold flex items-center justify-center gap-1">
<span class="material-symbols-outlined text-[16px] text-secondary">emoji_events</span>
            GRAN FINAL
          </span>
<p class="font-label-sm text-[10px] text-on-tertiary-container">Domingo 30 Mar • 20:00 CST</p>
</div>
<div class="col-stage bg-surface-container-high py-2 rounded">
<span class="font-headline-md text-[13px] uppercase tracking-wider text-on-surface font-bold">Semifinal B</span>
<p class="font-label-sm text-[10px] text-on-surface-variant">Domingo 23 Mar</p>
</div>
<div class="col-stage bg-surface-container-high py-2 rounded">
<span class="font-headline-md text-[13px] uppercase tracking-wider text-on-surface font-bold">Cuartos Derecha</span>
<p class="font-label-sm text-[10px] text-on-surface-variant">Jueves 20 Mar</p>
</div>
<div class="col-stage bg-surface-container-high py-2 rounded">
<span class="font-headline-md text-[13px] uppercase tracking-wider text-on-surface font-bold">Octavos Derecha</span>
<p class="font-label-sm text-[10px] text-on-surface-variant">Domingo 16 Mar</p>
</div>
</div>
<!-- 7-COLUMN SYMMETRIC GRID WITH BRACKET CARDS -->
<div class="grid grid-cols-7 gap-4 items-stretch relative" style="min-height: 740px;">
<!-- ============================================== -->
<!-- COL 1: OCTAVOS IZQUIERDA (4 Enfrentamientos) -->
<!-- ============================================== -->
<div class="stage-col flex flex-col justify-around relative" data-stage="octavos">
<!-- Match OCT-L1 -->
<div class="match-card group relative bg-surface p-2.5 rounded shadow-sm hover:shadow-md transition-all cursor-pointer" data-date="Sáb 15 Mar • 15:00" data-match-id="M-OCT-L1" data-s1="3" data-s2="1" data-stadium="Estadio Ricardo Saprissa" data-stage="Octavos de Final" data-t1="Saprissa de Moravia" data-t2="Guadalupe Auriazul" data-winner="Saprissa de Moravia">
<div class="flex items-center justify-between pb-1.5 mb-1.5 bg-surface-container-low px-2 py-0.5 rounded">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant font-bold">PARTIDO 01 • FINAL</span>
<span class="font-label-sm text-[9px] text-secondary font-bold">#1 VS #16</span>
</div>
<!-- Team 1 (Winner) -->
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded bg-surface-container-high text-on-surface font-medium" data-team="Saprissa de Moravia">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-primary text-on-primary font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">1</span>
<span class="font-title-sm text-[13px] truncate font-bold text-on-surface">Saprissa de Moravia</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-secondary ml-2">3</span>
</div>
<!-- Team 2 -->
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded mt-1 text-on-surface-variant" data-team="Guadalupe Auriazul">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-surface-container-highest text-on-surface-variant font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">16</span>
<span class="font-title-sm text-[13px] truncate text-on-surface-variant">Guadalupe Auriazul</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-on-surface-variant ml-2">1</span>
</div>
<!-- Micro Action Indicator -->
<div class="mt-1 flex items-center justify-between text-[10px] text-on-surface-variant font-label-sm">
<span class="flex items-center gap-1 text-secondary"><span class="material-symbols-outlined text-[12px]">analytics</span> Ver Detalle</span>
<span>90'</span>
</div>
</div>
<!-- Match OCT-L2 -->
<div class="match-card group relative bg-surface p-2.5 rounded shadow-sm hover:shadow-md transition-all cursor-pointer" data-date="Sáb 15 Mar • 18:00" data-match-id="M-OCT-L2" data-s1="2" data-s2="0" data-stadium="Estadio José Rafael Fello Meza" data-stage="Octavos de Final" data-t1="Cartaginés Brumosos" data-t2="Sporting Capital" data-winner="Cartaginés Brumosos">
<div class="flex items-center justify-between pb-1.5 mb-1.5 bg-surface-container-low px-2 py-0.5 rounded">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant font-bold">PARTIDO 02 • FINAL</span>
<span class="font-label-sm text-[9px] text-secondary font-bold">#8 VS #9</span>
</div>
<!-- Team 1 (Winner) -->
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded bg-surface-container-high text-on-surface font-medium" data-team="Cartaginés Brumosos">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-primary text-on-primary font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">8</span>
<span class="font-title-sm text-[13px] truncate font-bold text-on-surface">Cartaginés Brumosos</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-secondary ml-2">2</span>
</div>
<!-- Team 2 -->
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded mt-1 text-on-surface-variant" data-team="Sporting Capital">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-surface-container-highest text-on-surface-variant font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">9</span>
<span class="font-title-sm text-[13px] truncate text-on-surface-variant">Sporting Capital</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-on-surface-variant ml-2">0</span>
</div>
<div class="mt-1 flex items-center justify-between text-[10px] text-on-surface-variant font-label-sm">
<span class="flex items-center gap-1 text-secondary"><span class="material-symbols-outlined text-[12px]">analytics</span> Ver Detalle</span>
<span>90'</span>
</div>
</div>
<!-- Match OCT-L3 -->
<div class="match-card group relative bg-surface p-2.5 rounded shadow-sm hover:shadow-md transition-all cursor-pointer" data-date="Sáb 15 Mar • 20:00" data-match-id="M-OCT-L3" data-s1="3" data-s2="2" data-stadium="Estadio Carlos Ugalde Álvarez" data-stage="Octavos de Final" data-t1="San Carlos Toros" data-t2="Liberia Pampa" data-winner="San Carlos Toros">
<div class="flex items-center justify-between pb-1.5 mb-1.5 bg-surface-container-low px-2 py-0.5 rounded">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant font-bold">PARTIDO 03 • T.E.</span>
<span class="font-label-sm text-[9px] text-secondary font-bold">#4 VS #13</span>
</div>
<!-- Team 1 (Winner) -->
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded bg-surface-container-high text-on-surface font-medium" data-team="San Carlos Toros">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-primary text-on-primary font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">4</span>
<span class="font-title-sm text-[13px] truncate font-bold text-on-surface">San Carlos Toros</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-secondary ml-2">3</span>
</div>
<!-- Team 2 -->
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded mt-1 text-on-surface-variant" data-team="Liberia Pampa">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-surface-container-highest text-on-surface-variant font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">13</span>
<span class="font-title-sm text-[13px] truncate text-on-surface-variant">Liberia Pampa</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-on-surface-variant ml-2">2</span>
</div>
<div class="mt-1 flex items-center justify-between text-[10px] text-on-surface-variant font-label-sm">
<span class="flex items-center gap-1 text-secondary"><span class="material-symbols-outlined text-[12px]">analytics</span> Ver Detalle</span>
<span class="text-error font-bold">120' T.E.</span>
</div>
</div>
<!-- Match OCT-L4 -->
<div class="match-card group relative bg-surface p-2.5 rounded shadow-sm hover:shadow-md transition-all cursor-pointer" data-date="Dom 16 Mar • 11:00" data-match-id="M-OCT-L4" data-s1="2" data-s2="1" data-stadium="Estadio Municipal Pérez Zeledón" data-stage="Octavos de Final" data-t1="Pérez Zeledón Guerreros" data-t2="Carmelita Carmelo" data-winner="Pérez Zeledón Guerreros">
<div class="flex items-center justify-between pb-1.5 mb-1.5 bg-surface-container-low px-2 py-0.5 rounded">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant font-bold">PARTIDO 04 • FINAL</span>
<span class="font-label-sm text-[9px] text-secondary font-bold">#5 VS #12</span>
</div>
<!-- Team 1 (Winner) -->
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded bg-surface-container-high text-on-surface font-medium" data-team="Pérez Zeledón Guerreros">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-primary text-on-primary font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">5</span>
<span class="font-title-sm text-[13px] truncate font-bold text-on-surface">Pérez Zeledón Guerreros</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-secondary ml-2">2</span>
</div>
<!-- Team 2 -->
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded mt-1 text-on-surface-variant" data-team="Carmelita Carmelo">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-surface-container-highest text-on-surface-variant font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">12</span>
<span class="font-title-sm text-[13px] truncate text-on-surface-variant">Carmelita Carmelo</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-on-surface-variant ml-2">1</span>
</div>
<div class="mt-1 flex items-center justify-between text-[10px] text-on-surface-variant font-label-sm">
<span class="flex items-center gap-1 text-secondary"><span class="material-symbols-outlined text-[12px]">analytics</span> Ver Detalle</span>
<span>90'</span>
</div>
</div>
</div>
<!-- ============================================== -->
<!-- COL 2: CUARTOS IZQUIERDA (2 Enfrentamientos) -->
<!-- ============================================== -->
<div class="stage-col flex flex-col justify-around relative" data-stage="cuartos">
<!-- Connector lines from Octavos to Cuartos Left -->
<!-- Match QF-L1 -->
<div class="match-card group relative bg-surface p-2.5 rounded shadow-sm hover:shadow-md transition-all cursor-pointer" data-date="Mié 19 Mar • 19:00" data-match-id="M-QF-L1" data-s1="2" data-s2="1" data-stadium="Estadio Ricardo Saprissa" data-stage="Cuartos de Final" data-t1="Saprissa de Moravia" data-t2="Cartaginés Brumosos" data-winner="Saprissa de Moravia">
<div class="flex items-center justify-between pb-1.5 mb-1.5 bg-surface-container-low px-2 py-0.5 rounded">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant font-bold">CUARTO 1 • FINAL</span>
<span class="font-label-sm text-[9px] text-secondary font-bold">C-IZQ</span>
</div>
<!-- Winner -->
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded bg-surface-container-high text-on-surface font-medium" data-team="Saprissa de Moravia">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-primary text-on-primary font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">1</span>
<span class="font-title-sm text-[13px] truncate font-bold text-on-surface">Saprissa de Moravia</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-secondary ml-2">2</span>
</div>
<!-- Runner Up -->
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded mt-1 text-on-surface-variant" data-team="Cartaginés Brumosos">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-surface-container-highest text-on-surface-variant font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">8</span>
<span class="font-title-sm text-[13px] truncate text-on-surface-variant">Cartaginés Brumosos</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-on-surface-variant ml-2">1</span>
</div>
<div class="mt-1 flex items-center justify-between text-[10px] text-on-surface-variant font-label-sm">
<span class="flex items-center gap-1 text-secondary"><span class="material-symbols-outlined text-[12px]">analytics</span> Ver Detalle</span>
<span>90'</span>
</div>
</div>
<!-- Match QF-L2 -->
<div class="match-card group relative bg-surface p-2.5 rounded shadow-sm hover:shadow-md transition-all cursor-pointer" data-date="Mié 19 Mar • 21:00" data-match-id="M-QF-L2" data-s1="3" data-s2="1" data-stadium="Estadio Carlos Ugalde" data-stage="Cuartos de Final" data-t1="San Carlos Toros" data-t2="Pérez Zeledón Guerreros" data-winner="San Carlos Toros">
<div class="flex items-center justify-between pb-1.5 mb-1.5 bg-surface-container-low px-2 py-0.5 rounded">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant font-bold">CUARTO 2 • FINAL</span>
<span class="font-label-sm text-[9px] text-secondary font-bold">C-IZQ</span>
</div>
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded bg-surface-container-high text-on-surface font-medium" data-team="San Carlos Toros">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-primary text-on-primary font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">4</span>
<span class="font-title-sm text-[13px] truncate font-bold text-on-surface">San Carlos Toros</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-secondary ml-2">3</span>
</div>
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded mt-1 text-on-surface-variant" data-team="Pérez Zeledón Guerreros">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-surface-container-highest text-on-surface-variant font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">5</span>
<span class="font-title-sm text-[13px] truncate text-on-surface-variant">Pérez Zeledón Guerreros</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-on-surface-variant ml-2">1</span>
</div>
<div class="mt-1 flex items-center justify-between text-[10px] text-on-surface-variant font-label-sm">
<span class="flex items-center gap-1 text-secondary"><span class="material-symbols-outlined text-[12px]">analytics</span> Ver Detalle</span>
<span>90'</span>
</div>
</div>
</div>
<!-- ============================================== -->
<!-- COL 3: SEMIFINAL A (1 Enfrentamiento) -->
<!-- ============================================== -->
<div class="stage-col flex flex-col justify-center relative" data-stage="semis">
<div class="match-card group relative bg-surface p-3 rounded shadow-md hover:shadow-xl transition-all cursor-pointer ring-1 ring-secondary/20" data-date="Sáb 22 Mar • 20:00" data-match-id="M-SF-A" data-s1="2" data-s2="1" data-stadium="Estadio Nacional" data-stage="Semifinal Oficial A" data-t1="Saprissa de Moravia" data-t2="San Carlos Toros" data-winner="Saprissa de Moravia">
<div class="flex items-center justify-between pb-1.5 mb-1.5 bg-surface-container-low px-2 py-1 rounded">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant font-bold">SEMIFINAL A • FINAL</span>
<span class="font-label-sm text-[9px] text-secondary font-bold flex items-center gap-1">
<span class="w-1.5 h-1.5 rounded-full bg-secondary"></span>PASO A LA FINAL
              </span>
</div>
<div class="team-row flex items-center justify-between py-2 px-2.5 rounded bg-surface-container-high text-on-surface font-medium" data-team="Saprissa de Moravia">
<div class="flex items-center gap-2 min-w-0">
<span class="w-5 h-5 rounded-full bg-primary text-on-primary font-label-sm text-[10px] flex items-center justify-center font-bold shrink-0">1</span>
<span class="font-title-sm text-[14px] truncate font-bold text-on-surface">Saprissa de Moravia</span>
</div>
<span class="score-pill font-headline-md text-[16px] font-bold text-secondary ml-2">2</span>
</div>
<div class="team-row flex items-center justify-between py-2 px-2.5 rounded mt-1.5 text-on-surface-variant" data-team="San Carlos Toros">
<div class="flex items-center gap-2 min-w-0">
<span class="w-5 h-5 rounded-full bg-surface-container-highest text-on-surface-variant font-label-sm text-[10px] flex items-center justify-center font-bold shrink-0">4</span>
<span class="font-title-sm text-[14px] truncate text-on-surface-variant">San Carlos Toros</span>
</div>
<span class="score-pill font-headline-md text-[16px] font-bold text-on-surface-variant ml-2">1</span>
</div>
<div class="mt-2 pt-2 bg-surface-container-lowest flex items-center justify-between text-[10px] text-on-surface-variant font-label-sm rounded px-1.5">
<span class="flex items-center gap-1 text-secondary font-bold"><span class="material-symbols-outlined text-[13px]">sports_soccer</span> Saprissa Clasificado</span>
<span>Asistencia: 28,450</span>
</div>
</div>
</div>
<!-- ============================================== -->
<!-- COL 4: CENTRO - GRAN FINAL & TROFEO OFICIAL -->
<!-- ============================================== -->
<div class="stage-col flex flex-col items-center justify-center relative px-1" data-stage="final">
<!-- Finalist A (Top Finalist Box) -->
<div class="w-full bg-surface-container-low p-2 rounded mb-3 text-center shadow-sm">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant">Finalista Conferencia Oeste</span>
<div class="font-headline-md text-[14px] text-on-surface font-bold mt-0.5 truncate">Saprissa de Moravia</div>
</div>
<!-- THE TROPHY MONOLITH PEDESTAL -->
<div class="relative w-full max-w-[210px] flex flex-col items-center py-4 px-3 rounded-lg bg-gradient-to-b from-surface via-surface-container-low to-surface-container shadow-xl overflow-hidden group">
<!-- Subtle Gold Glow Background -->
<div class="absolute -top-12 left-1/2 -translate-x-1/2 w-32 h-32 bg-secondary/15 rounded-full blur-2xl pointer-events-none"></div>
<!-- Crown / Ribbon Header -->
<div class="px-2.5 py-0.5 rounded-full bg-secondary-container text-on-secondary-container font-label-sm text-[9px] font-bold uppercase tracking-wider mb-2 flex items-center gap-1 shadow-sm">
<span class="material-symbols-outlined text-[12px] text-secondary">military_tech</span>
              Copa Premier 2026
            </div>
<!-- Realistic Trophy Graphic (SVG) -->
<div class="relative my-2 transform group-hover:scale-105 transition-transform duration-300">
<svg class="w-20 h-24 text-secondary drop-shadow-[0_4px_12px_rgba(217,119,6,0.35)]" fill="currentColor" viewbox="0 0 24 24">
<path d="M19 4h-3V2H8v2H5c-1.1 0-2 .9-2 2v2c0 2.55 1.92 4.63 4.39 4.94.63 1.5 1.98 2.63 3.61 2.96V19H8v2h8v-2h-3v-3.1c1.63-.33 2.98-1.46 3.61-2.96C19.08 12.63 21 10.55 21 8V6c0-1.1-.9-2-2-2zM5 8V6h3v4.82C6.18 10.4 5 9.35 5 8zm14 0c0 1.35-1.18 2.4-3 2.82V6h3v2z"></path>
</svg>
</div>
<!-- Gran Final Championship Match Card -->
<div class="w-full bg-surface p-2.5 rounded shadow-sm hover:shadow-md transition-all cursor-pointer mt-1" data-date="Dom 30 Mar • 20:00 CST" data-match-id="M-GRAND-FINAL" data-s1="2" data-s2="1" data-stadium="Estadio Nacional La Sabana" data-stage="Gran Final Nacional" data-t1="Saprissa de Moravia" data-t2="Alajuelense Manudos" data-winner="Saprissa de Moravia">
<div class="flex items-center justify-between text-[9px] font-label-sm text-secondary font-bold uppercase mb-1">
<span>GRAN FINAL</span>
<span class="px-1 py-0.2 bg-secondary/10 rounded">EN VIVO</span>
</div>
<!-- Team Final A -->
<div class="flex items-center justify-between py-1 px-1.5 rounded bg-surface-container-high text-on-surface">
<span class="font-title-sm text-[12px] truncate font-bold text-on-surface">Saprissa</span>
<span class="score-pill font-headline-md text-[13px] font-bold text-secondary">2</span>
</div>
<!-- Team Final B -->
<div class="flex items-center justify-between py-1 px-1.5 rounded mt-1 bg-surface-container-lowest text-on-surface">
<span class="font-title-sm text-[12px] truncate font-medium text-on-surface">Alajuelense</span>
<span class="score-pill font-headline-md text-[13px] font-bold text-on-surface-variant">1</span>
</div>
<button class="w-full mt-2 py-1 bg-primary hover:bg-tertiary text-on-primary font-label-sm text-[10px] uppercase rounded flex items-center justify-center gap-1 transition-colors">
<span class="material-symbols-outlined text-[13px]">military_tech</span> Detalle Final
              </button>
</div>
<!-- Pedestal Base Stand -->
<div class="w-3/4 h-2 bg-gradient-to-r from-surface-container-highest via-secondary to-surface-container-highest mt-3 rounded-full opacity-60"></div>
</div>
<!-- Finalist B (Bottom Finalist Box) -->
<div class="w-full bg-surface-container-low p-2 rounded mt-3 text-center shadow-sm">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant">Finalista Conferencia Este</span>
<div class="font-headline-md text-[14px] text-on-surface font-bold mt-0.5 truncate">Alajuelense Manudos</div>
</div>
</div>
<!-- ============================================== -->
<!-- COL 5: SEMIFINAL B (1 Enfrentamiento) -->
<!-- ============================================== -->
<div class="stage-col flex flex-col justify-center relative" data-stage="semis">
<div class="match-card group relative bg-surface p-3 rounded shadow-md hover:shadow-xl transition-all cursor-pointer ring-1 ring-secondary/20" data-date="Dom 23 Mar • 19:30" data-match-id="M-SF-B" data-s1="2" data-s2="0" data-stadium="Estadio Alejandro Morera Soto" data-stage="Semifinal Oficial B" data-t1="Alajuelense Manudos" data-t2="Herediano Centenario" data-winner="Alajuelense Manudos">
<div class="flex items-center justify-between pb-1.5 mb-1.5 bg-surface-container-low px-2 py-1 rounded">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant font-bold">SEMIFINAL B • FINAL</span>
<span class="font-label-sm text-[9px] text-secondary font-bold flex items-center gap-1">
<span class="w-1.5 h-1.5 rounded-full bg-secondary"></span>PASO A LA FINAL
              </span>
</div>
<div class="team-row flex items-center justify-between py-2 px-2.5 rounded bg-surface-container-high text-on-surface font-medium" data-team="Alajuelense Manudos">
<div class="flex items-center gap-2 min-w-0">
<span class="w-5 h-5 rounded-full bg-primary text-on-primary font-label-sm text-[10px] flex items-center justify-center font-bold shrink-0">2</span>
<span class="font-title-sm text-[14px] truncate font-bold text-on-surface">Alajuelense Manudos</span>
</div>
<span class="score-pill font-headline-md text-[16px] font-bold text-secondary ml-2">2</span>
</div>
<div class="team-row flex items-center justify-between py-2 px-2.5 rounded mt-1.5 text-on-surface-variant" data-team="Herediano Centenario">
<div class="flex items-center gap-2 min-w-0">
<span class="w-5 h-5 rounded-full bg-surface-container-highest text-on-surface-variant font-label-sm text-[10px] flex items-center justify-center font-bold shrink-0">3</span>
<span class="font-title-sm text-[14px] truncate text-on-surface-variant">Herediano Centenario</span>
</div>
<span class="score-pill font-headline-md text-[16px] font-bold text-on-surface-variant ml-2">0</span>
</div>
<div class="mt-2 pt-2 bg-surface-container-lowest flex items-center justify-between text-[10px] text-on-surface-variant font-label-sm rounded px-1.5">
<span class="flex items-center gap-1 text-secondary font-bold"><span class="material-symbols-outlined text-[13px]">sports_soccer</span> Alajuelense Clasificado</span>
<span>Asistencia: 19,800</span>
</div>
</div>
</div>
<!-- ============================================== -->
<!-- COL 6: CUARTOS DERECHA (2 Enfrentamientos) -->
<!-- ============================================== -->
<div class="stage-col flex flex-col justify-around relative" data-stage="cuartos">
<!-- Match QF-R1 -->
<div class="match-card group relative bg-surface p-2.5 rounded shadow-sm hover:shadow-md transition-all cursor-pointer" data-date="Jue 20 Mar • 19:00" data-match-id="M-QF-R1" data-s1="4" data-s2="1" data-stadium="Estadio Alejandro Morera Soto" data-stage="Cuartos de Final" data-t1="Alajuelense Manudos" data-t2="Santos de Guápiles" data-winner="Alajuelense Manudos">
<div class="flex items-center justify-between pb-1.5 mb-1.5 bg-surface-container-low px-2 py-0.5 rounded">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant font-bold">CUARTO 3 • FINAL</span>
<span class="font-label-sm text-[9px] text-secondary font-bold">C-DER</span>
</div>
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded bg-surface-container-high text-on-surface font-medium" data-team="Alajuelense Manudos">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-primary text-on-primary font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">2</span>
<span class="font-title-sm text-[13px] truncate font-bold text-on-surface">Alajuelense Manudos</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-secondary ml-2">4</span>
</div>
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded mt-1 text-on-surface-variant" data-team="Santos de Guápiles">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-surface-container-highest text-on-surface-variant font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">7</span>
<span class="font-title-sm text-[13px] truncate text-on-surface-variant">Santos de Guápiles</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-on-surface-variant ml-2">1</span>
</div>
<div class="mt-1 flex items-center justify-between text-[10px] text-on-surface-variant font-label-sm">
<span class="flex items-center gap-1 text-secondary"><span class="material-symbols-outlined text-[12px]">analytics</span> Ver Detalle</span>
<span>90'</span>
</div>
</div>
<!-- Match QF-R2 -->
<div class="match-card group relative bg-surface p-2.5 rounded shadow-sm hover:shadow-md transition-all cursor-pointer" data-date="Jue 20 Mar • 21:00" data-match-id="M-QF-R2" data-s1="2" data-s2="1" data-stadium="Estadio Eladio Rosabal Cordero" data-stage="Cuartos de Final" data-t1="Herediano Centenario" data-t2="Puntarenas Tiburones" data-winner="Herediano Centenario">
<div class="flex items-center justify-between pb-1.5 mb-1.5 bg-surface-container-low px-2 py-0.5 rounded">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant font-bold">CUARTO 4 • FINAL</span>
<span class="font-label-sm text-[9px] text-secondary font-bold">C-DER</span>
</div>
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded bg-surface-container-high text-on-surface font-medium" data-team="Herediano Centenario">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-primary text-on-primary font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">3</span>
<span class="font-title-sm text-[13px] truncate font-bold text-on-surface">Herediano Centenario</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-secondary ml-2">2</span>
</div>
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded mt-1 text-on-surface-variant" data-team="Puntarenas Tiburones">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-surface-container-highest text-on-surface-variant font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">6</span>
<span class="font-title-sm text-[13px] truncate text-on-surface-variant">Puntarenas Tiburones</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-on-surface-variant ml-2">1</span>
</div>
<div class="mt-1 flex items-center justify-between text-[10px] text-on-surface-variant font-label-sm">
<span class="flex items-center gap-1 text-secondary"><span class="material-symbols-outlined text-[12px]">analytics</span> Ver Detalle</span>
<span>90'</span>
</div>
</div>
</div>
<!-- ============================================== -->
<!-- COL 7: OCTAVOS DERECHA (4 Enfrentamientos) -->
<!-- ============================================== -->
<div class="stage-col flex flex-col justify-around relative" data-stage="octavos">
<!-- Match OCT-R1 -->
<div class="match-card group relative bg-surface p-2.5 rounded shadow-sm hover:shadow-md transition-all cursor-pointer" data-date="Dom 16 Mar • 15:00" data-match-id="M-OCT-R1" data-s1="4" data-s2="0" data-stadium="Estadio Alejandro Morera Soto" data-stage="Octavos de Final" data-t1="Alajuelense Manudos" data-t2="Grecia Panteras" data-winner="Alajuelense Manudos">
<div class="flex items-center justify-between pb-1.5 mb-1.5 bg-surface-container-low px-2 py-0.5 rounded">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant font-bold">PARTIDO 05 • FINAL</span>
<span class="font-label-sm text-[9px] text-secondary font-bold">#2 VS #15</span>
</div>
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded bg-surface-container-high text-on-surface font-medium" data-team="Alajuelense Manudos">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-primary text-on-primary font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">2</span>
<span class="font-title-sm text-[13px] truncate font-bold text-on-surface">Alajuelense Manudos</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-secondary ml-2">4</span>
</div>
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded mt-1 text-on-surface-variant" data-team="Grecia Panteras">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-surface-container-highest text-on-surface-variant font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">15</span>
<span class="font-title-sm text-[13px] truncate text-on-surface-variant">Grecia Panteras</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-on-surface-variant ml-2">0</span>
</div>
<div class="mt-1 flex items-center justify-between text-[10px] text-on-surface-variant font-label-sm">
<span class="flex items-center gap-1 text-secondary"><span class="material-symbols-outlined text-[12px]">analytics</span> Ver Detalle</span>
<span>90'</span>
</div>
</div>
<!-- Match OCT-R2 -->
<div class="match-card group relative bg-surface p-2.5 rounded shadow-sm hover:shadow-md transition-all cursor-pointer" data-date="Dom 16 Mar • 17:00" data-match-id="M-OCT-R2" data-s1="1 (4)" data-s2="1 (2)" data-stadium="Estadio Ebal Rodríguez" data-stage="Octavos de Final" data-t1="Santos de Guápiles" data-t2="Santa Ana FC" data-winner="Santos de Guápiles">
<div class="flex items-center justify-between pb-1.5 mb-1.5 bg-surface-container-low px-2 py-0.5 rounded">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant font-bold">PARTIDO 06 • PEN</span>
<span class="font-label-sm text-[9px] text-secondary font-bold">#7 VS #10</span>
</div>
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded bg-surface-container-high text-on-surface font-medium" data-team="Santos de Guápiles">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-primary text-on-primary font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">7</span>
<span class="font-title-sm text-[13px] truncate font-bold text-on-surface">Santos de Guápiles</span>
</div>
<span class="score-pill font-headline-md text-[13px] font-bold text-secondary ml-2">1 (4)</span>
</div>
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded mt-1 text-on-surface-variant" data-team="Santa Ana FC">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-surface-container-highest text-on-surface-variant font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">10</span>
<span class="font-title-sm text-[13px] truncate text-on-surface-variant">Santa Ana FC</span>
</div>
<span class="score-pill font-headline-md text-[13px] font-bold text-on-surface-variant ml-2">1 (2)</span>
</div>
<div class="mt-1 flex items-center justify-between text-[10px] text-on-surface-variant font-label-sm">
<span class="flex items-center gap-1 text-secondary"><span class="material-symbols-outlined text-[12px]">analytics</span> Ver Detalle</span>
<span class="text-secondary font-bold">PENALTIS</span>
</div>
</div>
<!-- Match OCT-R3 -->
<div class="match-card group relative bg-surface p-2.5 rounded shadow-sm hover:shadow-md transition-all cursor-pointer" data-date="Dom 16 Mar • 19:00" data-match-id="M-OCT-R3" data-s1="3" data-s2="0" data-stadium="Estadio Eladio Rosabal" data-stage="Octavos de Final" data-t1="Herediano Centenario" data-t2="Uruguay de Coronado" data-winner="Herediano Centenario">
<div class="flex items-center justify-between pb-1.5 mb-1.5 bg-surface-container-low px-2 py-0.5 rounded">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant font-bold">PARTIDO 07 • FINAL</span>
<span class="font-label-sm text-[9px] text-secondary font-bold">#3 VS #14</span>
</div>
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded bg-surface-container-high text-on-surface font-medium" data-team="Herediano Centenario">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-primary text-on-primary font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">3</span>
<span class="font-title-sm text-[13px] truncate font-bold text-on-surface">Herediano Centenario</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-secondary ml-2">3</span>
</div>
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded mt-1 text-on-surface-variant" data-team="Uruguay de Coronado">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-surface-container-highest text-on-surface-variant font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">14</span>
<span class="font-title-sm text-[13px] truncate text-on-surface-variant">Uruguay Coronado</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-on-surface-variant ml-2">0</span>
</div>
<div class="mt-1 flex items-center justify-between text-[10px] text-on-surface-variant font-label-sm">
<span class="flex items-center gap-1 text-secondary"><span class="material-symbols-outlined text-[12px]">analytics</span> Ver Detalle</span>
<span>90'</span>
</div>
</div>
<!-- Match OCT-R4 -->
<div class="match-card group relative bg-surface p-2.5 rounded shadow-sm hover:shadow-md transition-all cursor-pointer" data-date="Dom 16 Mar • 21:00" data-match-id="M-OCT-R4" data-s1="2" data-s2="1" data-stadium="Estadio Lito Pérez" data-stage="Octavos de Final" data-t1="Puntarenas Tiburones" data-t2="Escorpiones de Belén" data-winner="Puntarenas Tiburones">
<div class="flex items-center justify-between pb-1.5 mb-1.5 bg-surface-container-low px-2 py-0.5 rounded">
<span class="font-label-sm text-[9px] uppercase tracking-widest text-on-surface-variant font-bold">PARTIDO 08 • FINAL</span>
<span class="font-label-sm text-[9px] text-secondary font-bold">#6 VS #11</span>
</div>
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded bg-surface-container-high text-on-surface font-medium" data-team="Puntarenas Tiburones">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-primary text-on-primary font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">6</span>
<span class="font-title-sm text-[13px] truncate font-bold text-on-surface">Puntarenas Tiburones</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-secondary ml-2">2</span>
</div>
<div class="team-row flex items-center justify-between py-1.5 px-2 rounded mt-1 text-on-surface-variant" data-team="Escorpiones de Belén">
<div class="flex items-center gap-2 min-w-0">
<span class="w-4 h-4 rounded-full bg-surface-container-highest text-on-surface-variant font-label-sm text-[9px] flex items-center justify-center font-bold shrink-0">11</span>
<span class="font-title-sm text-[13px] truncate text-on-surface-variant">Escorpiones Belén</span>
</div>
<span class="score-pill font-headline-md text-[14px] font-bold text-on-surface-variant ml-2">1</span>
</div>
<div class="mt-1 flex items-center justify-between text-[10px] text-on-surface-variant font-label-sm">
<span class="flex items-center gap-1 text-secondary"><span class="material-symbols-outlined text-[12px]">analytics</span> Ver Detalle</span>
<span>90'</span>
</div>
</div>
</div>
</div>
</div>
</div>
<!-- Bottom Quick Stats Strip -->
<div class="w-full bg-surface px-margin py-space-md shadow-sm">
<div class="grid grid-cols-2 md:grid-cols-4 gap-space-md text-center">
<div class="bg-surface-container-low p-space-sm rounded">
<div class="font-label-sm text-label-sm text-on-surface-variant uppercase">Goles Anotados</div>
<div class="font-headline-lg text-headline-lg text-primary font-bold">34</div>
<div class="font-body-sm text-body-sm text-on-surface-variant">Promedio 2.43 / partido</div>
</div>
<div class="bg-surface-container-low p-space-sm rounded">
<div class="font-label-sm text-label-sm text-on-surface-variant uppercase">Eficacia en Penal</div>
<div class="font-headline-lg text-headline-lg text-secondary font-bold">85.7%</div>
<div class="font-body-sm text-body-sm text-on-surface-variant">1 Definición desde los 11m</div>
</div>
<div class="bg-surface-container-low p-space-sm rounded">
<div class="font-label-sm text-label-sm text-on-surface-variant uppercase">Mayor Goleador</div>
<div class="font-headline-md text-headline-md text-primary font-bold truncate">Mariano Torres (Saprissa)</div>
<div class="font-body-sm text-body-sm text-on-surface-variant">4 goles marcados</div>
</div>
<div class="bg-surface-container-low p-space-sm rounded">
<div class="font-label-sm text-label-sm text-on-surface-variant uppercase">Estado del Torneo</div>
<div class="font-headline-md text-headline-md text-secondary font-bold">GRAN FINAL</div>
<div class="font-body-sm text-body-sm text-on-surface-variant">Saprissa vs Alajuelense</div>
</div>
</div>
</div>
<!-- SLIDABLE MATCH DETAIL DRAWER (PANEL LATERAL) -->
<div class="fixed top-0 right-0 h-full w-full max-w-md bg-surface shadow-2xl z-50 transform translate-x-full transition-transform duration-300 ease-in-out flex flex-col" id="match-drawer">
<!-- Drawer Header -->
<div class="p-space-md bg-tertiary-container text-on-tertiary flex items-center justify-between">
<div class="flex items-center gap-space-sm">
<div class="w-8 h-8 rounded bg-primary flex items-center justify-center">
<span class="material-symbols-outlined text-secondary text-[20px]">sports_soccer</span>
</div>
<div>
<span class="font-label-sm text-[10px] uppercase text-secondary-fixed tracking-wider font-bold" id="drawer-stage-badge">OCTAVOS DE FINAL</span>
<div class="font-headline-md text-[16px] text-on-tertiary font-bold" id="drawer-match-code">PARTIDO 01</div>
</div>
</div>
<button class="w-8 h-8 rounded-full bg-surface/10 hover:bg-surface/20 flex items-center justify-center text-on-tertiary transition-colors" id="close-drawer">
<span class="material-symbols-outlined text-[18px]">close</span>
</button>
</div>
<!-- Drawer Content Scrollable -->
<div class="flex-1 overflow-y-auto p-space-md flex flex-col gap-space-md">
<!-- Match Status Banner -->
<div class="p-space-sm rounded bg-surface-container-high flex items-center justify-between">
<div class="flex items-center gap-1.5">
<span class="w-2 h-2 rounded-full bg-secondary"></span>
<span class="font-label-sm text-label-sm font-bold text-on-surface uppercase">ESTADO: FINALIZADO</span>
</div>
<span class="font-label-sm text-[11px] text-on-surface-variant" id="drawer-stadium">Estadio Ricardo Saprissa</span>
</div>
<!-- Teams & Live Final Scoreboard -->
<div class="p-space-md rounded bg-surface-container-low shadow-sm flex items-center justify-between">
<!-- Team 1 -->
<div class="flex-1 text-center">
<div class="w-12 h-12 rounded-full bg-primary mx-auto flex items-center justify-center text-secondary mb-2 shadow-sm">
<span class="material-symbols-outlined text-[24px]">shield</span>
</div>
<div class="font-headline-md text-[14px] text-on-surface font-bold" id="drawer-team-1">Saprissa de Moravia</div>
<span class="font-label-sm text-[10px] text-on-surface-variant uppercase">Local</span>
</div>
<!-- Scoreboard Center -->
<div class="px-4 text-center">
<div class="font-headline-xl text-headline-xl text-primary font-bold flex items-center gap-1 justify-center">
<span id="drawer-score-1">3</span>
<span class="text-on-surface-variant text-[24px]">:</span>
<span id="drawer-score-2">1</span>
</div>
<div class="px-2 py-0.5 rounded bg-primary text-on-primary font-label-sm text-[10px] uppercase tracking-wider inline-block">Final 90'</div>
</div>
<!-- Team 2 -->
<div class="flex-1 text-center">
<div class="w-12 h-12 rounded-full bg-surface-container-highest mx-auto flex items-center justify-center text-on-surface-variant mb-2">
<span class="material-symbols-outlined text-[24px]">shield</span>
</div>
<div class="font-headline-md text-[14px] text-on-surface font-bold" id="drawer-team-2">Guadalupe Auriazul</div>
<span class="font-label-sm text-[10px] text-on-surface-variant uppercase">Visita</span>
</div>
</div>
<!-- Winner Announcement Badge -->
<div class="p-space-sm rounded bg-secondary-container text-on-secondary-container flex items-center gap-space-sm">
<span class="material-symbols-outlined text-[20px] text-secondary">verified</span>
<div>
<span class="font-label-sm text-[10px] uppercase font-bold">Equipo Clasificado a Siguiente Fase:</span>
<div class="font-title-sm text-title-sm font-bold text-on-secondary-container" id="drawer-winner">Saprissa de Moravia</div>
</div>
</div>
<!-- Match Timeline Highlights -->
<div class="flex flex-col gap-2">
<span class="font-headline-md text-[13px] uppercase tracking-wider text-on-surface font-bold">Cronología de Goles &amp; Hitos</span>
<div class="space-y-2 bg-surface-container-low p-space-sm rounded">
<div class="flex items-center justify-between text-body-sm text-on-surface">
<span class="font-label-sm font-bold text-secondary">14' GOL</span>
<span class="font-medium">M. Torres (Tiro Libre Directo)</span>
<span class="font-bold text-primary">1 - 0</span>
</div>
<div class="flex items-center justify-between text-body-sm text-on-surface">
<span class="font-label-sm font-bold text-secondary">38' GOL</span>
<span class="font-medium">J. Sinclair (Cabezazo al ángulo)</span>
<span class="font-bold text-primary">2 - 0</span>
</div>
<div class="flex items-center justify-between text-body-sm text-on-surface-variant">
<span class="font-label-sm font-bold text-on-surface-variant">59' GOL</span>
<span>J. Mora (Remate cruzado)</span>
<span class="font-medium text-on-surface">2 - 1</span>
</div>
<div class="flex items-center justify-between text-body-sm text-on-surface">
<span class="font-label-sm font-bold text-secondary">82' GOL</span>
<span class="font-medium">A. Rodríguez (Contragolpe letal)</span>
<span class="font-bold text-primary">3 - 1</span>
</div>
</div>
</div>
<!-- Match Technical Stats -->
<div class="flex flex-col gap-2">
<span class="font-headline-md text-[13px] uppercase tracking-wider text-on-surface font-bold">Estadísticas del Encuentro</span>
<div class="space-y-2.5 bg-surface-container-low p-space-sm rounded">
<div>
<div class="flex justify-between font-label-sm text-[11px] mb-1">
<span>Posesión de Balón</span>
<span class="font-bold">58% vs 42%</span>
</div>
<div class="w-full h-1.5 bg-surface-container-highest rounded-full overflow-hidden flex">
<div class="bg-primary h-full" style="width: 58%"></div>
<div class="bg-surface-container-high h-full" style="width: 42%"></div>
</div>
</div>
<div>
<div class="flex justify-between font-label-sm text-[11px] mb-1">
<span>Tiros a Puerta</span>
<span class="font-bold">9 vs 3</span>
</div>
<div class="w-full h-1.5 bg-surface-container-highest rounded-full overflow-hidden flex">
<div class="bg-secondary h-full" style="width: 75%"></div>
<div class="bg-surface-container-high h-full" style="width: 25%"></div>
</div>
</div>
<div>
<div class="flex justify-between font-label-sm text-[11px] mb-1">
<span>Faltas Cometidas</span>
<span class="font-bold">11 vs 14</span>
</div>
<div class="w-full h-1.5 bg-surface-container-highest rounded-full overflow-hidden flex">
<div class="bg-surface-tint h-full" style="width: 44%"></div>
<div class="bg-surface-container-high h-full" style="width: 56%"></div>
</div>
</div>
</div>
</div>
<!-- Action Simulation & Replay Button -->
<div class="pt-2 flex flex-col gap-2">
<button class="w-full py-2.5 bg-secondary hover:bg-on-secondary-container text-on-secondary font-headline-md text-[13px] uppercase tracking-wider rounded flex items-center justify-center gap-2 shadow-md transition-all active:scale-[0.98]" id="btn-replay-sim">
<span class="material-symbols-outlined text-[18px]">replay</span>
          Reproducir Simulación (Replay 2D)
        </button>
<button class="w-full py-2 bg-surface-container-high hover:bg-surface-container-highest text-on-surface font-label-sm text-label-sm uppercase rounded flex items-center justify-center gap-1 transition-colors" id="btn-view-stats">
<span class="material-symbols-outlined text-[16px]">query_stats</span>
          Ficha Técnica Completa (PDF)
        </button>
</div>
</div>
</div>
<!-- Drawer Backdrop Overlay -->
<div class="fixed inset-0 bg-primary/40 backdrop-blur-xs z-40 hidden transition-opacity duration-300" id="drawer-backdrop"></div>
</div>
</main><footer class="w-full bg-surface-container-low py-space-xl mt-space-xl"><div class="w-full px-margin flex flex-col md:flex-row items-center justify-between gap-space-md"><div class="flex items-center gap-space-sm"><div class="w-6 h-6 rounded bg-primary flex items-center justify-center"><span class="material-symbols-outlined text-secondary text-[14px]">emoji_events</span></div><span class="font-headline-md text-headline-md uppercase text-on-surface">BRACKET ARENA</span></div><div class="font-body-sm text-body-sm text-on-surface-variant text-center">© 2026 Bracket Arena Technologies. Sistema Profesional de Gestión de Torneos Eliminatorios.</div><div class="flex items-center gap-space-md font-label-sm text-label-sm text-on-surface-variant uppercase"><a class="hover:text-on-surface transition-colors" href="#">Reglamento</a><a class="hover:text-on-surface transition-colors" href="#">Soporte</a><a class="hover:text-on-surface transition-colors" href="#">API Torneo</a></div></div></footer><script>window.ARENA_BASE = '<%=request.getContextPath()%>';</script><script defer="" src="<%=request.getContextPath()%>/js/stitch-runtime.js"></script></body></html>