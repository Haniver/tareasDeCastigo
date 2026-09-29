#!/usr/bin/env python3
"""Cambia la contraseña del panel de admin. Se ejecuta en el servidor:

    sudo -u lucio backend/venv/bin/python backend/set_admin_password.py
"""
import getpass
import sys

import models
from auth import hashear_password
from database import SessionLocal

password = getpass.getpass("Nueva contraseña de admin: ")
if not password:
    sys.exit("La contraseña no puede estar vacía")
if getpass.getpass("Repítela: ") != password:
    sys.exit("Las contraseñas no coinciden")

db = SessionLocal()
config = db.query(models.Config).filter(models.Config.clave == "password_admin").first()
if config:
    config.valor = hashear_password(password)
else:
    db.add(models.Config(clave="password_admin", valor=hashear_password(password)))
db.commit()
db.close()
print("Contraseña actualizada. Las sesiones abiertas del panel se cerraron.")
