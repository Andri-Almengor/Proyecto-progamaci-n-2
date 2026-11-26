<%--
  BRACKET ARENA / PANTALLA: Reproducción opcional e informe estadístico de un partido.
  Origen: HTML y clases originales de Stitch aportados al proyecto.
  Los datos y permisos se actualizan mediante /arena-data y stitch-runtime.js.
  La maquetación exportada se conserva sin reindentación para no cambiar su aspecto.
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html class="light" lang="es"><head><meta charset="utf-8"/><meta content="width=device-width, initial-scale=1.0" name="viewport"/><meta content="web_standard" name="shell-type"/><link href="https://fonts.googleapis.com" rel="preconnect"/><link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&amp;family=Space+Grotesk:wght@600;700&amp;display=swap" rel="preload" as="style" onload="this.onload=null;this.rel='stylesheet'"/><link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="preload" as="style" onload="this.onload=null;this.rel='stylesheet'"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="preload" as="style" onload="this.onload=null;this.rel='stylesheet'"/><style>@layer base{html,body{margin:0;padding:0;}body{overscroll-behavior:none;}main>:first-child{margin-top:0!important;}main>:last-child{margin-bottom:0!important;}}::-webkit-scrollbar{display:none;}</style><link href="<%=request.getContextPath()%>/css/stitch.css?v=2026-11-25-admin-r3" rel="stylesheet"/><link href="<%=request.getContextPath()%>/css/stitch-bridge.css?v=2026-11-25-admin-r3" rel="stylesheet"/></head><body class="bg-background font-body-md text-body-md text-on-surface antialiased arena-loading" data-arena-page="match"><div aria-busy="true" aria-label="Cargando datos del torneo" id="arena-skeleton">
<div class="ske-nav"><div class="ske-block" style="width:160px;height:28px"></div><div class="ske-block" style="width:300px;height:16px"></div><div class="ske-block" style="width:120px;height:25px"></div></div>
<div class="ske-hero"><div><div class="ske-block" style="width:110px;height:14px"></div><div class="ske-block" style="width:80%;height:52px"></div><div class="ske-block" style="width:66%;height:18px"></div><div class="ske-block" style="width:73%;height:18px"></div><div class="ske-block" style="width:45%;height:35px"></div></div><div class="ske-block ske-cover"></div></div>
<div class="ske-cards"><div class="ske-block"></div><div class="ske-block"></div><div class="ske-block"></div><div class="ske-block"></div></div>
<div class="ske-panel"><div class="ske-block" style="width:35%;height:25px"></div><div class="ske-block" style="height:120px"></div><div class="ske-block" style="height:24px;width:70%"></div></div>
<div class="ske-panel"><div class="ske-block" style="width:42%;height:25px"></div><div class="ske-cards"><div class="ske-block"></div><div class="ske-block"></div></div></div>
</div><noscript><p style="padding:2rem;background:#fef3c7;color:#111">La interfaz necesita JavaScript para consultar los datos del torneo. Activá JavaScript para continuar.</p></noscript><%@ include file="partials/header.jspf" %><main class="w-full pt-28 bg-background min-h-screen" data-arena-main=""><% if (request.getAttribute("flash") != null) { %><div class="arena-flash <%= "error".equals(request.getAttribute("flashKind")) ? "error" : "" %>" role="status"><%=com.torneo.Web.esc(String.valueOf(request.getAttribute("flash")))%></div><% } %><div class="flex flex-col w-full">
<!-- Match Headline & Scoreboard Monolith -->
<section class="w-full px-margin pb-space-lg" data-original-section="0">
<div class="bg-surface shadow-sm rounded-xl p-space-lg flex flex-col gap-space-md">
<!-- Breadcrumb Meta & Live Engine Badges -->
<div class="flex flex-wrap items-center justify-between gap-space-sm">
<div class="flex items-center gap-space-xs font-label-sm text-label-sm uppercase tracking-wider text-on-surface-variant">
<span class="text-secondary font-headline-md leading-none text-headline-md">●</span>
<span>COPA PREMIER 2026</span>
<span>/</span>
<span>FASE FINAL</span>
<span>/</span>
<span class="text-on-surface font-label-md text-label-md">SEMIFINAL #2</span>
</div>
<div class="flex items-center gap-space-xs">
<span class="px-2 py-0.5 rounded bg-surface-container-high text-on-surface font-label-sm text-label-sm uppercase tracking-wider">REGISTRO OFICIAL ID #14</span>
<span class="px-2 py-0.5 rounded bg-primary text-on-primary font-label-sm text-label-sm uppercase tracking-wider flex items-center gap-1">
<span class="material-symbols-outlined text-[14px] text-secondary">check_circle</span>
            FINALIZADO (90')
          </span>
</div>
</div>
<!-- Teams Matchup Scoreboard -->
<div class="grid grid-cols-1 lg:grid-cols-12 gap-space-md items-center py-space-sm">
<!-- Team Local: Deportivo Saprissa -->
<div class="lg:col-span-5 flex items-center justify-between lg:justify-end gap-space-md">
<div class="text-left lg:text-right">
<div class="flex items-center lg:justify-end gap-space-xs">
<span class="px-1.5 py-0.5 rounded bg-primary text-on-primary font-label-sm text-label-sm">SEM 01</span>
<span class="font-headline-lg text-headline-lg uppercase text-on-surface">DEP. SAPRISSA</span>
</div>
<div class="font-body-sm text-body-sm text-on-surface-variant">San José, CRC • Local</div>
</div>
<div class="w-16 h-16 rounded-xl bg-surface-container-high flex items-center justify-center font-headline-xl text-headline-xl text-on-surface shrink-0 shadow-inner">
<span class="material-symbols-outlined text-[36px] text-primary">shield</span>
</div>
</div>
<!-- Center Score & Venue -->
<div class="lg:col-span-2 flex flex-col items-center justify-center text-center px-space-sm py-space-xs bg-surface-container-low rounded-lg shadow-sm">
<div class="flex items-baseline justify-center gap-space-xs font-headline-xl text-headline-xl tracking-tighter text-on-surface">
<span class="transition-all duration-300" id="score-home">3</span>
<span class="text-secondary font-headline-lg text-headline-lg">:</span>
<span class="transition-all duration-300" id="score-away">2</span>
</div>
<div class="font-label-sm text-label-sm uppercase text-secondary font-bold tracking-widest mt-[-2px]">TIEMPO CUMPLIDO</div>
<div class="flex items-center gap-1 font-body-sm text-body-sm text-on-surface-variant mt-1">
<span class="material-symbols-outlined text-[14px]">stadium</span>
<span>Estadio Nacional CRC</span>
</div>
</div>
<!-- Team Away: LD Alajuelense -->
<div class="lg:col-span-5 flex items-center justify-between lg:justify-start gap-space-md">
<div class="w-16 h-16 rounded-xl bg-surface-container-high flex items-center justify-center font-headline-xl text-headline-xl text-on-surface shrink-0 shadow-inner order-last lg:order-first">
<span class="material-symbols-outlined text-[36px] text-on-surface-variant">military_tech</span>
</div>
<div class="text-right lg:text-left">
<div class="flex items-center lg:justify-start gap-space-xs">
<span class="font-headline-lg text-headline-lg uppercase text-on-surface">LD ALAJUELENSE</span>
<span class="px-1.5 py-0.5 rounded bg-surface-container-highest text-on-surface font-label-sm text-label-sm">SEM 02</span>
</div>
<div class="font-body-sm text-body-sm text-on-surface-variant">Alajuela, CRC • Visitante</div>
</div>
</div>
</div>
<!-- Scorer Event Highlights Row -->
<div class="flex flex-wrap items-center justify-between gap-space-md pt-space-xs bg-surface-container-lowest rounded-lg p-space-sm text-on-surface">
<div class="flex items-center gap-space-xs font-body-sm text-body-sm text-on-surface">
<span class="material-symbols-outlined text-secondary text-[16px]">sports_soccer</span>
<span class="font-title-sm text-title-sm">Goles SAP:</span>
<span>A. Cruz (18'), M. Torres (63'), K. Venegas (90+2')</span>
</div>
<div class="flex items-center gap-space-xs font-body-sm text-body-sm text-on-surface">
<span class="material-symbols-outlined text-secondary text-[16px]">sports_soccer</span>
<span class="font-title-sm text-title-sm">Goles LDA:</span>
<span>J. Moya (34'), C. Mora (71')</span>
</div>
</div>
</div>
</section>
<!-- Interactive Simulation Canvas & Control Bar -->
<section class="w-full px-margin pb-space-lg" data-original-section="1">
<div class="grid grid-cols-1 xl:grid-cols-12 gap-space-md">
<!-- Left: 2D Tactical Field & Simulation Engine (xl:col-span-8) -->
<div class="xl:col-span-8 bg-surface rounded-xl shadow-sm p-space-md flex flex-col gap-space-md">
<!-- Control Header & Playback Strip -->
<div class="flex flex-wrap items-center justify-between gap-space-sm bg-surface-container-low p-space-sm rounded-lg">
<div class="flex items-center gap-space-xs">
<button class="px-space-md py-space-xs rounded bg-primary text-on-primary font-label-md text-label-md uppercase flex items-center gap-1 hover:bg-primary-container transition-all active:scale-95 shadow-sm" id="btn-play" type="button">
<span class="material-symbols-outlined text-[16px]">play_arrow</span>
<span id="btn-play-label">Reproducir</span>
</button>
<button class="px-space-sm py-space-xs rounded bg-surface text-on-surface font-label-md text-label-md uppercase flex items-center gap-1 hover:bg-surface-container transition-all shadow-sm" id="btn-pause" type="button">
<span class="material-symbols-outlined text-[16px]">pause</span>
<span>Pausar</span>
</button>
<button class="px-space-sm py-space-xs rounded bg-surface text-on-surface font-label-md text-label-md uppercase flex items-center gap-1 hover:bg-surface-container transition-all shadow-sm" id="btn-reset" type="button">
<span class="material-symbols-outlined text-[16px]">restart_alt</span>
<span>Reiniciar</span>
</button>
</div>
<div class="flex items-center gap-space-xs">
<span class="font-label-sm text-label-sm uppercase text-on-surface-variant font-bold">Velocidad:</span>
<button class="px-2 py-0.5 rounded text-[11px] font-bold bg-surface text-on-surface hover:bg-surface-container shadow-sm speed-btn active" data-speed="1">1X</button>
<button class="px-2 py-0.5 rounded text-[11px] font-bold bg-surface-container-high text-on-surface-variant hover:bg-surface hover:text-on-surface transition-colors speed-btn" data-speed="2">2X</button>
<button class="ml-space-xs px-space-sm py-space-xs rounded bg-secondary text-on-secondary font-label-md text-label-md uppercase flex items-center gap-1 hover:opacity-90 transition-all shadow-sm" id="btn-jump" type="button">
<span class="material-symbols-outlined text-[16px]">fast_forward</span>
<span>Estadísticas Finales</span>
</button>
</div>
</div>
<!-- Scrubber Bar with Match Milestones -->
<div class="relative pt-4 pb-2 px-space-xs bg-surface-container-lowest rounded-lg">
<div class="flex items-center justify-between text-on-surface-variant font-label-sm text-label-sm mb-1.5">
<div class="flex items-center gap-2">
<span class="w-2.5 h-2.5 rounded-full bg-secondary animate-ping"></span>
<span class="font-headline-md text-headline-md text-on-surface tracking-tight" id="clock-display">00:00</span>
<span class="font-label-sm text-label-sm text-secondary uppercase font-bold" id="clock-period">1T EN ESPERA</span>
</div>
<div class="flex items-center gap-3">
<span class="flex items-center gap-1"><span class="w-2 h-2 rounded-full bg-secondary"></span> Gol</span>
<span class="flex items-center gap-1"><span class="w-2 h-2 rounded-full bg-tertiary-container"></span> Tarjeta</span>
<span class="flex items-center gap-1"><span class="w-2 h-2 rounded-full bg-surface-container-highest"></span> Cambio</span>
<span>90:00' Final</span>
</div>
</div>
<!-- Progress Track -->
<div class="relative w-full h-3 bg-surface-container rounded-full overflow-hidden cursor-pointer" id="progress-track">
<div class="h-full bg-secondary transition-all duration-100 ease-linear" id="sim-progress-bar" style="width: 0%;"></div>
</div>
<!-- Markers Over Progress -->
<div class="relative w-full h-4 mt-1 font-label-sm text-label-sm">
<!-- 18m Goal SAP -->
<button class="marker-btn absolute -top-4 -ml-2 w-4 h-4 rounded-full bg-secondary text-white flex items-center justify-center hover:scale-125 transition-transform" data-minute="18" style="left: 20%;" title="18' Gol SAP" type="button">
<span class="material-symbols-outlined text-[10px]">sports_soccer</span>
</button>
<!-- 34m Goal LDA -->
<button class="marker-btn absolute -top-4 -ml-2 w-4 h-4 rounded-full bg-secondary text-white flex items-center justify-center hover:scale-125 transition-transform" data-minute="34" style="left: 37.7%;" title="34' Gol LDA" type="button">
<span class="material-symbols-outlined text-[10px]">sports_soccer</span>
</button>
<!-- 42m Yellow LDA -->
<button class="marker-btn absolute -top-4 -ml-2 w-4 h-4 rounded-full bg-on-secondary-fixed-variant text-secondary-fixed flex items-center justify-center hover:scale-125 transition-transform" data-minute="42" style="left: 46.6%;" title="42' Amarilla LDA" type="button">
<span class="text-[9px] font-bold">Y</span>
</button>
<!-- 45m HT -->
<div class="absolute -top-3 w-0.5 h-3 bg-primary" style="left: 50%;"></div>
<!-- 63m Goal SAP -->
<button class="marker-btn absolute -top-4 -ml-2 w-4 h-4 rounded-full bg-secondary text-white flex items-center justify-center hover:scale-125 transition-transform" data-minute="63" style="left: 70%;" title="63' Gol SAP" type="button">
<span class="material-symbols-outlined text-[10px]">sports_soccer</span>
</button>
<!-- 71m Goal LDA -->
<button class="marker-btn absolute -top-4 -ml-2 w-4 h-4 rounded-full bg-secondary text-white flex items-center justify-center hover:scale-125 transition-transform" data-minute="71" style="left: 78.8%;" title="71' Gol LDA" type="button">
<span class="material-symbols-outlined text-[10px]">sports_soccer</span>
</button>
<!-- 74m Sub SAP -->
<button class="marker-btn absolute -top-4 -ml-2 w-4 h-4 rounded-full bg-surface-container-highest text-on-surface flex items-center justify-center hover:scale-125 transition-transform" data-minute="74" style="left: 82.2%;" title="74' Sustitución" type="button">
<span class="material-symbols-outlined text-[10px]">sync</span>
</button>
<!-- 90+2m Goal SAP -->
<button class="marker-btn absolute -top-4 -ml-2 w-4 h-4 rounded-full bg-secondary text-white flex items-center justify-center hover:scale-125 transition-transform" data-minute="90" style="left: 98%;" title="90+2' Gol SAP Ganador" type="button">
<span class="material-symbols-outlined text-[10px]">star</span>
</button>
</div>
</div>
<!-- 2D Tactical Soccer Pitch Schematics -->
<div class="relative w-full aspect-[16/9] bg-primary rounded-xl overflow-hidden shadow-lg flex items-center justify-center select-none">
<!-- Pitch Grass Lines SVG -->
<svg class="absolute inset-0 w-full h-full opacity-30 text-surface" fill="none" stroke="currentColor" stroke-width="2" viewbox="0 0 1000 600">
<!-- Outer Line -->
<rect height="560" rx="4" width="960" x="20" y="20"></rect>
<!-- Midfield Line -->
<line x1="500" x2="500" y1="20" y2="580"></line>
<!-- Center Circle -->
<circle cx="500" cy="300" r="70"></circle>
<circle cx="500" cy="300" fill="currentColor" r="3"></circle>
<!-- Left Penalty Area -->
<rect height="320" width="160" x="20" y="140"></rect>
<rect height="160" width="60" x="20" y="220"></rect>
<circle cx="120" cy="300" fill="currentColor" r="3"></circle>
<path d="M 180 250 A 70 70 0 0 1 180 350"></path>
<!-- Right Penalty Area -->
<rect height="320" width="160" x="820" y="140"></rect>
<rect height="160" width="60" x="920" y="220"></rect>
<circle cx="880" cy="300" fill="currentColor" r="3"></circle>
<path d="M 820 250 A 70 70 0 0 0 820 350"></path>
<!-- Corners -->
<path d="M 20 40 A 20 20 0 0 0 40 20"></path>
<path d="M 20 560 A 20 20 0 0 1 40 580"></path>
<path d="M 980 40 A 20 20 0 0 1 960 20"></path>
<path d="M 980 560 A 20 20 0 0 0 960 580"></path>
</svg>
<!-- Heatmap & Danger Zone Dynamic Glow Underlays -->
<div class="absolute inset-0 pointer-events-none transition-opacity duration-700 opacity-60" id="heatmap-overlay">
<!-- Left High Press Gradient Zone -->
<div class="absolute left-1/4 top-1/4 w-72 h-44 rounded-full bg-secondary/20 blur-2xl"></div>
<!-- Right Penetration Heat Zone -->
<div class="absolute right-1/6 bottom-1/3 w-80 h-52 rounded-full bg-secondary/30 blur-3xl"></div>
</div>
<!-- Team Labels on Field -->
<div class="absolute left-6 top-6 font-headline-md text-headline-md tracking-wider text-surface/20 uppercase">Saprissa (Local)</div>
<div class="absolute right-6 bottom-6 font-headline-md text-headline-md tracking-wider text-surface/20 uppercase">Alajuelense (Visita)</div>
<!-- Dynamic Ball Node -->
<div class="absolute w-6 h-6 rounded-full bg-surface shadow-[0_0_15px_rgba(255,255,255,0.9)] flex items-center justify-center transition-all duration-700 ease-out transform -translate-x-1/2 -translate-y-1/2 z-20" id="ball-actor" style="left: 50%; top: 50%;">
<div class="w-3 h-3 rounded-full bg-primary flex items-center justify-center">
<div class="w-1 h-1 rounded-full bg-white"></div>
</div>
</div>
<!-- Ball Vector Trail SVG -->
<svg class="absolute inset-0 w-full h-full pointer-events-none z-10" viewbox="0 0 1000 600">
<polyline fill="none" id="ball-vector-trail" points="500,300" stroke="rgba(217,119,6,0.5)" stroke-dasharray="6,6" stroke-linecap="round" stroke-width="3"></polyline>
</svg>
<!-- Attacking Phase Indicator HUD -->
<div class="absolute bottom-4 left-4 bg-primary/80 backdrop-blur-md px-3 py-1.5 rounded-lg flex items-center gap-space-sm z-30 shadow-md">
<div class="w-2.5 h-2.5 rounded-full bg-secondary animate-pulse"></div>
<div class="flex flex-col">
<span class="font-label-sm text-label-sm text-surface uppercase font-bold tracking-wider" id="tactical-state">ESTADO: DISTRIBUCIÓN MEDIA</span>
<span class="font-body-sm text-body-sm text-primary-fixed-dim" id="tactical-substate">Posesión equilibrada en zona medular</span>
</div>
</div>
<!-- Mini Pitch Legend / Toggle -->
<div class="absolute top-4 right-4 flex items-center gap-1 z-30">
<button class="px-2.5 py-1 rounded bg-surface/20 backdrop-blur-md text-surface hover:bg-surface/30 font-label-sm text-label-sm uppercase transition-colors" id="toggle-heatmap" type="button">
              Zonas de Calor: ON
            </button>
</div>
</div>
</div>
<!-- Right: Real-time Live Ticker & Chronology Feed (xl:col-span-4) -->
<div class="xl:col-span-4 bg-surface rounded-xl shadow-sm p-space-md flex flex-col justify-between">
<div class="flex flex-col h-full">
<!-- Feed Header -->
<div class="flex items-center justify-between pb-space-sm bg-surface-container-low p-space-sm rounded-lg mb-space-sm">
<div class="flex items-center gap-space-xs font-label-md text-label-md uppercase text-on-surface">
<span class="material-symbols-outlined text-secondary text-[18px]">stream</span>
<span>Minuto a Minuto En Vivo</span>
</div>
<span class="px-2 py-0.5 rounded bg-secondary-container text-on-secondary-container font-label-sm text-label-sm uppercase font-bold">12 Eventos</span>
</div>
<!-- Chronology Event Stream Container -->
<div class="flex flex-col gap-space-xs overflow-y-auto max-h-[460px] pr-1" id="ticker-feed">
<!-- Event 1: 90+2' Goal -->
<div class="ticker-item p-space-sm rounded-lg bg-secondary-container/60 transition-all flex items-start gap-space-sm">
<span class="px-2 py-1 rounded bg-secondary text-on-secondary font-headline-md text-headline-md tracking-tight shrink-0">90+2'</span>
<div class="flex flex-col">
<div class="flex items-center gap-1 font-label-md text-label-md uppercase text-on-surface font-bold">
<span class="material-symbols-outlined text-[16px] text-secondary">sports_soccer</span>
                  ¡GOLAZO DECISIVO DE SAPRISSA!
                </div>
<div class="font-body-md text-body-md text-on-surface mt-0.5">K. Venegas (#10) clava un tiro libre magistral al ángulo superior izquierdo. Delirio en la grada morada.</div>
</div>
</div>
<!-- Event 2: 74' Substitution -->
<div class="ticker-item p-space-sm rounded-lg bg-surface-container-low transition-all flex items-start gap-space-sm">
<span class="px-2 py-1 rounded bg-surface-container-highest text-on-surface font-title-sm text-title-sm shrink-0">74'</span>
<div class="flex flex-col">
<div class="flex items-center gap-1 font-label-md text-label-md uppercase text-on-surface font-bold">
<span class="material-symbols-outlined text-[16px] text-on-surface-variant">sync</span>
                  Modificación Táctica Saprissa
                </div>
<div class="font-body-md text-body-md text-on-surface mt-0.5">Sale Jugador #8 (D. Guzmán), ingresa Jugador #14 (F. Torres) para reforzar contención.</div>
</div>
</div>
<!-- Event 3: 71' Goal LDA -->
<div class="ticker-item p-space-sm rounded-lg bg-surface-container-low transition-all flex items-start gap-space-sm">
<span class="px-2 py-1 rounded bg-secondary text-on-secondary font-title-sm text-title-sm shrink-0">71'</span>
<div class="flex flex-col">
<div class="flex items-center gap-1 font-label-md text-label-md uppercase text-on-surface font-bold">
<span class="material-symbols-outlined text-[16px] text-secondary">sports_soccer</span>
                  GOL DE LD ALAJUELENSE
                </div>
<div class="font-body-md text-body-md text-on-surface mt-0.5">C. Mora aprovecha un rebote en el área chica y sentencia la paridad momentánea (2-2).</div>
</div>
</div>
<!-- Event 4: 63' Goal SAP -->
<div class="ticker-item p-space-sm rounded-lg bg-surface-container-low transition-all flex items-start gap-space-sm">
<span class="px-2 py-1 rounded bg-secondary text-on-secondary font-title-sm text-title-sm shrink-0">63'</span>
<div class="flex flex-col">
<div class="flex items-center gap-1 font-label-md text-label-md uppercase text-on-surface font-bold">
<span class="material-symbols-outlined text-[16px] text-secondary">sports_soccer</span>
                  GOL DE DEP. SAPRISSA
                </div>
<div class="font-body-md text-body-md text-on-surface mt-0.5">M. Torres remata cruzado tras un centro medido desde el costado diestro (2-1).</div>
</div>
</div>
<!-- Event 5: 42' Yellow Card -->
<div class="ticker-item p-space-sm rounded-lg bg-surface-container-low transition-all flex items-start gap-space-sm">
<span class="px-2 py-1 rounded bg-tertiary-container text-on-tertiary font-title-sm text-title-sm shrink-0">42'</span>
<div class="flex flex-col">
<div class="flex items-center gap-1 font-label-md text-label-md uppercase text-on-surface font-bold">
<span class="material-symbols-outlined text-[16px] text-secondary">warning</span>
                  Amonestación con Tarjeta Amarilla
                </div>
<div class="font-body-md text-body-md text-on-surface mt-0.5">Infracción táctica cometida por Jugador #5 (C. Borges) para frenar contragolpe rival.</div>
</div>
</div>
<!-- Event 6: 34' Goal LDA -->
<div class="ticker-item p-space-sm rounded-lg bg-surface-container-low transition-all flex items-start gap-space-sm">
<span class="px-2 py-1 rounded bg-secondary text-on-secondary font-title-sm text-title-sm shrink-0">34'</span>
<div class="flex flex-col">
<div class="flex items-center gap-1 font-label-md text-label-md uppercase text-on-surface font-bold">
<span class="material-symbols-outlined text-[16px] text-secondary">sports_soccer</span>
                  GOL DE LD ALAJUELENSE
                </div>
<div class="font-body-md text-body-md text-on-surface mt-0.5">J. Moya cabecea impecable en el primer poste tras tiro de esquina (1-1).</div>
</div>
</div>
<!-- Event 7: 18' Goal SAP -->
<div class="ticker-item p-space-sm rounded-lg bg-surface-container-low transition-all flex items-start gap-space-sm">
<span class="px-2 py-1 rounded bg-secondary text-on-secondary font-title-sm text-title-sm shrink-0">18'</span>
<div class="flex flex-col">
<div class="flex items-center gap-1 font-label-md text-label-md uppercase text-on-surface font-bold">
<span class="material-symbols-outlined text-[16px] text-secondary">sports_soccer</span>
                  GOL APERTURA SAPRISSA
                </div>
<div class="font-body-md text-body-md text-on-surface mt-0.5">A. Cruz define de volea tras recuperación alta en tres cuartos de campo (1-0).</div>
</div>
</div>
</div>
</div>
<div class="pt-space-sm text-center">
<span class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-widest">Sincronización en tiempo real vía motor táctico</span>
</div>
</div>
</div>
</section>
<!-- Deep Statistical Breakdown: Tabbed Comparative Engine -->
<section class="w-full px-margin pb-space-lg" data-original-section="2">
<div class="bg-surface rounded-xl shadow-sm p-space-lg flex flex-col gap-space-md">
<!-- Section Header & Filter Tabs -->
<div class="flex flex-col md:flex-row md:items-center justify-between gap-space-md pb-space-sm bg-surface-container-low p-space-sm rounded-lg">
<div>
<h2 class="font-headline-md text-headline-md uppercase text-on-surface tracking-tight">Análisis Estadístico Profundo</h2>
<div class="font-body-sm text-body-sm text-on-surface-variant">Métricas oficiales del compromiso validadas por sensor de rendimiento</div>
</div>
<!-- Period Switcher Tabs -->
<div class="flex items-center bg-surface-container-high p-1 rounded-lg">
<button class="tab-btn px-space-md py-1.5 rounded font-label-md text-label-md uppercase text-on-surface-variant hover:text-on-surface transition-all" data-period="first" type="button">Primer Tiempo</button>
<button class="tab-btn px-space-md py-1.5 rounded font-label-md text-label-md uppercase text-on-surface-variant hover:text-on-surface transition-all" data-period="second" type="button">Segundo Tiempo</button>
<button class="tab-btn active px-space-md py-1.5 rounded font-label-md text-label-md uppercase bg-primary text-on-primary shadow-sm transition-all" data-period="full" type="button">Partido Completo (90')</button>
</div>
</div>
<!-- Comparative Stat Metrics Matrix -->
<div class="grid grid-cols-1 gap-space-md">
<!-- Team Headers for Comparison -->
<div class="flex items-center justify-between px-space-sm font-headline-md text-headline-md uppercase">
<div class="flex items-center gap-space-xs text-on-surface">
<span class="w-3 h-3 rounded-full bg-primary"></span>
<span>Deportivo Saprissa</span>
</div>
<div class="font-label-sm text-label-sm uppercase text-on-surface-variant tracking-wider">Métrica Comparada</div>
<div class="flex items-center gap-space-xs text-on-surface">
<span>LD Alajuelense</span>
<span class="w-3 h-3 rounded-full bg-secondary"></span>
</div>
</div>
<!-- 1. Posesión del Balón -->
<div class="bg-surface-container-low p-space-sm rounded-lg flex flex-col gap-1.5 shadow-sm">
<div class="flex items-center justify-between font-headline-md text-headline-md">
<span class="font-bold text-on-surface" id="stat-pos-home">54%</span>
<span class="font-label-md text-label-md uppercase text-on-surface-variant tracking-wider">Posesión de Balón</span>
<span class="font-bold text-secondary" id="stat-pos-away">46%</span>
</div>
<div class="w-full h-3 bg-surface-container-highest rounded-full flex overflow-hidden">
<div class="h-full bg-primary transition-all duration-500" id="bar-pos-home" style="width: 54%;"></div>
<div class="h-full bg-secondary transition-all duration-500" id="bar-pos-away" style="width: 46%;"></div>
</div>
</div>
<!-- 2. Dominio Ofensivo (Ataques Peligrosos) -->
<div class="bg-surface-container-low p-space-sm rounded-lg flex flex-col gap-1.5 shadow-sm">
<div class="flex items-center justify-between font-headline-md text-headline-md">
<span class="font-bold text-on-surface" id="stat-atk-home">62</span>
<span class="font-label-md text-label-md uppercase text-on-surface-variant tracking-wider">Dominio Ofensivo (Ataques Peligrosos)</span>
<span class="font-bold text-secondary" id="stat-atk-away">48</span>
</div>
<div class="w-full h-3 bg-surface-container-highest rounded-full flex overflow-hidden">
<div class="h-full bg-primary transition-all duration-500" id="bar-atk-home" style="width: 56.3%;"></div>
<div class="h-full bg-secondary transition-all duration-500" id="bar-atk-away" style="width: 43.7%;"></div>
</div>
</div>
<!-- 3. Pases Completados -->
<div class="bg-surface-container-low p-space-sm rounded-lg flex flex-col gap-1.5 shadow-sm">
<div class="flex items-center justify-between font-headline-md text-headline-md">
<div class="flex items-baseline gap-1 text-on-surface">
<span class="font-bold" id="stat-pass-home">412</span>
<span class="font-body-sm text-body-sm text-on-surface-variant" id="stat-pass-home-sub">(88%)</span>
</div>
<span class="font-label-md text-label-md uppercase text-on-surface-variant tracking-wider">Pases Completados (Efectividad)</span>
<div class="flex items-baseline gap-1 text-secondary">
<span class="font-body-sm text-body-sm text-on-secondary-container" id="stat-pass-away-sub">(85%)</span>
<span class="font-bold" id="stat-pass-away">389</span>
</div>
</div>
<div class="w-full h-3 bg-surface-container-highest rounded-full flex overflow-hidden">
<div class="h-full bg-primary transition-all duration-500" id="bar-pass-home" style="width: 51.4%;"></div>
<div class="h-full bg-secondary transition-all duration-500" id="bar-pass-away" style="width: 48.6%;"></div>
</div>
</div>
<!-- 4. Tiros Totales -->
<div class="bg-surface-container-low p-space-sm rounded-lg flex flex-col gap-1.5 shadow-sm">
<div class="flex items-center justify-between font-headline-md text-headline-md">
<span class="font-bold text-on-surface" id="stat-shots-home">14</span>
<span class="font-label-md text-label-md uppercase text-on-surface-variant tracking-wider">Tiros Totales</span>
<span class="font-bold text-secondary" id="stat-shots-away">11</span>
</div>
<div class="w-full h-3 bg-surface-container-highest rounded-full flex overflow-hidden">
<div class="h-full bg-primary transition-all duration-500" id="bar-shots-home" style="width: 56%;"></div>
<div class="h-full bg-secondary transition-all duration-500" id="bar-shots-away" style="width: 44%;"></div>
</div>
</div>
<!-- 5. Tiros al Marco -->
<div class="bg-surface-container-low p-space-sm rounded-lg flex flex-col gap-1.5 shadow-sm">
<div class="flex items-center justify-between font-headline-md text-headline-md">
<span class="font-bold text-on-surface" id="stat-ontarget-home">6</span>
<span class="font-label-md text-label-md uppercase text-on-surface-variant tracking-wider">Tiros al Marco</span>
<span class="font-bold text-secondary" id="stat-ontarget-away">4</span>
</div>
<div class="w-full h-3 bg-surface-container-highest rounded-full flex overflow-hidden">
<div class="h-full bg-primary transition-all duration-500" id="bar-ontarget-home" style="width: 60%;"></div>
<div class="h-full bg-secondary transition-all duration-500" id="bar-ontarget-away" style="width: 40%;"></div>
</div>
</div>
<!-- 6. Tiros de Esquina -->
<div class="bg-surface-container-low p-space-sm rounded-lg flex flex-col gap-1.5 shadow-sm">
<div class="flex items-center justify-between font-headline-md text-headline-md">
<span class="font-bold text-on-surface" id="stat-corners-home">7</span>
<span class="font-label-md text-label-md uppercase text-on-surface-variant tracking-wider">Tiros de Esquina</span>
<span class="font-bold text-secondary" id="stat-corners-away">5</span>
</div>
<div class="w-full h-3 bg-surface-container-highest rounded-full flex overflow-hidden">
<div class="h-full bg-primary transition-all duration-500" id="bar-corners-home" style="width: 58.3%;"></div>
<div class="h-full bg-secondary transition-all duration-500" id="bar-corners-away" style="width: 41.7%;"></div>
</div>
</div>
<!-- 7. Faltas Cometidas -->
<div class="bg-surface-container-low p-space-sm rounded-lg flex flex-col gap-1.5 shadow-sm">
<div class="flex items-center justify-between font-headline-md text-headline-md">
<span class="font-bold text-on-surface" id="stat-fouls-home">12</span>
<span class="font-label-md text-label-md uppercase text-on-surface-variant tracking-wider">Faltas Cometidas</span>
<span class="font-bold text-secondary" id="stat-fouls-away">15</span>
</div>
<div class="w-full h-3 bg-surface-container-highest rounded-full flex overflow-hidden">
<div class="h-full bg-primary transition-all duration-500" id="bar-fouls-home" style="width: 44.4%;"></div>
<div class="h-full bg-secondary transition-all duration-500" id="bar-fouls-away" style="width: 55.6%;"></div>
</div>
</div>
</div>
</div>
</section>
<!-- Legal & Disclaimer Footnote -->
<footer class="w-full px-margin pb-space-xl">
<div class="bg-surface-container-low rounded-lg p-space-md flex flex-col md:flex-row items-center justify-between gap-space-sm text-center md:text-left">
<div class="flex items-center gap-space-xs font-body-sm text-body-sm text-on-surface-variant">
<span class="material-symbols-outlined text-[16px] text-secondary">info</span>
<span>Estadísticas y eventos simulados con fines demostrativos.</span>
</div>
<div class="font-label-sm text-label-sm uppercase tracking-widest text-on-surface-variant">
        MOTOR TOURNAMENT MONOLITH v2.4 • LATENCIA: 18ms
      </div>
</div>
</footer>
</div>
<!-- Simulation Script Logic -->
</main><footer class="w-full bg-surface-container-low py-space-xl mt-space-xl"><div class="w-full px-margin flex flex-col md:flex-row items-center justify-between gap-space-md"><div class="flex items-center gap-space-sm"><div class="w-6 h-6 rounded bg-primary flex items-center justify-center"><span class="material-symbols-outlined text-secondary text-[14px]">emoji_events</span></div><span class="font-headline-md text-headline-md uppercase text-on-surface">BRACKET ARENA</span></div><div class="font-body-sm text-body-sm text-on-surface-variant text-center">© 2026 Bracket Arena Technologies. Sistema Profesional de Gestión de Torneos Eliminatorios.</div><div class="flex items-center gap-space-md font-label-sm text-label-sm text-on-surface-variant uppercase"><a class="hover:text-on-surface transition-colors" href="#">Reglamento</a><a class="hover:text-on-surface transition-colors" href="#">Soporte</a><a class="hover:text-on-surface transition-colors" href="#">API Torneo</a></div></div></footer><script>window.ARENA_BASE = '<%=request.getContextPath()%>';</script><script defer="" src="<%=request.getContextPath()%>/js/stitch-runtime.js?v=2026-11-25-admin-r3"></script></body></html>