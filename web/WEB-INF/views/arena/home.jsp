<%--
  BRACKET ARENA / PANTALLA: Inicio: final nacional, encuentros destacados y estadísticas.
  Origen: HTML y clases originales de Stitch aportados al proyecto.
  Los datos y permisos se actualizan mediante /arena-data y stitch-runtime.js.
  La maquetación exportada se conserva sin reindentación para no cambiar su aspecto.
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html class="light" lang="es"><head><meta charset="utf-8"/><meta content="width=device-width, initial-scale=1.0" name="viewport"/><meta content="web_standard" name="shell-type"/><link href="https://fonts.googleapis.com" rel="preconnect"/><link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&amp;family=Space+Grotesk:wght@600;700&amp;display=swap" rel="preload" as="style" onload="this.onload=null;this.rel='stylesheet'"/><link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="preload" as="style" onload="this.onload=null;this.rel='stylesheet'"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="preload" as="style" onload="this.onload=null;this.rel='stylesheet'"/><style>@layer base{html,body{margin:0;padding:0;}body{overscroll-behavior:none;}main>:first-child{margin-top:0!important;}main>:last-child{margin-bottom:0!important;}}::-webkit-scrollbar{display:none;}</style><link href="<%=request.getContextPath()%>/css/stitch.css?v=2026-11-25-mobile-r4" rel="stylesheet"/><link href="<%=request.getContextPath()%>/css/stitch-bridge.css?v=2026-11-25-mobile-r4" rel="stylesheet"/></head><body class="bg-background font-body-md text-body-md text-on-surface antialiased arena-loading" data-arena-page="home"><div aria-busy="true" aria-label="Cargando datos del torneo" id="arena-skeleton">
<div class="ske-nav"><div class="ske-block" style="width:160px;height:28px"></div><div class="ske-block" style="width:300px;height:16px"></div><div class="ske-block" style="width:120px;height:25px"></div></div>
<div class="ske-hero"><div><div class="ske-block" style="width:110px;height:14px"></div><div class="ske-block" style="width:80%;height:52px"></div><div class="ske-block" style="width:66%;height:18px"></div><div class="ske-block" style="width:73%;height:18px"></div><div class="ske-block" style="width:45%;height:35px"></div></div><div class="ske-block ske-cover"></div></div>
<div class="ske-cards"><div class="ske-block"></div><div class="ske-block"></div><div class="ske-block"></div><div class="ske-block"></div></div>
<div class="ske-panel"><div class="ske-block" style="width:35%;height:25px"></div><div class="ske-block" style="height:120px"></div><div class="ske-block" style="height:24px;width:70%"></div></div>
<div class="ske-panel"><div class="ske-block" style="width:42%;height:25px"></div><div class="ske-cards"><div class="ske-block"></div><div class="ske-block"></div></div></div>
</div><noscript><p style="padding:2rem;background:#fef3c7;color:#111">La interfaz necesita JavaScript para consultar los datos del torneo. Activá JavaScript para continuar.</p></noscript><%@ include file="partials/header.jspf" %><main class="w-full pt-28 bg-background min-h-screen" data-arena-main=""><% if (request.getAttribute("flash") != null) { %><div class="arena-flash <%= "error".equals(request.getAttribute("flashKind")) ? "error" : "" %>" role="status"><%=com.torneo.Web.esc(String.valueOf(request.getAttribute("flash")))%></div><% } %><div class="flex flex-col w-full">
<!-- Top Ticker / Meta Status Bar -->
<section class="w-full bg-surface-container-high px-margin py-space-sm flex flex-wrap items-center justify-between gap-space-sm" data-original-section="0">
<div class="flex items-center gap-space-md">
<div class="flex items-center gap-space-xs">
<span class="w-2 h-2 rounded-full bg-secondary animate-ping"></span>
<span class="font-label-sm text-label-sm uppercase tracking-wider text-on-surface">EDICIÓN NACIONAL CLAUSURA</span>
</div>
<span class="text-on-surface-variant font-label-sm text-label-sm">/</span>
<span class="font-label-sm text-label-sm text-on-surface-variant uppercase">SISTEMA: ELIMINACIÓN DIRECTA 16K</span>
</div>
<div class="flex items-center gap-space-lg text-on-surface-variant font-label-sm text-label-sm uppercase">
<span>ÁRBITROS FEDERADOS: <b class="text-on-surface">ASIGNADOS</b></span>
<span>VAR CENTRALIZADO: <b class="text-secondary font-bold">ONLINE</b></span>
<span>ESTADIO NACIONAL • SAN JOSÉ</span>
</div>
</section>
<!-- Hero Editorial Section -->
<section class="relative w-full bg-primary text-on-primary px-margin py-space-xl overflow-hidden" data-original-section="1">
<!-- Subtle Architectural Background Grids and Scrim -->
<div class="absolute inset-0 opacity-15 pointer-events-none bg-[radial-gradient(#ffffff_1px,transparent_1px)] [background-size:24px_24px]"></div>
<div class="absolute -right-24 -bottom-24 w-96 h-96 bg-secondary/20 rounded-full blur-3xl pointer-events-none"></div>
<div class="relative z-10 flex flex-col lg:flex-row items-start lg:items-end justify-between gap-space-xl">
<div class="flex flex-col max-w-3xl space-y-space-md">
<div class="flex flex-wrap items-center gap-space-sm">
<span class="bg-secondary text-on-secondary px-space-sm py-0.5 rounded font-label-sm text-label-sm uppercase tracking-widest font-bold">TORNEO ACTIVO • SEMIFINALES CONCLUIDAS</span>
<span class="bg-primary-container text-on-primary-container px-space-sm py-0.5 rounded font-label-sm text-label-sm uppercase tracking-wider">OFICIAL FCRF • TEMPORADA 2026</span>
</div>
<div class="space-y-space-xs">
<p class="font-label-md text-label-md uppercase tracking-widest text-secondary-fixed">TORNEO MÁXIMO DE CATEGORÍA SUPERIOR</p>
<h1 class="font-headline-xl text-headline-xl uppercase tracking-tighter text-on-primary">COPA PREMIER NACIONAL 2026</h1>
</div>
<p class="font-body-lg text-body-lg text-primary-fixed max-w-2xl">
          El torneo cumbre de eliminación directa reúne a los mejores 16 clubes de Costa Rica en una batalla sin margen de error. Tras duelos intensos, la corona se disputará en el Clásico Nacional definitivo.
        </p>
<!-- Quick Spec Tags -->
<div class="grid grid-cols-2 sm:grid-cols-3 gap-space-md pt-space-sm">
<div class="bg-primary-container/80 p-space-md rounded-lg">
<span class="font-label-sm text-label-sm text-on-primary-container uppercase block">PERIODO OFICIAL</span>
<span class="font-title-sm text-title-sm text-on-primary uppercase">15 OCT - 30 NOV</span>
</div>
<div class="bg-primary-container/80 p-space-md rounded-lg">
<span class="font-label-sm text-label-sm text-on-primary-container uppercase block">BOLSA DE PREMIOS</span>
<span class="font-title-sm text-title-sm text-secondary font-bold">₡ 5,000,000 CRC</span>
</div>
<div class="bg-primary-container/80 p-space-md rounded-lg col-span-2 sm:col-span-1">
<span class="font-label-sm text-label-sm text-on-primary-container uppercase block">FASE EN CURSO</span>
<span class="font-title-sm text-title-sm text-on-primary uppercase flex items-center gap-1">
<span class="material-symbols-outlined text-[16px] text-secondary">verified</span>
              GRAN FINAL
            </span>
</div>
</div>
<!-- Hero Actions -->
<div class="flex flex-wrap items-center gap-space-md pt-space-md">
<a class="bg-secondary hover:bg-secondary/90 text-on-secondary px-space-lg py-space-md rounded font-label-md text-label-md uppercase tracking-wider flex items-center gap-space-sm transition-all transform active:scale-95 shadow-md" data-path="cuadro-eliminatorio" href="#">
<span>Explorar Cuadro Eliminatorio</span>
<span class="material-symbols-outlined text-[18px]">account_tree</span>
</a>
<a class="bg-surface-container-highest/20 hover:bg-surface-container-highest/30 text-on-primary px-space-lg py-space-md rounded font-label-md text-label-md uppercase tracking-wider flex items-center gap-space-sm transition-all" href="#resultados-recientes">
<span>Ver Resultados en Vivo</span>
<span class="material-symbols-outlined text-[18px]">scoreboard</span>
</a>
</div>
</div>
<!-- Hero Visual Card / Trophy Badge -->
<div class="w-full lg:w-96 bg-primary-container p-space-lg rounded-xl shadow-xl flex flex-col justify-between self-stretch">
<div class="flex items-center justify-between">
<span class="font-label-sm text-label-sm text-secondary uppercase font-bold tracking-widest">TROFEO CLAUSURA</span>
<span class="material-symbols-outlined text-secondary text-[24px]">military_tech</span>
</div>
<div class="my-space-md relative overflow-hidden rounded-lg bg-tertiary-container h-44 flex items-center justify-center">
<img class="w-full h-full object-cover mix-blend-luminosity hover:mix-blend-normal transition-all duration-500 scale-105" data-alt="Official Tournament Trophy of Copa Premier, high contrast professional studio photography on dark slate texture, glowing reflections of gold and amber metal, sharp sports editorial presentation" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBMOu45swSCeoJmuOEeq8TgU5M1AcXK7-SUF5b39F3DfyVbIEc1jTKkHXgL-LIhqhw5VnF37gfCgH0KrH2vKlXg_Tkt7JRm1-L8gZPKa8bNx9vrG5Jp8yqI8528b5DvGneWfwGVDeGm3uv9fqNzIjCIpyaKYfAwHYIvIV1_6aXmMpk0HqhCaQN4ZDYWsnM4h4rc0zgUSlhFeSEw3jjt24RJI8xr-_FXJctD_jdesW4"/>
<div class="absolute inset-0 bg-gradient-to-t from-primary-container via-transparent to-transparent"></div>
<div class="absolute bottom-2 left-3 right-3 flex items-center justify-between text-on-primary">
<span class="font-label-sm text-label-sm uppercase font-bold text-secondary-fixed">Copa Premier 2026</span>
<span class="font-label-sm text-label-sm bg-primary/80 px-2 py-0.5 rounded">₡ 3.5M al Campeón</span>
</div>
</div>
<div class="space-y-space-xs">
<div class="flex justify-between font-label-sm text-label-sm text-on-primary-container uppercase">
<span>PROGRESO DEL TORNEO</span>
<span class="text-on-primary font-bold">12 / 15 PARTIDOS</span>
</div>
<div class="w-full h-2 rounded bg-surface-container-highest/30 overflow-hidden">
<div class="h-full bg-secondary rounded" style="width: 80%;"></div>
</div>
<div class="flex justify-between font-body-sm text-body-sm text-on-primary-container pt-1">
<span>Octavos: 8/8</span>
<span>Cuartos: 4/4</span>
<span class="text-secondary font-bold">Semis: 2/2</span>
</div>
</div>
</div>
</div>
</section>
<!-- Official KPIs Metrics Grid -->
<section class="w-full px-margin -mt-6 z-20" data-original-section="2">
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-space-md">
<!-- KPI 1 -->
<div class="bg-surface p-space-lg rounded-xl shadow-md flex items-center justify-between hover:shadow-lg transition-shadow">
<div class="space-y-1">
<p class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wider">EQUIPOS PARTICIPANTES</p>
<p class="font-headline-lg text-headline-lg text-primary font-bold">16</p>
<p class="font-body-sm text-body-sm text-on-surface-variant">Representantes de 7 provincias</p>
</div>
<div class="w-12 h-12 rounded-lg bg-surface-container-high flex items-center justify-center text-primary">
<span class="material-symbols-outlined text-[28px]">shield</span>
</div>
</div>
<!-- KPI 2 -->
<div class="bg-surface p-space-lg rounded-xl shadow-md flex items-center justify-between hover:shadow-lg transition-shadow">
<div class="space-y-1">
<p class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wider">TOTAL PARTIDOS</p>
<p class="font-headline-lg text-headline-lg text-primary font-bold">15</p>
<p class="font-body-sm text-body-sm text-on-surface-variant">4 rondas sin revancha</p>
</div>
<div class="w-12 h-12 rounded-lg bg-surface-container-high flex items-center justify-center text-primary">
<span class="material-symbols-outlined text-[28px]">sports_soccer</span>
</div>
</div>
<!-- KPI 3 -->
<div class="bg-surface p-space-lg rounded-xl shadow-md flex items-center justify-between hover:shadow-lg transition-shadow">
<div class="space-y-1">
<p class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wider">PARTIDOS JUGADOS</p>
<div class="flex items-baseline gap-2">
<p class="font-headline-lg text-headline-lg text-secondary font-bold">12</p>
<span class="font-label-sm text-label-sm px-2 py-0.5 rounded bg-secondary-container text-on-secondary-container font-bold">80% AVANCE</span>
</div>
<p class="font-body-sm text-body-sm text-on-surface-variant">3 partidos restantes (Final y 3er)</p>
</div>
<div class="w-12 h-12 rounded-lg bg-secondary-container flex items-center justify-center text-on-secondary-container">
<span class="material-symbols-outlined text-[28px]">task_alt</span>
</div>
</div>
<!-- KPI 4 -->
<div class="bg-surface p-space-lg rounded-xl shadow-md flex items-center justify-between hover:shadow-lg transition-shadow">
<div class="space-y-1">
<p class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wider">GOLES ANOTADOS</p>
<p class="font-headline-lg text-headline-lg text-primary font-bold">32</p>
<p class="font-body-sm text-body-sm text-on-surface-variant">Promedio: 2.67 por encuentro</p>
</div>
<div class="w-12 h-12 rounded-lg bg-surface-container-high flex items-center justify-center text-primary">
<span class="material-symbols-outlined text-[28px]">analytics</span>
</div>
</div>
</div>
</section>
<!-- Big Match Banner: LA GRAN FINAL -->
<section class="w-full px-margin pt-space-xl" data-original-section="3">
<div class="bg-surface-container-lowest rounded-xl p-space-lg lg:p-space-xl shadow-md">
<!-- Section Header -->
<div class="flex flex-col md:flex-row md:items-center justify-between pb-space-lg gap-space-sm">
<div>
<span class="font-label-sm text-label-sm uppercase tracking-widest text-secondary font-bold">EL COMBATE POR EL TÍTULO</span>
<h2 class="font-headline-lg text-headline-lg uppercase text-on-surface">LA GRAN FINAL NACIONAL</h2>
</div>
<!-- Live Countdown Module -->
<div class="bg-surface-container px-space-md py-space-sm rounded-lg flex items-center gap-space-md">
<div class="flex items-center gap-1.5 text-secondary">
<span class="material-symbols-outlined text-[20px]">timer</span>
<span class="font-label-md text-label-md uppercase font-bold">CUENTA REGRESIVA:</span>
</div>
<div class="flex items-center gap-2 font-headline-md text-headline-md text-primary font-bold">
<span class="bg-surface px-2 py-0.5 rounded shadow-sm">02</span><span class="text-on-surface-variant text-[14px]">D</span>
<span class="bg-surface px-2 py-0.5 rounded shadow-sm">14</span><span class="text-on-surface-variant text-[14px]">H</span>
<span class="bg-surface px-2 py-0.5 rounded shadow-sm">35</span><span class="text-on-surface-variant text-[14px]">M</span>
</div>
</div>
</div>
<!-- Finalists Versus Showcase -->
<div class="grid grid-cols-1 lg:grid-cols-12 gap-space-lg items-center">
<!-- Finalist 1: Saprissa -->
<div class="lg:col-span-5 bg-surface-container-low p-space-lg rounded-xl flex flex-col justify-between space-y-space-md">
<div class="flex items-center justify-between">
<span class="px-2.5 py-1 rounded bg-primary text-on-primary font-label-sm text-label-sm uppercase font-bold">SEMIFINALISTA A (SEED #1)</span>
<span class="font-label-sm text-label-sm text-on-surface-variant uppercase">3 VICTORIAS EN TORNEO</span>
</div>
<div class="flex items-center gap-space-md">
<div class="w-16 h-16 rounded-xl bg-tertiary text-on-tertiary flex items-center justify-center font-headline-lg text-headline-lg font-bold shadow-md shrink-0">
              S
            </div>
<div>
<h3 class="font-headline-md text-headline-md uppercase text-on-surface">DEPORTIVO SAPRISSA</h3>
<p class="font-body-sm text-body-sm text-on-surface-variant">Máximo goleador: Christian Bolaños (3 goles)</p>
</div>
</div>
<!-- Team Stats Pre-Match -->
<div class="space-y-space-xs pt-space-xs">
<div class="flex justify-between font-label-sm text-label-sm uppercase text-on-surface-variant">
<span>POSESIÓN MEDIA</span>
<span class="text-on-surface font-bold">58.4%</span>
</div>
<div class="w-full h-1.5 bg-surface-container-high rounded overflow-hidden">
<div class="bg-primary h-full rounded" style="width: 58.4%;"></div>
</div>
<div class="flex justify-between font-label-sm text-label-sm uppercase text-on-surface-variant pt-1">
<span>EFECTIVIDAD DE TIROS</span>
<span class="text-on-surface font-bold">42.1%</span>
</div>
<div class="w-full h-1.5 bg-surface-container-high rounded overflow-hidden">
<div class="bg-primary h-full rounded" style="width: 42.1%;"></div>
</div>
</div>
</div>
<!-- Center Match Metadata / VS Emblem -->
<div class="lg:col-span-2 flex flex-col items-center justify-center text-center space-y-space-sm py-space-sm">
<div class="w-14 h-14 rounded-full bg-secondary text-on-secondary font-headline-md text-headline-md flex items-center justify-center shadow-lg font-bold">
            VS
          </div>
<div class="space-y-0.5">
<p class="font-label-md text-label-md uppercase text-on-surface font-bold">DOMINGO 20:00 CST</p>
<p class="font-body-sm text-body-sm text-on-surface-variant">Estadio Nacional de Costa Rica</p>
<p class="font-label-sm text-label-sm text-secondary uppercase font-bold">TRANSMISIÓN NACIONAL FHD</p>
</div>
<button class="mt-2 bg-primary hover:bg-primary-container text-on-primary px-space-md py-space-xs rounded font-label-sm text-label-sm uppercase tracking-wider transition-colors shadow" type="button">
            Ficha Técnica
          </button>
</div>
<!-- Finalist 2: Alajuelense -->
<div class="lg:col-span-5 bg-surface-container-low p-space-lg rounded-xl flex flex-col justify-between space-y-space-md">
<div class="flex items-center justify-between">
<span class="px-2.5 py-1 rounded bg-secondary text-on-secondary font-label-sm text-label-sm uppercase font-bold">SEMIFINALISTA B (SEED #2)</span>
<span class="font-label-sm text-label-sm text-on-surface-variant uppercase">3 VICTORIAS EN TORNEO</span>
</div>
<div class="flex items-center gap-space-md">
<div class="w-16 h-16 rounded-xl bg-error text-on-error flex items-center justify-center font-headline-lg text-headline-lg font-bold shadow-md shrink-0">
              LDA
            </div>
<div>
<h3 class="font-headline-md text-headline-md uppercase text-on-surface">L.D. ALAJUELENSE</h3>
<p class="font-body-sm text-body-sm text-on-surface-variant">Máximo goleador: Joel Campbell (4 goles)</p>
</div>
</div>
<!-- Team Stats Pre-Match -->
<div class="space-y-space-xs pt-space-xs">
<div class="flex justify-between font-label-sm text-label-sm uppercase text-on-surface-variant">
<span>POSESIÓN MEDIA</span>
<span class="text-on-surface font-bold">61.2%</span>
</div>
<div class="w-full h-1.5 bg-surface-container-high rounded overflow-hidden">
<div class="bg-secondary h-full rounded" style="width: 61.2%;"></div>
</div>
<div class="flex justify-between font-label-sm text-label-sm uppercase text-on-surface-variant pt-1">
<span>EFECTIVIDAD DE TIROS</span>
<span class="text-on-surface font-bold">46.8%</span>
</div>
<div class="w-full h-1.5 bg-surface-container-high rounded overflow-hidden">
<div class="bg-secondary h-full rounded" style="width: 46.8%;"></div>
</div>
</div>
</div>
</div>
</div>
</section>
<!-- Recent Matches & Semi-Final Highlights Section -->
<section class="w-full px-margin pt-space-xl" data-original-section="4" id="resultados-recientes">
<div class="flex flex-col md:flex-row md:items-end justify-between gap-space-sm mb-space-lg">
<div>
<span class="font-label-sm text-label-sm uppercase tracking-widest text-secondary font-bold">FASE DE SEMIFINALES CONCLUIDA</span>
<h2 class="font-headline-lg text-headline-lg uppercase text-on-surface">ENFRENTAMIENTOS DESTACADOS</h2>
</div>
<div class="flex items-center gap-space-xs">
<span class="font-label-sm text-label-sm uppercase text-on-surface-variant mr-2">VER FILTROS:</span>
<button class="bg-primary text-on-primary font-label-sm text-label-sm uppercase px-3 py-1.5 rounded" type="button">Semifinales</button>
<button class="bg-surface-container text-on-surface font-label-sm text-label-sm uppercase px-3 py-1.5 rounded hover:bg-surface-container-high" type="button">Cuartos</button>
<button class="bg-surface-container text-on-surface font-label-sm text-label-sm uppercase px-3 py-1.5 rounded hover:bg-surface-container-high" type="button">Octavos</button>
</div>
</div>
<!-- Match Cards Grid -->
<div class="grid grid-cols-1 lg:grid-cols-2 gap-space-lg">
<!-- Match Card A -->
<div class="bg-surface rounded-xl shadow-md p-space-lg flex flex-col justify-between space-y-space-md">
<!-- Card Header -->
<div class="flex items-center justify-between pb-space-sm">
<div class="flex items-center gap-space-xs">
<span class="w-2 h-2 rounded-full bg-on-surface-variant"></span>
<span class="font-label-sm text-label-sm uppercase font-bold text-on-surface">SEMIFINAL A • FINALIZADO</span>
</div>
<span class="font-label-sm text-label-sm text-on-surface-variant uppercase">Jueves 24 Nov • Estadio Ricardo Saprissa</span>
</div>
<!-- Competitor Score Rows -->
<div class="space-y-space-xs">
<!-- Row 1 Winner -->
<div class="bg-surface-container-high p-space-md rounded-lg flex items-center justify-between">
<div class="flex items-center gap-space-md">
<span class="font-label-sm text-label-sm bg-primary text-on-primary px-2 py-0.5 rounded font-bold">#1</span>
<div>
<span class="font-title-sm text-title-sm font-bold text-on-surface uppercase">DEPORTIVO SAPRISSA</span>
<span class="block font-body-sm text-body-sm text-secondary font-bold">Clasificado a Gran Final</span>
</div>
</div>
<div class="flex items-center gap-space-md">
<div class="font-label-sm text-label-sm text-on-surface-variant text-right hidden sm:block">
<span>(1 - 0 HT)</span>
</div>
<span class="font-headline-lg text-headline-lg font-bold text-primary">3</span>
</div>
</div>
<!-- Row 2 Loser -->
<div class="bg-surface-container-low p-space-md rounded-lg flex items-center justify-between">
<div class="flex items-center gap-space-md">
<span class="font-label-sm text-label-sm bg-surface-container-highest text-on-surface px-2 py-0.5 rounded font-bold">#4</span>
<div>
<span class="font-title-sm text-title-sm text-on-surface-variant uppercase">C.S. CARTAGINÉS</span>
<span class="block font-body-sm text-body-sm text-on-surface-variant">Disputa 3er Puesto</span>
</div>
</div>
<div class="flex items-center gap-space-md">
<div class="font-label-sm text-label-sm text-on-surface-variant text-right hidden sm:block">
<span>(Gol al 78')</span>
</div>
<span class="font-headline-lg text-headline-lg font-bold text-on-surface-variant">1</span>
</div>
</div>
</div>
<!-- Key Moments Chips -->
<div class="bg-surface-container-lowest p-space-sm rounded-lg flex flex-wrap items-center gap-space-sm font-body-sm text-body-sm text-on-surface-variant">
<span class="font-label-sm text-label-sm uppercase font-bold text-on-surface">CLAVES:</span>
<span>Goles: Guzmán (14'), Sinclair (52', 88') • Guevara (78')</span>
<span>• Posesión: 54% - 46%</span>
</div>
<!-- Card Action Footer -->
<div class="flex items-center justify-between pt-space-xs">
<button class="flex items-center gap-1.5 font-label-md text-label-md text-secondary hover:text-secondary/80 uppercase font-bold transition-colors" type="button">
<span class="material-symbols-outlined text-[18px]">play_circle</span>
<span>Ver Replay Animado</span>
</button>
<button class="bg-surface-container hover:bg-surface-container-high text-on-surface px-space-md py-space-xs rounded font-label-sm text-label-sm uppercase font-bold transition-colors" type="button">
            Estadísticas Completas
          </button>
</div>
</div>
<!-- Match Card B -->
<div class="bg-surface rounded-xl shadow-md p-space-lg flex flex-col justify-between space-y-space-md">
<!-- Card Header -->
<div class="flex items-center justify-between pb-space-sm">
<div class="flex items-center gap-space-xs">
<span class="w-2 h-2 rounded-full bg-on-surface-variant"></span>
<span class="font-label-sm text-label-sm uppercase font-bold text-on-surface">SEMIFINAL B • FINALIZADO</span>
</div>
<span class="font-label-sm text-label-sm text-on-surface-variant uppercase">Viernes 25 Nov • Estadio Morera Soto</span>
</div>
<!-- Competitor Score Rows -->
<div class="space-y-space-xs">
<!-- Row 1 Winner -->
<div class="bg-surface-container-high p-space-md rounded-lg flex items-center justify-between">
<div class="flex items-center gap-space-md">
<span class="font-label-sm text-label-sm bg-primary text-on-primary px-2 py-0.5 rounded font-bold">#2</span>
<div>
<span class="font-title-sm text-title-sm font-bold text-on-surface uppercase">L.D. ALAJUELENSE</span>
<span class="block font-body-sm text-body-sm text-secondary font-bold">Clasificado a Gran Final</span>
</div>
</div>
<div class="flex items-center gap-space-md">
<div class="font-label-sm text-label-sm text-on-surface-variant text-right hidden sm:block">
<span>(Gol de penal al 90+2')</span>
</div>
<span class="font-headline-lg text-headline-lg font-bold text-primary">2</span>
</div>
</div>
<!-- Row 2 Loser -->
<div class="bg-surface-container-low p-space-md rounded-lg flex items-center justify-between">
<div class="flex items-center gap-space-md">
<span class="font-label-sm text-label-sm bg-surface-container-highest text-on-surface px-2 py-0.5 rounded font-bold">#3</span>
<div>
<span class="font-title-sm text-title-sm text-on-surface-variant uppercase">C.S. HEREDIANO</span>
<span class="block font-body-sm text-body-sm text-on-surface-variant">Disputa 3er Puesto</span>
</div>
</div>
<div class="flex items-center gap-space-md">
<div class="font-label-sm text-label-sm text-on-surface-variant text-right hidden sm:block">
<span>(1 - 1 HT)</span>
</div>
<span class="font-headline-lg text-headline-lg font-bold text-on-surface-variant">1</span>
</div>
</div>
</div>
<!-- Key Moments Chips -->
<div class="bg-surface-container-lowest p-space-sm rounded-lg flex flex-wrap items-center gap-space-sm font-body-sm text-body-sm text-on-surface-variant">
<span class="font-label-sm text-label-sm uppercase font-bold text-on-surface">CLAVES:</span>
<span>Goles: Campbell (31'), Moya (90+2' P) • Aguilar (44')</span>
<span>• Posesión: 63% - 37%</span>
</div>
<!-- Card Action Footer -->
<div class="flex items-center justify-between pt-space-xs">
<button class="flex items-center gap-1.5 font-label-md text-label-md text-secondary hover:text-secondary/80 uppercase font-bold transition-colors" type="button">
<span class="material-symbols-outlined text-[18px]">play_circle</span>
<span>Ver Replay Animado</span>
</button>
<button class="bg-surface-container hover:bg-surface-container-high text-on-surface px-space-md py-space-xs rounded font-label-sm text-label-sm uppercase font-bold transition-colors" type="button">
            Estadísticas Completas
          </button>
</div>
</div>
</div>
</section>
<!-- Editorial Tournament Analytics Mini-Hub -->
<section class="w-full px-margin pt-space-xl" data-original-section="5">
<div class="grid grid-cols-1 lg:grid-cols-12 gap-space-lg">
<!-- Leaderboard / Golden Boot -->
<div class="lg:col-span-7 bg-surface rounded-xl p-space-lg shadow-md flex flex-col justify-between">
<div class="flex items-center justify-between pb-space-sm">
<div>
<span class="font-label-sm text-label-sm uppercase tracking-widest text-secondary font-bold">LÍDERES DE RENDIMIENTO</span>
<h3 class="font-headline-md text-headline-md uppercase text-on-surface">TABLA DE GOLEO INDIVIDUAL</h3>
</div>
<span class="font-label-sm text-label-sm bg-surface-container-high px-2.5 py-1 rounded text-on-surface uppercase">BOTA DE ORO</span>
</div>
<div class="overflow-x-auto">
<table class="w-full text-left">
<thead>
<tr class="bg-surface-container-high text-on-surface-variant font-label-sm text-label-sm uppercase">
<th class="py-2.5 px-3">POS</th>
<th class="py-2.5 px-3">JUGADOR</th>
<th class="py-2.5 px-3">CLUB</th>
<th class="py-2.5 px-3 text-center">PARTIDOS</th>
<th class="py-2.5 px-3 text-center">GOLES</th>
<th class="py-2.5 px-3 text-right">EFICACIA</th>
</tr>
</thead>
<tbody class="divide-y divide-transparent font-body-md text-body-md text-on-surface">
<tr class="bg-surface-container-lowest hover:bg-surface-container-low transition-colors">
<td class="py-2.5 px-3 font-bold text-secondary">01</td>
<td class="py-2.5 px-3 font-title-sm text-title-sm uppercase">Joel Campbell</td>
<td class="py-2.5 px-3 text-on-surface-variant">L.D. Alajuelense</td>
<td class="py-2.5 px-3 text-center">3</td>
<td class="py-2.5 px-3 text-center font-bold text-primary">4</td>
<td class="py-2.5 px-3 text-right font-label-sm text-label-sm font-bold">1.33 G/P</td>
</tr>
<tr class="bg-surface hover:bg-surface-container-low transition-colors">
<td class="py-2.5 px-3 font-bold">02</td>
<td class="py-2.5 px-3 font-title-sm text-title-sm uppercase">Orlando Sinclair</td>
<td class="py-2.5 px-3 text-on-surface-variant">Deportivo Saprissa</td>
<td class="py-2.5 px-3 text-center">3</td>
<td class="py-2.5 px-3 text-center font-bold text-primary">3</td>
<td class="py-2.5 px-3 text-right font-label-sm text-label-sm font-bold">1.00 G/P</td>
</tr>
<tr class="bg-surface-container-lowest hover:bg-surface-container-low transition-colors">
<td class="py-2.5 px-3 font-bold">03</td>
<td class="py-2.5 px-3 font-title-sm text-title-sm uppercase">Erick Torres</td>
<td class="py-2.5 px-3 text-on-surface-variant">A.D. Guanacasteca</td>
<td class="py-2.5 px-3 text-center">2</td>
<td class="py-2.5 px-3 text-center font-bold text-primary">2</td>
<td class="py-2.5 px-3 text-right font-label-sm text-label-sm font-bold">1.00 G/P</td>
</tr>
<tr class="bg-surface hover:bg-surface-container-low transition-colors">
<td class="py-2.5 px-3 font-bold">04</td>
<td class="py-2.5 px-3 font-title-sm text-title-sm uppercase">Elias Aguilar</td>
<td class="py-2.5 px-3 text-on-surface-variant">C.S. Herediano</td>
<td class="py-2.5 px-3 text-center">3</td>
<td class="py-2.5 px-3 text-center font-bold text-primary">2</td>
<td class="py-2.5 px-3 text-right font-label-sm text-label-sm font-bold">0.67 G/P</td>
</tr>
</tbody>
</table>
</div>
<div class="pt-space-md flex items-center justify-between text-on-surface-variant font-body-sm text-body-sm">
<span>Actualizado al minuto tras Semifinal B</span>
<a class="font-label-sm text-label-sm uppercase text-primary font-bold hover:underline flex items-center gap-1" href="#">
<span>Rosters y Plantillas</span>
<span class="material-symbols-outlined text-[14px]">arrow_forward</span>
</a>
</div>
</div>
<!-- Fair Play & Fast Tournament Stats -->
<div class="lg:col-span-5 bg-surface rounded-xl p-space-lg shadow-md flex flex-col justify-between space-y-space-md">
<div>
<span class="font-label-sm text-label-sm uppercase tracking-widest text-secondary font-bold">DISCIPLINA Y CONTROL</span>
<h3 class="font-headline-md text-headline-md uppercase text-on-surface">DISCIPLINA DEL TORNEO</h3>
</div>
<!-- Metric visual breakdown -->
<div class="grid grid-cols-2 gap-space-md">
<div class="bg-surface-container p-space-md rounded-lg text-center">
<span class="font-headline-lg text-headline-lg font-bold text-on-surface block">38</span>
<span class="font-label-sm text-label-sm text-on-surface-variant uppercase">TARJETAS AMARILLAS</span>
<span class="block font-body-sm text-body-sm text-on-surface-variant mt-1">3.1 por encuentro</span>
</div>
<div class="bg-surface-container p-space-md rounded-lg text-center">
<span class="font-headline-lg text-headline-lg font-bold text-error block">3</span>
<span class="font-label-sm text-label-sm text-on-surface-variant uppercase">TARJETAS ROJAS</span>
<span class="block font-body-sm text-body-sm text-on-surface-variant mt-1">0.25 por encuentro</span>
</div>
</div>
<!-- Clean Sheet Club -->
<div class="bg-surface-container-low p-space-md rounded-lg space-y-1">
<div class="flex items-center justify-between font-label-sm text-label-sm uppercase">
<span class="text-on-surface font-bold">VALLA MENOS VENCIDA</span>
<span class="text-secondary font-bold">SAPRISSA (1 GOL RECIBIDO)</span>
</div>
<p class="font-body-sm text-body-sm text-on-surface-variant">Esteban Alvarado acumula 2 porterías a cero en 3 encuentros de fase eliminatoria.</p>
</div>
<div class="flex items-center justify-between pt-space-xs font-label-sm text-label-sm">
<span class="text-on-surface-variant uppercase">TRIBUNAL DISCIPLINARIO</span>
<span class="px-2 py-0.5 rounded bg-surface-container-high text-on-surface uppercase font-bold">0 SANCIONES PENDIENTES</span>
</div>
</div>
</div>
</section>
<!-- CTA Portal: Registration & Directors Gate -->
<section class="w-full px-margin pt-space-xl" data-original-section="6">
<div class="bg-tertiary text-on-tertiary rounded-xl p-space-lg lg:p-space-xl shadow-xl relative overflow-hidden">
<!-- Glow ambient accent -->
<div class="absolute -left-20 top-0 w-72 h-72 bg-secondary/15 rounded-full blur-3xl pointer-events-none"></div>
<div class="relative z-10 grid grid-cols-1 lg:grid-cols-12 gap-space-xl items-center">
<div class="lg:col-span-8 space-y-space-sm">
<span class="px-2.5 py-1 rounded bg-secondary text-on-secondary font-label-sm text-label-sm uppercase font-bold tracking-widest">
            TEMPORADA APERTURA 2026
          </span>
<h2 class="font-headline-lg text-headline-lg uppercase text-on-tertiary">
            ¿DESEAS REGISTRAR A TU CLUB O FEDERACIÓN?
          </h2>
<p class="font-body-lg text-body-lg text-tertiary-fixed-dim max-w-2xl">
            La convocatoria para el próximo certamen eliminatorio de BRACKET ARENA ya está en precalificación. Registra tu nómina oficial de jugadores, certifica al cuerpo técnico y asegura tu puesto en el cuadro de 16 equipos.
          </p>
<!-- Capacity Bar -->
<div class="pt-space-sm max-w-md space-y-1">
<div class="flex justify-between font-label-sm text-label-sm uppercase text-tertiary-fixed">
<span>CUPOS TORNEO ACTUAL</span>
<span class="font-bold text-secondary-fixed">16 / 16 (LLENO COMPLETO)</span>
</div>
<div class="w-full h-2 bg-tertiary-container rounded overflow-hidden">
<div class="bg-secondary h-full rounded" style="width: 100%;"></div>
</div>
<span class="font-body-sm text-body-sm text-tertiary-fixed-variant">Lista de espera abierta para Torneo Apertura 2026.</span>
</div>
</div>
<div class="lg:col-span-4 flex flex-col gap-space-sm">
<button class="w-full bg-secondary hover:bg-secondary/90 text-on-secondary py-space-md px-space-lg rounded font-label-md text-label-md uppercase tracking-wider text-center transition-all shadow-md" type="button">
            Solicitar Inscripción de Equipo
          </button>
<a class="w-full bg-tertiary-container hover:bg-tertiary-container/80 text-on-tertiary py-space-md px-space-lg rounded font-label-md text-label-md uppercase tracking-wider text-center transition-all" data-path="panel-de-administracion" href="#">
            Acceso a Panel de Directivos
          </a>
</div>
</div>
</div>
</section>
<!-- Tournament Rulebook & Partners Summary -->
<section class="w-full px-margin pt-space-xl" data-original-section="7">
<div class="bg-surface rounded-xl p-space-lg shadow-sm space-y-space-lg">
<div class="grid grid-cols-1 md:grid-cols-3 gap-space-lg">
<!-- Pillar 1 -->
<div class="space-y-space-xs">
<div class="flex items-center gap-space-xs text-primary">
<span class="material-symbols-outlined text-[20px] text-secondary">bolt</span>
<h4 class="font-title-sm text-title-sm uppercase font-bold">Muerte Súbita Pura</h4>
</div>
<p class="font-body-md text-body-md text-on-surface-variant">
            Sin partido de vuelta. En caso de empate tras los 90 minutos reglamentarios, se disputan 2 tiempos extra de 15 minutos. De persistir, definición por tanda de penales FIFA.
          </p>
</div>
<!-- Pillar 2 -->
<div class="space-y-space-xs">
<div class="flex items-center gap-space-xs text-primary">
<span class="material-symbols-outlined text-[20px] text-secondary">group</span>
<h4 class="font-title-sm text-title-sm uppercase font-bold">Rosters Blindados</h4>
</div>
<p class="font-body-md text-body-md text-on-surface-variant">
            Límite de 23 futbolistas inscritos por plantilla. Modificaciones únicamente permitidas por lesión grave certificada por el comité médico oficial previo a cuartos de final.
          </p>
</div>
<!-- Pillar 3 -->
<div class="space-y-space-xs">
<div class="flex items-center gap-space-xs text-primary">
<span class="material-symbols-outlined text-[20px] text-secondary">verified_user</span>
<h4 class="font-title-sm text-title-sm uppercase font-bold">Garantía Fair Play</h4>
</div>
<p class="font-body-md text-body-md text-on-surface-variant">
            Revisión automática de videoarbitraje en todas las fases. Dos tarjetas amarillas conllevan suspensión automática de un partido para la siguiente ronda inmediata.
          </p>
</div>
</div>
<!-- Official Tournament Sponsors -->
<div class="pt-space-md">
<span class="font-label-sm text-label-sm uppercase tracking-widest text-on-surface-variant font-bold block mb-space-sm text-center">
          PATROCINADORES OFICIALES Y ALIADOS DEL TORNEO
        </span>
<div class="flex flex-wrap items-center justify-center gap-space-xl opacity-60 grayscale hover:grayscale-0 transition-all">
<span class="font-headline-md text-headline-md uppercase tracking-tighter text-on-surface">BANCO COSTA SPORT</span>
<span class="font-headline-md text-headline-md uppercase tracking-tighter text-on-surface">ICE BEVERAGE LABS</span>
<span class="font-headline-md text-headline-md uppercase tracking-tighter text-on-surface">TITAN APPAREL</span>
<span class="font-headline-md text-headline-md uppercase tracking-tighter text-on-surface">PACIFIC TELECOM</span>
</div>
</div>
</div>
</section>
</div></main><footer class="w-full bg-surface-container-low py-space-xl mt-space-xl"><div class="w-full px-margin flex flex-col md:flex-row items-center justify-between gap-space-md"><div class="flex items-center gap-space-sm"><div class="w-6 h-6 rounded bg-primary flex items-center justify-center"><span class="material-symbols-outlined text-secondary text-[14px]">emoji_events</span></div><span class="font-headline-md text-headline-md uppercase text-on-surface">BRACKET ARENA</span></div><div class="font-body-sm text-body-sm text-on-surface-variant text-center">© 2026 Bracket Arena Technologies. Sistema Profesional de Gestión de Torneos Eliminatorios.</div><div class="flex items-center gap-space-md font-label-sm text-label-sm text-on-surface-variant uppercase"><a class="hover:text-on-surface transition-colors" href="#">Reglamento</a><a class="hover:text-on-surface transition-colors" href="#">Soporte</a><a class="hover:text-on-surface transition-colors" href="#">API Torneo</a></div></div></footer><script>window.ARENA_BASE = '<%=request.getContextPath()%>';</script><script defer="" src="<%=request.getContextPath()%>/js/stitch-runtime.js?v=2026-11-25-mobile-r4"></script></body></html>