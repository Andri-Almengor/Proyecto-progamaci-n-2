# Interfaz anterior (archivada)

Esta carpeta conserva las JSP, parciales y estilos de la interfaz anterior para consulta histórica. **No participa en la compilación del WAR ni en el flujo de la aplicación actual**.

Las ocho pantallas utilizadas actualmente provienen del HTML de Stitch aportado al proyecto y están en `web/WEB-INF/views/arena/`. Sus estilos activos viven en `web/css/stitch.css` y `web/css/stitch-bridge.css`, con `web/js/stitch-runtime.js`.

No copies estas vistas a `web/WEB-INF/views` sin actualizar rutas y pruebas: son referencias antiguas, no una segunda implementación en producción.
