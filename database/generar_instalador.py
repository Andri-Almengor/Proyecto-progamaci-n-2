#!/usr/bin/env python3
"""Genera el instalador SQL único desde el esquema y los datos de prueba.

Desde la raíz del proyecto:
    python database/generar_instalador.py
    python database/generar_instalador.py --check

Esta herramienta no abre conexiones a MySQL.
"""
from pathlib import Path
import sys

DATABASE = Path(__file__).resolve().parent
SCHEMA = DATABASE / "schema" / "torneos.sql"
SEED = DATABASE / "seeds" / "demo_20_equipos.sql"
INSTALLER = DATABASE / "instalacion_completa_2026.sql"

HEADER = (
    "-- BRACKET ARENA | INSTALACION COMPLETA 2026 (MySQL 8+)\n"
    "-- Un solo archivo para MySQL Workbench: esquema + 20 equipos.\n"
    "-- No ejecuta DROP DATABASE ni borra registros existentes.\n"
    "-- Usuario MySQL opcional: database/setup/usuario_aplicacion.sql\n\n"
)


def create_installer() -> str:
    """Respeta el orden de instalación: primero tablas y luego equipos."""
    schema = SCHEMA.read_text(encoding="utf-8").rstrip()
    seed = SEED.read_text(encoding="utf-8").rstrip()
    return f"{HEADER}{schema}\n\n{seed}\n"


def main() -> int:
    expected = create_installer()
    if "--check" in sys.argv:
        if not INSTALLER.is_file() or INSTALLER.read_text(encoding="utf-8") != expected:
            print("ERROR: el instalador difiere de los scripts de origen.")
            return 1
        print("Instalador SQL sincronizado.")
    else:
        INSTALLER.write_text(expected, encoding="utf-8", newline="\n")
        print(f"Generado: {INSTALLER}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
