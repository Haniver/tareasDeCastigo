"""Autenticación del panel de admin: contraseña hasheada y tokens firmados."""
import hashlib
import hmac
import os
import secrets
import time
from typing import Optional

from fastapi import Depends, Header, HTTPException
from sqlalchemy.orm import Session

import models
from database import get_db

SECRET_KEY = os.getenv("SECRET_KEY")
if not SECRET_KEY:
    raise RuntimeError("Falta SECRET_KEY en backend/.env")

ITERACIONES = 600_000
DURACION_TOKEN = 7 * 24 * 3600  # 7 días


def hashear_password(password: str) -> str:
    salt = secrets.token_hex(16)
    h = hashlib.pbkdf2_hmac("sha256", password.encode(), bytes.fromhex(salt), ITERACIONES)
    return f"pbkdf2_sha256${ITERACIONES}${salt}${h.hex()}"


def verificar_password(password: str, guardado: str) -> bool:
    try:
        algoritmo, iteraciones, salt, esperado = guardado.split("$")
    except ValueError:
        return False  # contraseña en texto plano (formato viejo): no se acepta
    if algoritmo != "pbkdf2_sha256":
        return False
    h = hashlib.pbkdf2_hmac("sha256", password.encode(), bytes.fromhex(salt), int(iteraciones))
    return hmac.compare_digest(h.hex(), esperado)


def _firma(expira: int, password_hash: str) -> str:
    # Incluir el hash de la contraseña invalida los tokens viejos al cambiarla
    return hmac.new(SECRET_KEY.encode(), f"{expira}.{password_hash}".encode(), hashlib.sha256).hexdigest()


def crear_token(password_hash: str) -> str:
    expira = int(time.time()) + DURACION_TOKEN
    return f"{expira}.{_firma(expira, password_hash)}"


def obtener_password_hash(db: Session) -> Optional[str]:
    config = db.query(models.Config).filter(models.Config.clave == "password_admin").first()
    return config.valor if config else None


def require_admin(authorization: Optional[str] = Header(None), db: Session = Depends(get_db)):
    """Dependencia para endpoints que solo puede usar la maestra"""
    no_autorizado = HTTPException(status_code=401, detail="No autorizado")
    if not authorization or not authorization.startswith("Bearer "):
        raise no_autorizado
    try:
        expira_str, firma = authorization[len("Bearer "):].split(".")
        expira = int(expira_str)
    except ValueError:
        raise no_autorizado
    password_hash = obtener_password_hash(db)
    if not password_hash or expira < time.time():
        raise no_autorizado
    if not hmac.compare_digest(firma, _firma(expira, password_hash)):
        raise no_autorizado
