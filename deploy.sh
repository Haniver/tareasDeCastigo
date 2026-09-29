#!/bin/bash
# Actualiza la app en el servidor. Ejecutar como root:
#   /home/lucio/Proyectos/tareaDeCastigo/deploy.sh
set -euo pipefail

APP=/home/lucio/Proyectos/tareaDeCastigo

echo "==> git pull"
sudo -u lucio git -C "$APP" pull --ff-only origin main

echo "==> Dependencias del backend"
sudo -u lucio "$APP/backend/venv/bin/pip" install -q -r "$APP/backend/requirements.txt"

echo "==> Base de datos (init_db.sql es idempotente)"
sudo -u lucio psql -q -v ON_ERROR_STOP=1 -d tareasDeCastigo -f "$APP/database/init_db.sql" >/dev/null

echo "==> Frontend"
cd "$APP/frontend"
sudo -u lucio npm ci --no-audit --no-fund --loglevel=error
sudo -u lucio npm run build --silent

echo "==> Reiniciando backend"
systemctl restart tareadecastigo
sleep 3
curl -fsS http://127.0.0.1:8004/api/health && echo
echo "==> Listo"
