#!/usr/bin/env python3
"""Regenera/verifica el instalador autocontenido desde los dos SQL fuente."""
from pathlib import Path
import sys

BASE = Path(__file__).resolve().parent
HEADER = (
    "-- BRACKET ARENA | INSTALACION COMPLETA 2026 (MySQL 8+)\n"
    "-- Un solo archivo para MySQL Workbench: esquema + 20 equipos.\n"
    "-- No ejecuta DROP DATABASE ni borra registros existentes.\n"
    "-- Usuario MySQL opcional: database/usuario_aplicacion.sql\n\n"
)
source = HEADER + (BASE / "torneos.sql").read_text(encoding="utf-8").rstrip() + "\n\n" + (BASE / "demo_20_equipos.sql").read_text(encoding="utf-8").rstrip() + "\n"
output = BASE / "instalacion_completa_2026.sql"
if "--check" in sys.argv:
    if not output.exists() or output.read_text(encoding="utf-8") != source:
        print("ERROR: instalacion_completa_2026.sql no coincide con los SQL de origen.")
        sys.exit(1)
    print("Instalador SQL sincronizado.")
else:
    output.write_text(source, encoding="utf-8", newline="\n")
    print(f"Generado: {output}")
