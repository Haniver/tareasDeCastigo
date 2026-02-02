#!/usr/bin/env python3
"""Script para ejecutar el backend en producción con gunicorn"""
import subprocess
import sys

if __name__ == "__main__":
    subprocess.run([
        sys.executable, "-m", "gunicorn",
        "main:app",
        "-w", "4",
        "-k", "uvicorn.workers.UvicornWorker",
        "-b", "127.0.0.1:8004",
        "--access-logfile", "-",
        "--error-logfile", "-"
    ])
