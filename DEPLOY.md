# Instrucciones de Despliegue

## Información del Servidor
- **URL:** https://tareadecastigo.work
- **Proveedor:** VPSDime
- **IP Pública:** 104.251.211.214
- **Sistema:** Ubuntu 26.04 LTS
- **Ruta de la app:** `/home/lucio/Proyectos/tareaDeCastigo` (usuario `lucio`, sin login)

Se entra al servidor como root con una llave SSH dedicada (sin passphrase):

```powershell
ssh -i $env:USERPROFILE\.ssh\tareadecastigo_ed25519 root@104.251.211.214
```

---

## Desplegar Cambios

1. Hacer commit y push a `main` desde la máquina de desarrollo.
2. Ejecutar el script de despliegue en el servidor:

```powershell
ssh -i $env:USERPROFILE\.ssh\tareadecastigo_ed25519 root@104.251.211.214 /home/lucio/Proyectos/tareaDeCastigo/deploy.sh
```

`deploy.sh` hace `git pull`, instala dependencias del backend, ejecuta `database/init_db.sql`
(es idempotente: solo agrega lo que falte), compila el frontend y reinicia el backend.

> Como `init_db.sql` se ejecuta en cada despliegue, un verbo que venga en ese archivo y se
> borre desde el panel de admin volverá a aparecer en el siguiente despliegue.

### Verificar
```bash
systemctl status tareadecastigo
curl https://tareadecastigo.work/api/health
```

---

## Comandos Útiles (en el servidor, como root)

| Acción | Comando |
|--------|---------|
| Ver estado del backend | `systemctl status tareadecastigo` |
| Reiniciar backend | `systemctl restart tareadecastigo` |
| Ver logs del backend | `journalctl -u tareadecastigo -f` |
| Recargar nginx | `systemctl reload nginx` |
| Ver logs de nginx | `tail -f /var/log/nginx/error.log` |
| Conectar a la BD | `sudo -u lucio psql -d tareasDeCastigo` |
| Respaldar la BD | `sudo -u lucio pg_dump tareasDeCastigo > respaldo.sql` |

El usuario `lucio` entra a PostgreSQL por autenticación *peer* (sin contraseña) desde el propio
servidor. La contraseña que usa el backend está solo en `backend/.env` en el servidor.

---

## Archivos de Configuración

| Archivo | Ubicación |
|---------|-----------|
| Servicio systemd | `/etc/systemd/system/tareadecastigo.service` (copia de `tareadecastigo.service`) |
| Configuración nginx | `/etc/nginx/sites-available/tareadecastigo.work` |
| Variables de entorno | `/home/lucio/Proyectos/tareaDeCastigo/backend/.env` |
| Frontend compilado | `/home/lucio/Proyectos/tareaDeCastigo/frontend/dist/` |

Si se modifica `tareadecastigo.service` en el repo, hay que volver a copiarlo:
```bash
cp /home/lucio/Proyectos/tareaDeCastigo/tareadecastigo.service /etc/systemd/system/
systemctl daemon-reload && systemctl restart tareadecastigo
```

---

## Solución de Problemas

### El backend no inicia (puerto ocupado)
```bash
fuser -k 8004/tcp
systemctl restart tareadecastigo
```

### Renovar certificado SSL
Certbot lo renueva solo (timer de systemd). Para probar la renovación:
```bash
certbot renew --dry-run
```

---

## Despliegue Completo (desde cero, como root)

```bash
# 1. Paquetes
apt-get install -y postgresql nginx python3-venv git nodejs npm certbot python3-certbot-nginx ufw

# 2. Usuario de la app
useradd --create-home --shell /usr/sbin/nologin lucio
chmod 755 /home/lucio

# 3. Base de datos (usar una contraseña generada, p. ej. con: openssl rand -hex 24)
sudo -u postgres psql -c "CREATE ROLE lucio LOGIN PASSWORD '<contraseña>';"
sudo -u postgres psql -c "CREATE DATABASE \"tareasDeCastigo\" OWNER lucio;"

# 4. Código
sudo -u lucio mkdir -p /home/lucio/Proyectos
sudo -u lucio git clone https://github.com/Haniver/tareasDeCastigo.git /home/lucio/Proyectos/tareaDeCastigo
cd /home/lucio/Proyectos/tareaDeCastigo

# 5. Backend
sudo -u lucio python3 -m venv backend/venv
sudo -u lucio cp backend/.env.example backend/.env   # poner DB_USER=lucio y la contraseña
chmod 600 backend/.env

# 6. Servicio systemd
cp tareadecastigo.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable tareadecastigo

# 7. Instala dependencias, carga la BD, compila el frontend y arranca el backend
./deploy.sh

# 8. nginx (primero HTTP, luego certbot agrega HTTPS)
cp nginx-tareadecastigo-temp.conf /etc/nginx/sites-available/tareadecastigo.work
ln -sf /etc/nginx/sites-available/tareadecastigo.work /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

# 9. Firewall
ufw allow OpenSSH && ufw allow 'Nginx Full' && ufw --force enable

# 10. SSL (cuando el DNS ya apunte al servidor)
certbot --nginx -d tareadecastigo.work -d www.tareadecastigo.work
```

---

## Panel de Administración

- **URL:** https://tareadecastigo.work/admin
- La contraseña se guarda en la tabla `config` (clave `password_admin`).
