<%--
  BRACKET ARENA / PANTALLA: Panel administrativo: aprobación de equipos y gestión de partidos.
  Origen: HTML y clases originales de Stitch aportados al proyecto.
  Los datos y permisos se actualizan mediante /arena-data y stitch-runtime.js.
  La maquetación exportada se conserva sin reindentación para no cambiar su aspecto.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html class="light" lang="es"><head><meta charset="utf-8"/><meta content="width=device-width, initial-scale=1.0" name="viewport"/><meta content="web_standard" name="shell-type"/><link href="https://fonts.googleapis.com" rel="preconnect"/><link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&amp;family=Space+Grotesk:wght@600;700&amp;display=swap" rel="preload" as="style" onload="this.onload=null;this.rel='stylesheet'"/><link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="preload" as="style" onload="this.onload=null;this.rel='stylesheet'"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="preload" as="style" onload="this.onload=null;this.rel='stylesheet'"/><style>@layer base{html,body{margin:0;padding:0;}body{overscroll-behavior:none;}main>:first-child{margin-top:0!important;}main>:last-child{margin-bottom:0!important;}}::-webkit-scrollbar{display:none;}</style><link href="<%=request.getContextPath()%>/css/stitch.css?v=2026-11-25-navbar-r2" rel="stylesheet"/><link href="<%=request.getContextPath()%>/css/stitch-bridge.css?v=2026-11-25-navbar-r2" rel="stylesheet"/></head><body class="bg-background font-body-md text-body-md text-on-surface antialiased arena-loading" data-arena-page="admin"><div aria-busy="true" aria-label="Cargando datos del torneo" id="arena-skeleton">
<div class="ske-nav"><div class="ske-block" style="width:160px;height:28px"></div><div class="ske-block" style="width:300px;height:16px"></div><div class="ske-block" style="width:120px;height:25px"></div></div>
<div class="ske-hero"><div><div class="ske-block" style="width:110px;height:14px"></div><div class="ske-block" style="width:80%;height:52px"></div><div class="ske-block" style="width:66%;height:18px"></div><div class="ske-block" style="width:73%;height:18px"></div><div class="ske-block" style="width:45%;height:35px"></div></div><div class="ske-block ske-cover"></div></div>
<div class="ske-cards"><div class="ske-block"></div><div class="ske-block"></div><div class="ske-block"></div><div class="ske-block"></div></div>
<div class="ske-panel"><div class="ske-block" style="width:35%;height:25px"></div><div class="ske-block" style="height:120px"></div><div class="ske-block" style="height:24px;width:70%"></div></div>
<div class="ske-panel"><div class="ske-block" style="width:42%;height:25px"></div><div class="ske-cards"><div class="ske-block"></div><div class="ske-block"></div></div></div>
</div><noscript><p style="padding:2rem;background:#fef3c7;color:#111">La interfaz necesita JavaScript para consultar los datos del torneo. Activá JavaScript para continuar.</p></noscript><%@ include file="partials/header.jspf" %><main class="w-full pt-28 bg-background min-h-screen" data-arena-main=""><% if (request.getAttribute("flash") != null) { %><div class="arena-flash <%= "error".equals(request.getAttribute("flashKind")) ? "error" : "" %>" role="status"><%=com.torneo.Web.esc(String.valueOf(request.getAttribute("flash")))%></div><% } %><div class="flex flex-col w-full">
<!-- Sub-bar: Admin Context & High-Frequency Operations -->
<div class="w-full bg-surface-container-high px-margin py-space-sm flex flex-wrap items-center justify-between gap-space-md">
<div class="flex items-center gap-space-md">
<div class="flex items-center gap-space-xs font-label-md text-label-md uppercase tracking-wider text-primary">
<span class="w-2.5 h-2.5 rounded-full bg-secondary animate-ping"></span>
<span class="font-headline-md text-headline-md tracking-tight">OPERACIONES LIVE //</span>
<span class="text-on-surface-variant font-body-md text-body-md">COPA PREMIER 2026</span>
</div>
<span class="bg-primary text-on-primary font-label-sm text-label-sm px-2 py-0.5 rounded uppercase">Edición Oficial</span>
</div>
<!-- Quick Status Pill & Global Seed State -->
<div class="flex items-center gap-space-sm">
<div class="hidden sm:flex items-center gap-2 bg-surface px-space-md py-1 rounded shadow-sm">
<span class="material-symbols-outlined text-[16px] text-secondary">lock</span>
<span class="font-label-sm text-label-sm uppercase text-on-surface tracking-wider">Cuadro Bloqueado (16/16 Seeds)</span>
</div>
<!-- Blocked New Tournament Launcher with Tooltip -->
<div class="relative group cursor-not-allowed">
<button class="opacity-50 bg-surface-container-highest text-on-surface-variant font-label-md text-label-md uppercase px-space-md py-2 rounded flex items-center gap-1.5 cursor-not-allowed" disabled="">
<span class="material-symbols-outlined text-[16px]">add_circle</span>
          Nuevo Torneo
        </button>
<div class="absolute right-0 top-full mt-2 hidden group-hover:flex flex-col w-64 p-3 bg-inverse-surface text-inverse-on-surface rounded shadow-xl z-50 pointer-events-none">
<div class="flex items-center gap-1.5 text-secondary-fixed mb-1 font-label-sm text-label-sm uppercase">
<span class="material-symbols-outlined text-[14px]">lock_clock</span>
            Acción Restringida
          </div>
<p class="font-body-sm text-body-sm leading-snug">
            Debe finalizarse el torneo actual y coronar campeón antes de crear un nuevo torneo eliminatorio.
          </p>
</div>
</div>
</div>
</div>
<!-- Main Administrative Canvas -->
<div class="w-full px-margin py-space-lg flex flex-col gap-space-xl">
<!-- 1. METRICS & CONTROL TELEMETRY -->
<section class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-gutter" data-original-section="0">
<!-- Metric 1 -->
<div class="bg-surface p-space-md rounded shadow-sm flex flex-col justify-between relative overflow-hidden group">
<div class="flex justify-between items-start">
<span class="font-label-sm text-label-sm uppercase text-on-surface-variant tracking-wider">Inscripción Oficial</span>
<span class="p-1.5 rounded bg-secondary-container text-on-secondary-container">
<span class="material-symbols-outlined text-[18px]">verified</span>
</span>
</div>
<div class="my-space-sm">
<div class="font-headline-xl text-headline-xl text-primary leading-none">16<span class="text-secondary font-headline-md text-headline-md">/16</span></div>
<div class="font-label-sm text-label-sm uppercase tracking-widest text-on-surface-variant mt-1">100% Cuota Aprobada</div>
</div>
<div class="w-full bg-surface-container-high h-1.5 rounded overflow-hidden">
<div class="bg-primary h-full w-full"></div>
</div>
</div>
<!-- Metric 2 -->
<div class="bg-surface p-space-md rounded shadow-sm flex flex-col justify-between relative overflow-hidden group">
<div class="flex justify-between items-start">
<span class="font-label-sm text-label-sm uppercase text-on-surface-variant tracking-wider">Partidos Disputados</span>
<span class="p-1.5 rounded bg-surface-container-high text-on-surface">
<span class="material-symbols-outlined text-[18px]">scoreboard</span>
</span>
</div>
<div class="my-space-sm">
<div class="font-headline-xl text-headline-xl text-primary leading-none">12<span class="text-on-surface-variant font-headline-md text-headline-md">/15</span></div>
<div class="font-label-sm text-label-sm uppercase tracking-widest text-on-surface-variant mt-1">Progreso 80% del Cuadro</div>
</div>
<div class="w-full bg-surface-container-high h-1.5 rounded overflow-hidden">
<div class="bg-secondary h-full" style="width: 80%;"></div>
</div>
</div>
<!-- Metric 3 -->
<div class="bg-surface p-space-md rounded shadow-sm flex flex-col justify-between relative overflow-hidden group">
<div class="flex justify-between items-start">
<span class="font-label-sm text-label-sm uppercase text-on-surface-variant tracking-wider">Partidos Pendientes</span>
<span class="p-1.5 rounded bg-secondary-container text-on-secondary-container">
<span class="material-symbols-outlined text-[18px] animate-pulse">pending_actions</span>
</span>
</div>
<div class="my-space-sm">
<div class="font-headline-xl text-headline-xl text-secondary leading-none">03</div>
<div class="font-label-sm text-label-sm uppercase tracking-widest text-on-surface-variant mt-1">2 Semis • 1 Gran Final</div>
</div>
<div class="flex items-center gap-1 font-body-sm text-body-sm text-on-surface-variant">
<span class="w-2 h-2 rounded-full bg-secondary"></span>
          Resolución Crítica Requerida
        </div>
</div>
<!-- Metric 4 -->
<div class="bg-surface p-space-md rounded shadow-sm flex flex-col justify-between relative overflow-hidden group">
<div class="flex justify-between items-start">
<span class="font-label-sm text-label-sm uppercase text-on-surface-variant tracking-wider">Estado de Servidor</span>
<span class="p-1.5 rounded bg-surface-container-high text-primary">
<span class="material-symbols-outlined text-[18px]">bolt</span>
</span>
</div>
<div class="my-space-sm">
<div class="font-headline-md text-headline-md text-primary uppercase leading-tight">En Curso</div>
<div class="font-label-sm text-label-sm uppercase tracking-widest text-secondary mt-1">Ronda Semifinales</div>
</div>
<div class="font-body-sm text-body-sm text-on-surface-variant truncate">
          Hash: <span class="font-label-sm text-label-sm">88F4-CP25-LIVE</span>
</div>
</div>
</section>
<!-- 3. TOURNAMENT GLOBAL CONTROLS BAR -->
<section class="bg-primary text-on-primary p-space-md rounded shadow-md flex flex-col lg:flex-row lg:items-center justify-between gap-space-md" data-original-section="1">
<div class="flex items-center gap-space-md">
<div class="w-12 h-12 bg-secondary/20 rounded flex items-center justify-center shrink-0">
<span class="material-symbols-outlined text-secondary text-[28px]">account_tree</span>
</div>
<div class="flex flex-col">
<div class="flex items-center gap-space-sm flex-wrap">
<span class="font-headline-md text-headline-md uppercase tracking-tight">Estructura del Cuadro</span>
<span class="bg-secondary text-on-secondary font-label-sm text-label-sm uppercase px-2 py-0.5 rounded">15 Partidos Totales</span>
</div>
<p class="font-body-sm text-body-sm text-on-primary-container mt-0.5">
            Llaves bloqueadas y sorteadas en estándar simple eliminación de 16 equipos. Árbol de progresión matemática activo.
          </p>
</div>
</div>
<div class="flex items-center gap-space-sm shrink-0">
<button class="bg-secondary hover:bg-on-secondary-container text-on-secondary font-label-md text-label-md uppercase px-space-lg py-2.5 rounded shadow-sm flex items-center gap-2 transition-all" id="open-batch-sim-modal">
<span class="material-symbols-outlined text-[18px]">bolt</span>
          ⚡ Simular Todos los Partidos Pendientes
        </button>
</div>
</section>
<!-- 4. GESTOR DE MARCADORES Y PARTIDOS (OCTAVOS, CUARTOS, SEMIFINALES, FINAL) -->
<section class="flex flex-col gap-space-md" data-original-section="2">
<div class="flex flex-col md:flex-row md:items-end justify-between gap-space-sm">
<div>
<span class="font-label-sm text-label-sm uppercase tracking-widest text-secondary">Control Operativo</span>
<h2 class="font-headline-lg text-headline-lg uppercase text-primary">Gestor de Marcadores y Partidos</h2>
</div>
<!-- Filter tabs for tournament bracket stages -->
<div class="flex items-center bg-surface-container p-1 rounded gap-1 overflow-x-auto">
<button class="stage-btn active-stage bg-primary text-on-primary font-label-sm text-label-sm uppercase px-space-md py-1.5 rounded transition-all" onclick="filterStage('all')" type="button">Todos (15)</button>
<button class="stage-btn text-on-surface-variant hover:text-on-surface font-label-sm text-label-sm uppercase px-space-md py-1.5 rounded transition-all" onclick="filterStage('octavos')" type="button">Octavos (8)</button>
<button class="stage-btn text-on-surface-variant hover:text-on-surface font-label-sm text-label-sm uppercase px-space-md py-1.5 rounded transition-all" onclick="filterStage('cuartos')" type="button">Cuartos (4)</button>
<button class="stage-btn text-on-surface-variant hover:text-on-surface font-label-sm text-label-sm uppercase px-space-md py-1.5 rounded transition-all relative" onclick="filterStage('semis')" type="button">
            Semis (2)
            <span class="w-1.5 h-1.5 rounded-full bg-secondary absolute top-1 right-1"></span>
</button>
<button class="stage-btn text-on-surface-variant hover:text-on-surface font-label-sm text-label-sm uppercase px-space-md py-1.5 rounded transition-all relative" onclick="filterStage('final')" type="button">
            Final (1)
            <span class="w-1.5 h-1.5 rounded-full bg-secondary absolute top-1 right-1"></span>
</button>
</div>
</div>
<!-- MATCHES CONTAINER -->
<div class="space-y-space-md">
<!-- ================= STAGE: SEMIFINALES (ACTIVE EDITING) ================= -->
<div class="stage-group flex flex-col gap-space-sm" data-group="semis">
<div class="flex items-center justify-between bg-surface-container-high px-space-md py-1.5 rounded">
<div class="flex items-center gap-2">
<span class="w-2 h-2 rounded-full bg-secondary animate-pulse"></span>
<span class="font-label-md text-label-md uppercase text-primary tracking-wider">Ronda 3: Semifinales • 2 Llaves</span>
</div>
<span class="font-label-sm text-label-sm uppercase text-secondary font-bold">En Espera de Cierre</span>
</div>
<div class="grid grid-cols-1 lg:grid-cols-2 gap-space-md">
<!-- Semifinal 1 - PENDIENTE -->
<div class="bg-surface rounded p-space-md shadow-sm flex flex-col justify-between gap-space-md" id="match-card-13">
<div class="flex items-center justify-between">
<span class="font-label-sm text-label-sm uppercase tracking-widest text-on-surface-variant">Llave SF-01 • Sábado 18:00 CST</span>
<span class="bg-secondary-container text-on-secondary-container font-label-sm text-label-sm px-2 py-0.5 rounded uppercase font-bold flex items-center gap-1">
<span class="material-symbols-outlined text-[13px]">alarm</span> Pendiente
                </span>
</div>
<!-- Match Competitors & Input Form -->
<form class="match-form flex flex-col gap-space-sm" data-match-id="SF-1">
<!-- Team A -->
<div class="flex items-center justify-between p-space-sm bg-surface-container-low rounded">
<div class="flex items-center gap-space-sm min-w-0">
<div class="w-8 h-8 rounded bg-primary text-on-primary flex items-center justify-center font-label-sm text-label-sm font-bold shrink-0">
                      LD
                    </div>
<div class="truncate">
<div class="font-title-sm text-title-sm text-on-surface truncate">Liga Deportivo Moravia</div>
<div class="font-label-sm text-label-sm text-on-surface-variant uppercase">Seed #1 • San José</div>
</div>
</div>
<input class="team-score-a w-14 h-10 text-center font-headline-md text-headline-md bg-surface text-primary rounded outline-none focus:bg-surface-container-highest transition-colors" max="99" min="0" required="" type="number" value="2"/>
</div>
<!-- Division Divider -->
<div class="flex items-center justify-between px-space-sm text-on-surface-variant">
<span class="font-label-sm text-label-sm uppercase tracking-widest">Versus</span>
<span class="validation-warning hidden text-error font-label-sm text-label-sm uppercase font-bold flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]">error</span>
                    No se permiten empates en eliminación directa
                  </span>
</div>
<!-- Team B -->
<div class="flex items-center justify-between p-space-sm bg-surface-container-low rounded">
<div class="flex items-center gap-space-sm min-w-0">
<div class="w-8 h-8 rounded bg-secondary text-on-secondary flex items-center justify-center font-label-sm text-label-sm font-bold shrink-0">
                      ST
                    </div>
<div class="truncate">
<div class="font-title-sm text-title-sm text-on-surface truncate">Sporting Tibás FC</div>
<div class="font-label-sm text-label-sm text-on-surface-variant uppercase">Seed #4 • Tibás</div>
</div>
</div>
<input class="team-score-b w-14 h-10 text-center font-headline-md text-headline-md bg-surface text-primary rounded outline-none focus:bg-surface-container-highest transition-colors" max="99" min="0" required="" type="number" value="1"/>
</div>
<!-- Action CTAs -->
<div class="flex flex-wrap items-center justify-end gap-space-xs pt-space-xs">
<button class="btn-simulate-single bg-surface-container-high hover:bg-surface-container text-primary font-label-sm text-label-sm uppercase px-space-md py-2 rounded flex items-center gap-1 transition-colors" type="button">
<span class="material-symbols-outlined text-[15px] text-secondary">bolt</span>
                    ⚡ Simular este Partido
                  </button>
<button class="bg-primary hover:bg-primary-container text-on-primary font-label-sm text-label-sm uppercase px-space-md py-2 rounded flex items-center gap-1 transition-colors" type="submit">
<span class="material-symbols-outlined text-[15px] text-secondary">check_circle</span>
                    Confirmar Resultado (Avanza Ganador)
                  </button>
</div>
</form>
</div>
<!-- Semifinal 2 - PENDIENTE -->
<div class="bg-surface rounded p-space-md shadow-sm flex flex-col justify-between gap-space-md" id="match-card-14">
<div class="flex items-center justify-between">
<span class="font-label-sm text-label-sm uppercase tracking-widest text-on-surface-variant">Llave SF-02 • Sábado 20:30 CST</span>
<span class="bg-secondary-container text-on-secondary-container font-label-sm text-label-sm px-2 py-0.5 rounded uppercase font-bold flex items-center gap-1">
<span class="material-symbols-outlined text-[13px]">alarm</span> Pendiente
                </span>
</div>
<!-- Match Competitors & Input Form -->
<form class="match-form flex flex-col gap-space-sm" data-match-id="SF-2">
<!-- Team A -->
<div class="flex items-center justify-between p-space-sm bg-surface-container-low rounded">
<div class="flex items-center gap-space-sm min-w-0">
<div class="w-8 h-8 rounded bg-primary text-on-primary flex items-center justify-center font-label-sm text-label-sm font-bold shrink-0">
                      CR
                    </div>
<div class="truncate">
<div class="font-title-sm text-title-sm text-on-surface truncate">Club Real Cartaginés</div>
<div class="font-label-sm text-label-sm text-on-surface-variant uppercase">Seed #2 • Cartago</div>
</div>
</div>
<input class="team-score-a w-14 h-10 text-center font-headline-md text-headline-md bg-surface text-primary rounded outline-none focus:bg-surface-container-highest transition-colors" max="99" min="0" required="" type="number" value="0"/>
</div>
<!-- Division Divider with Error Demo -->
<div class="flex items-center justify-between px-space-sm text-on-surface-variant">
<span class="font-label-sm text-label-sm uppercase tracking-widest">Versus</span>
<span class="validation-warning hidden text-error font-label-sm text-label-sm uppercase font-bold flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]">error</span>
                    No se permiten empates en eliminación directa
                  </span>
</div>
<!-- Team B -->
<div class="flex items-center justify-between p-space-sm bg-surface-container-low rounded">
<div class="flex items-center gap-space-sm min-w-0">
<div class="w-8 h-8 rounded bg-tertiary text-on-tertiary flex items-center justify-center font-label-sm text-label-sm font-bold shrink-0">
                      AH
                    </div>
<div class="truncate">
<div class="font-title-sm text-title-sm text-on-surface truncate">Atlético Herediano Gaming</div>
<div class="font-label-sm text-label-sm text-on-surface-variant uppercase">Seed #3 • Heredia</div>
</div>
</div>
<input class="team-score-b w-14 h-10 text-center font-headline-md text-headline-md bg-surface text-primary rounded outline-none focus:bg-surface-container-highest transition-colors" max="99" min="0" required="" type="number" value="1"/>
</div>
<!-- Action CTAs -->
<div class="flex flex-wrap items-center justify-end gap-space-xs pt-space-xs">
<button class="btn-simulate-single bg-surface-container-high hover:bg-surface-container text-primary font-label-sm text-label-sm uppercase px-space-md py-2 rounded flex items-center gap-1 transition-colors" type="button">
<span class="material-symbols-outlined text-[15px] text-secondary">bolt</span>
                    ⚡ Simular este Partido
                  </button>
<button class="bg-primary hover:bg-primary-container text-on-primary font-label-sm text-label-sm uppercase px-space-md py-2 rounded flex items-center gap-1 transition-colors" type="submit">
<span class="material-symbols-outlined text-[15px] text-secondary">check_circle</span>
                    Confirmar Resultado (Avanza Ganador)
                  </button>
</div>
</form>
</div>
</div>
</div>
<!-- ================= STAGE: GRAN FINAL (LOCKED UNTIL SEMIS COMPLETE) ================= -->
<div class="stage-group flex flex-col gap-space-sm" data-group="final">
<div class="flex items-center justify-between bg-surface-container-high px-space-md py-1.5 rounded">
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-secondary text-[16px]">emoji_events</span>
<span class="font-label-md text-label-md uppercase text-primary tracking-wider">Gran Final • Domingo 20:00 CST</span>
</div>
<span class="font-label-sm text-label-sm uppercase text-on-surface-variant">Premio Mayor: ₡ 3,000,000</span>
</div>
<div class="bg-surface rounded p-space-md shadow-sm flex flex-col md:flex-row items-center justify-between gap-space-md border-l-4 border-secondary">
<div class="flex flex-col gap-1 w-full md:w-auto">
<span class="bg-surface-container-high text-on-surface font-label-sm text-label-sm px-2 py-0.5 rounded uppercase self-start">Esperando Definición Semifinales</span>
<div class="flex items-center gap-space-md mt-2">
<div class="font-headline-md text-headline-md text-primary">Ganador SF-01</div>
<span class="font-label-sm text-label-sm uppercase text-secondary font-bold">VS</span>
<div class="font-headline-md text-headline-md text-primary">Ganador SF-02</div>
</div>
<p class="font-body-sm text-body-sm text-on-surface-variant">
                Los dos vencedores de semifinales se asignarán automáticamente para disputar el trofeo oficial.
              </p>
</div>
<div class="flex items-center gap-space-sm shrink-0 w-full md:w-auto justify-end">
<span class="text-on-surface-variant font-label-sm text-label-sm uppercase flex items-center gap-1">
<span class="material-symbols-outlined text-[16px]">lock</span>
                Bloqueado hasta cierre SF
              </span>
</div>
</div>
</div>
<!-- ================= STAGE: CUARTOS DE FINAL (FINALIZADOS) ================= -->
<div class="stage-group flex flex-col gap-space-sm" data-group="cuartos">
<div class="flex items-center justify-between bg-surface-container-high px-space-md py-1.5 rounded">
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-[16px] text-primary">check_circle</span>
<span class="font-label-md text-label-md uppercase text-primary tracking-wider">Ronda 2: Cuartos de Final (Completada 4/4)</span>
</div>
<span class="font-label-sm text-label-sm uppercase text-on-surface-variant">Auditado y Cerrado</span>
</div>
<div class="grid grid-cols-1 md:grid-cols-2 gap-space-md">
<!-- Match QF 1 -->
<div class="bg-surface rounded p-space-md shadow-sm flex flex-col justify-between gap-space-sm">
<div class="flex items-center justify-between text-on-surface-variant">
<span class="font-label-sm text-label-sm uppercase">CF-01 • Llave A</span>
<span class="bg-surface-container text-on-surface font-label-sm text-label-sm px-2 py-0.5 rounded uppercase font-bold">FINALIZADO</span>
</div>
<div class="flex flex-col gap-1">
<div class="flex justify-between items-center bg-surface-container-low px-space-sm py-1.5 rounded border-l-2 border-primary font-bold">
<span class="font-body-md text-body-md text-on-surface">Liga Deportivo Moravia</span>
<span class="font-headline-md text-headline-md text-primary">3</span>
</div>
<div class="flex justify-between items-center px-space-sm py-1.5 text-on-surface-variant">
<span class="font-body-md text-body-md line-through">Alajuela eSports FC</span>
<span class="font-headline-md text-headline-md">1</span>
</div>
</div>
<div class="flex justify-end pt-1">
<button class="text-on-surface hover:text-secondary font-label-sm text-label-sm uppercase flex items-center gap-1 transition-colors">
<span class="material-symbols-outlined text-[14px]">receipt_long</span> Ver Ficha Técnica
                </button>
</div>
</div>
<!-- Match QF 2 -->
<div class="bg-surface rounded p-space-md shadow-sm flex flex-col justify-between gap-space-sm">
<div class="flex items-center justify-between text-on-surface-variant">
<span class="font-label-sm text-label-sm uppercase">CF-02 • Llave B</span>
<span class="bg-surface-container text-on-surface font-label-sm text-label-sm px-2 py-0.5 rounded uppercase font-bold">FINALIZADO</span>
</div>
<div class="flex flex-col gap-1">
<div class="flex justify-between items-center bg-surface-container-low px-space-sm py-1.5 rounded border-l-2 border-primary font-bold">
<span class="font-body-md text-body-md text-on-surface">Sporting Tibás FC</span>
<span class="font-headline-md text-headline-md text-primary">2</span>
</div>
<div class="flex justify-between items-center px-space-sm py-1.5 text-on-surface-variant">
<span class="font-body-md text-body-md line-through">San Carlos Spartans</span>
<span class="font-headline-md text-headline-md">0</span>
</div>
</div>
<div class="flex justify-end pt-1">
<button class="text-on-surface hover:text-secondary font-label-sm text-label-sm uppercase flex items-center gap-1 transition-colors">
<span class="material-symbols-outlined text-[14px]">receipt_long</span> Ver Ficha Técnica
                </button>
</div>
</div>
<!-- Match QF 3 -->
<div class="bg-surface rounded p-space-md shadow-sm flex flex-col justify-between gap-space-sm">
<div class="flex items-center justify-between text-on-surface-variant">
<span class="font-label-sm text-label-sm uppercase">CF-03 • Llave C</span>
<span class="bg-surface-container text-on-surface font-label-sm text-label-sm px-2 py-0.5 rounded uppercase font-bold">FINALIZADO</span>
</div>
<div class="flex flex-col gap-1">
<div class="flex justify-between items-center bg-surface-container-low px-space-sm py-1.5 rounded border-l-2 border-primary font-bold">
<span class="font-body-md text-body-md text-on-surface">Club Real Cartaginés</span>
<span class="font-headline-md text-headline-md text-primary">4</span>
</div>
<div class="flex justify-between items-center px-space-sm py-1.5 text-on-surface-variant">
<span class="font-body-md text-body-md line-through">Pérez Zeledón Storm</span>
<span class="font-headline-md text-headline-md">2</span>
</div>
</div>
<div class="flex justify-end pt-1">
<button class="text-on-surface hover:text-secondary font-label-sm text-label-sm uppercase flex items-center gap-1 transition-colors">
<span class="material-symbols-outlined text-[14px]">receipt_long</span> Ver Ficha Técnica
                </button>
</div>
</div>
<!-- Match QF 4 -->
<div class="bg-surface rounded p-space-md shadow-sm flex flex-col justify-between gap-space-sm">
<div class="flex items-center justify-between text-on-surface-variant">
<span class="font-label-sm text-label-sm uppercase">CF-04 • Llave D</span>
<span class="bg-surface-container text-on-surface font-label-sm text-label-sm px-2 py-0.5 rounded uppercase font-bold">FINALIZADO</span>
</div>
<div class="flex flex-col gap-1">
<div class="flex justify-between items-center bg-surface-container-low px-space-sm py-1.5 rounded border-l-2 border-primary font-bold">
<span class="font-body-md text-body-md text-on-surface">Atlético Herediano Gaming</span>
<span class="font-headline-md text-headline-md text-primary">2</span>
</div>
<div class="flex justify-between items-center px-space-sm py-1.5 text-on-surface-variant">
<span class="font-body-md text-body-md line-through">Puntarenas Puerto Sharks</span>
<span class="font-headline-md text-headline-md">1</span>
</div>
</div>
<div class="flex justify-end pt-1">
<button class="text-on-surface hover:text-secondary font-label-sm text-label-sm uppercase flex items-center gap-1 transition-colors">
<span class="material-symbols-outlined text-[14px]">receipt_long</span> Ver Ficha Técnica
                </button>
</div>
</div>
</div>
</div>
<!-- ================= STAGE: OCTAVOS DE FINAL (COMPLETADOS RESUMEN) ================= -->
<div class="stage-group flex flex-col gap-space-sm" data-group="octavos">
<div class="flex items-center justify-between bg-surface-container-high px-space-md py-1.5 rounded">
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-[16px] text-primary">task_alt</span>
<span class="font-label-md text-label-md uppercase text-primary tracking-wider">Ronda 1: Octavos de Final (Completada 8/8)</span>
</div>
<span class="font-label-sm text-label-sm uppercase text-on-surface-variant">8 Ganadores Promovidos</span>
</div>
<div class="bg-surface p-space-md rounded shadow-sm overflow-x-auto">
<table class="w-full text-left">
<thead>
<tr class="bg-surface-container-high font-label-sm text-label-sm uppercase text-on-surface">
<th class="p-2">Llave</th>
<th class="p-2">Ganador (Avanzó)</th>
<th class="p-2">Marcador</th>
<th class="p-2">Derrotado (Eliminado)</th>
<th class="p-2 text-right">Auditoría</th>
</tr>
</thead>
<tbody class="divide-y divide-outline">
<tr class="hover:bg-surface-container-low transition-colors">
<td class="p-2 font-label-sm text-label-sm text-on-surface-variant">OCT-01</td>
<td class="p-2 font-title-sm text-title-sm text-primary">Liga Deportivo Moravia</td>
<td class="p-2 font-headline-md text-headline-md text-primary">4 - 0</td>
<td class="p-2 font-body-sm text-body-sm text-on-surface-variant">Guápiles Santos eSports</td>
<td class="p-2 text-right"><span class="bg-surface-container text-on-surface font-label-sm text-label-sm px-2 py-0.5 rounded uppercase">CERRADO</span></td>
</tr>
<tr class="hover:bg-surface-container-low transition-colors">
<td class="p-2 font-label-sm text-label-sm text-on-surface-variant">OCT-02</td>
<td class="p-2 font-title-sm text-title-sm text-primary">Alajuela eSports FC</td>
<td class="p-2 font-headline-md text-headline-md text-primary">2 - 1</td>
<td class="p-2 font-body-sm text-body-sm text-on-surface-variant">Liberia Golden Bulls</td>
<td class="p-2 text-right"><span class="bg-surface-container text-on-surface font-label-sm text-label-sm px-2 py-0.5 rounded uppercase">CERRADO</span></td>
</tr>
<tr class="hover:bg-surface-container-low transition-colors">
<td class="p-2 font-label-sm text-label-sm text-on-surface-variant">OCT-03</td>
<td class="p-2 font-title-sm text-title-sm text-primary">Sporting Tibás FC</td>
<td class="p-2 font-headline-md text-headline-md text-primary">3 - 1</td>
<td class="p-2 font-body-sm text-body-sm text-on-surface-variant">Turrialba Titans</td>
<td class="p-2 text-right"><span class="bg-surface-container text-on-surface font-label-sm text-label-sm px-2 py-0.5 rounded uppercase">CERRADO</span></td>
</tr>
<tr class="hover:bg-surface-container-low transition-colors">
<td class="p-2 font-label-sm text-label-sm text-on-surface-variant">OCT-04</td>
<td class="p-2 font-title-sm text-title-sm text-primary">San Carlos Spartans</td>
<td class="p-2 font-headline-md text-headline-md text-primary">1 - 0</td>
<td class="p-2 font-body-sm text-body-sm text-on-surface-variant">Grecia Phoenix Club</td>
<td class="p-2 text-right"><span class="bg-surface-container text-on-surface font-label-sm text-label-sm px-2 py-0.5 rounded uppercase">CERRADO</span></td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
</section>
<!-- 2. GESTOR DE INSCRIPCIONES Y SOLICITUDES -->
<section class="flex flex-col gap-space-md" data-original-section="3">
<div class="flex flex-col md:flex-row md:items-end justify-between gap-space-sm">
<div>
<span class="font-label-sm text-label-sm uppercase tracking-widest text-secondary">Base de Datos de Clubes</span>
<h2 class="font-headline-lg text-headline-lg uppercase text-primary">Gestor de Inscripciones y Solicitudes</h2>
</div>
<div class="flex items-center gap-space-xs">
<span class="font-label-sm text-label-sm text-on-surface-variant uppercase">Filtrar por:</span>
<span class="bg-surface text-primary px-2.5 py-1 rounded font-label-sm text-label-sm shadow-sm cursor-pointer font-bold">Todos (19)</span>
<span class="text-on-surface-variant hover:text-primary px-2 py-1 rounded font-label-sm text-label-sm cursor-pointer">Pendientes (1)</span>
<span class="text-on-surface-variant hover:text-primary px-2 py-1 rounded font-label-sm text-label-sm cursor-pointer">Rechazados (2)</span>
</div>
</div>
<!-- Teams Registration Table Card -->
<div class="bg-surface rounded shadow-sm overflow-hidden">
<div class="overflow-x-auto">
<table class="w-full text-left" id="teams-registry-table">
<thead>
<tr class="bg-surface-container-high text-on-surface font-label-sm text-label-sm uppercase">
<th class="p-space-md">Escudo / Club</th>
<th class="p-space-md">Dueño / Representante</th>
<th class="p-space-md">Contacto (Costa Rica)</th>
<th class="p-space-md">Estado Oficial</th>
<th class="p-space-md text-right">Acción de Registro</th>
</tr>
</thead>
<tbody class="divide-y divide-outline">
<!-- Team 1: Approved -->
<tr class="hover:bg-surface-container-low transition-colors">
<td class="p-space-md flex items-center gap-space-sm">
<div class="w-10 h-10 rounded bg-primary text-on-primary font-headline-md text-headline-md flex items-center justify-center shrink-0">
                    LD
                  </div>
<div>
<div class="font-title-sm text-title-sm text-on-surface">Liga Deportivo Moravia</div>
<div class="font-body-sm text-body-sm text-on-surface-variant">Roster: 11 Titulares + 4 Suplentes</div>
</div>
</td>
<td class="p-space-md">
<div class="font-body-md text-body-md text-on-surface">Esteban Fonseca R.</div>
<div class="font-label-sm text-label-sm text-on-surface-variant uppercase">Cédula: 1-1402-0982</div>
</td>
<td class="p-space-md">
<span class="font-body-md text-body-md text-on-surface font-mono">+506 8841-2091</span>
</td>
<td class="p-space-md">
<span class="status-badge bg-secondary-container text-on-secondary-container font-label-sm text-label-sm uppercase px-2 py-0.5 rounded font-bold">
                    APROBADO
                  </span>
</td>
<td class="p-space-md text-right">
<span class="text-on-surface-variant font-label-sm text-label-sm uppercase">Validado en Cuadro</span>
</td>
</tr>
<!-- Team 2: Approved -->
<tr class="hover:bg-surface-container-low transition-colors">
<td class="p-space-md flex items-center gap-space-sm">
<div class="w-10 h-10 rounded bg-secondary text-on-secondary font-headline-md text-headline-md flex items-center justify-center shrink-0">
                    ST
                  </div>
<div>
<div class="font-title-sm text-title-sm text-on-surface">Sporting Tibás FC</div>
<div class="font-body-sm text-body-sm text-on-surface-variant">Roster: 11 Titulares + 5 Suplentes</div>
</div>
</td>
<td class="p-space-md">
<div class="font-body-md text-body-md text-on-surface">Carlos Mario Cordero</div>
<div class="font-label-sm text-label-sm text-on-surface-variant uppercase">Cédula: 1-0988-0245</div>
</td>
<td class="p-space-md">
<span class="font-body-md text-body-md text-on-surface font-mono">+506 8312-9900</span>
</td>
<td class="p-space-md">
<span class="status-badge bg-secondary-container text-on-secondary-container font-label-sm text-label-sm uppercase px-2 py-0.5 rounded font-bold">
                    APROBADO
                  </span>
</td>
<td class="p-space-md text-right">
<span class="text-on-surface-variant font-label-sm text-label-sm uppercase">Validado en Cuadro</span>
</td>
</tr>
<!-- Team 3: PENDIENTE (INTERACTIVE ROW) -->
<tr class="hover:bg-surface-container-low transition-colors bg-secondary-container/20" id="team-row-pen1">
<td class="p-space-md flex items-center gap-space-sm">
<div class="w-10 h-10 rounded bg-surface-container-highest text-on-surface font-headline-md text-headline-md flex items-center justify-center shrink-0">
                    ES
                  </div>
<div>
<div class="font-title-sm text-title-sm text-on-surface">Escazú Serpents eSports</div>
<div class="font-body-sm text-body-sm text-on-surface-variant">Lista de Reserva • Suplente Oficial</div>
</div>
</td>
<td class="p-space-md">
<div class="font-body-md text-body-md text-on-surface">Valeria Monge Solís</div>
<div class="font-label-sm text-label-sm text-on-surface-variant uppercase">Cédula: 1-1772-0451</div>
</td>
<td class="p-space-md">
<span class="font-body-md text-body-md text-on-surface font-mono">+506 7015-8833</span>
</td>
<td class="p-space-md">
<span class="status-badge bg-secondary-container text-on-secondary-container font-label-sm text-label-sm uppercase px-2 py-0.5 rounded font-bold" id="badge-pen1">
                    PENDIENTE
                  </span>
</td>
<td class="p-space-md text-right">
<div class="flex items-center justify-end gap-1.5" id="actions-pen1">
<button class="bg-primary hover:bg-primary-container text-on-primary font-label-sm text-label-sm uppercase px-3 py-1 rounded transition-colors" onclick="updateTeamStatus('pen1', 'APROBADO')" type="button">
                      Aprobar
                    </button>
<button class="bg-surface-container-high hover:bg-error hover:text-on-error text-error font-label-sm text-label-sm uppercase px-3 py-1 rounded transition-colors" onclick="updateTeamStatus('pen1', 'RECHAZADO')" type="button">
                      Rechazar
                    </button>
</div>
</td>
</tr>
<!-- Team 4: RECHAZADO -->
<tr class="hover:bg-surface-container-low transition-colors">
<td class="p-space-md flex items-center gap-space-sm">
<div class="w-10 h-10 rounded bg-surface-container-high text-on-surface-variant font-headline-md text-headline-md flex items-center justify-center shrink-0">
                    LP
                  </div>
<div>
<div class="font-title-sm text-title-sm text-on-surface line-through">Limón Port Vipers</div>
<div class="font-body-sm text-body-sm text-on-surface-variant">Fuera de plazo oficial de inscripción</div>
</div>
</td>
<td class="p-space-md">
<div class="font-body-md text-body-md text-on-surface">Javier Campbell Brown</div>
<div class="font-label-sm text-label-sm text-on-surface-variant uppercase">Cédula: 7-0199-0331</div>
</td>
<td class="p-space-md">
<span class="font-body-md text-body-md text-on-surface font-mono">+506 8701-4422</span>
</td>
<td class="p-space-md">
<span class="status-badge bg-error-container text-on-error-container font-label-sm text-label-sm uppercase px-2 py-0.5 rounded font-bold">
                    RECHAZADO
                  </span>
</td>
<td class="p-space-md text-right">
<span class="text-on-surface-variant font-label-sm text-label-sm uppercase">Rechazo Notificado</span>
</td>
</tr>
</tbody>
</table>
</div>
</div>
</section>
</div>
<!-- MODAL: BATCH SIMULATION WARNING (IRREVERSIBLE) -->
<div class="fixed inset-0 z-50 hidden items-center justify-center bg-black/60 backdrop-blur-sm p-4" id="batch-sim-modal">
<div class="bg-surface max-w-lg w-full rounded p-space-lg shadow-[8px_8px_0px_#000000] flex flex-col gap-space-md relative">
<div class="flex items-center gap-space-sm text-error">
<span class="material-symbols-outlined text-[32px]">warning</span>
<h3 class="font-headline-md text-headline-md uppercase text-primary">Confirmar Simulación Masiva</h3>
</div>
<div class="font-body-md text-body-md text-on-surface flex flex-col gap-2">
<p class="font-bold text-error">
          ADVERTENCIA DE IRREVERSIBILIDAD TOTAL:
        </p>
<p class="text-on-surface-variant">
          Esta acción ejecutará de manera instantánea el algoritmo matemático sobre los <strong class="text-primary">3 partidos pendientes</strong> (Semifinales y Gran Final), coronando automáticamente al Campeón 2026.
        </p>
<div class="bg-surface-container-high p-space-sm rounded font-body-sm text-body-sm text-on-surface">
          • Los marcadores serán generados y sellados en base a coeficientes de rendimiento.<br/>
          • El cuadro pasará inmediatamente a estado <strong>COMPLETADO (15/15)</strong>.<br/>
          • No será posible revertir las llaves ni ajustar marcadores manualmente.
        </div>
</div>
<div class="flex items-center justify-end gap-space-sm pt-space-sm">
<button class="bg-surface-container-high hover:bg-surface-container text-on-surface font-label-md text-label-md uppercase px-space-md py-2.5 rounded transition-colors" id="close-batch-sim-modal" type="button">
          Cancelar
        </button>
<button class="bg-error hover:bg-on-error-container text-on-error font-label-md text-label-md uppercase px-space-lg py-2.5 rounded shadow-sm flex items-center gap-2 transition-colors" id="confirm-batch-sim" type="button">
<span class="material-symbols-outlined text-[18px]">bolt</span>
          Proceder y Cerrar Torneo
        </button>
</div>
</div>
</div>
<!-- Client-side Interactive Logic -->

</div></main><footer class="w-full bg-surface-container-low py-space-xl mt-space-xl"><div class="w-full px-margin flex flex-col md:flex-row items-center justify-between gap-space-md"><div class="flex items-center gap-space-sm"><div class="w-6 h-6 rounded bg-primary flex items-center justify-center"><span class="material-symbols-outlined text-secondary text-[14px]">emoji_events</span></div><span class="font-headline-md text-headline-md uppercase text-on-surface">BRACKET ARENA</span></div><div class="font-body-sm text-body-sm text-on-surface-variant text-center">© 2026 Bracket Arena Technologies. Sistema Profesional de Gestión de Torneos Eliminatorios.</div><div class="flex items-center gap-space-md font-label-sm text-label-sm text-on-surface-variant uppercase"><a class="hover:text-on-surface transition-colors" href="#">Reglamento</a><a class="hover:text-on-surface transition-colors" href="#">Soporte</a><a class="hover:text-on-surface transition-colors" href="#">API Torneo</a></div></div></footer><script>window.ARENA_BASE = '<%=request.getContextPath()%>';</script><script defer="" src="<%=request.getContextPath()%>/js/stitch-runtime.js?v=2026-11-25-navbar-r2"></script></body></html>