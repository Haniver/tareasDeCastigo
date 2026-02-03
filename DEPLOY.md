# Instrucciones de Despliegue

## Requisitos
- Acceso SSH al servidor
- Permisos sudo
- Git configurado

## Servidor de Producción
- **URL:** https://tareadecastigo.work
- **IP:** 104.251.217.178
- **Usuario:** lucio

---

## Desplegar Cambios

### 1. Obtener últimos cambios del repositorio
```bash
cd /home/lucio/Proyectos/tareaDeCastigo
git pull origin main
```

### 2. Reconstruir el frontend
```bash
cd /home/lucio/Proyectos/tareaDeCastigo/frontend
npm install  # Solo si hay nuevas dependencias
npm run build
```

### 3. Reiniciar el backend
```bash
sudo systemctl restart tareadecastigo
```

### 4. Verificar que todo funcione
```bash
# Verificar estado del servicio
sudo systemctl status tareadecastigo

# Probar la API
curl https://tareadecastigo.work/api/health

# Probar el frontend
curl -s -o /dev/null -w "%{http_code}" https://tareadecastigo.work
```

---

## Comandos Útiles

### Servicios

| Acción | Comando |
|--------|---------|
| Ver estado del backend | `sudo systemctl status tareadecastigo` |
| Reiniciar backend | `sudo systemctl restart tareadecastigo` |
| Detener backend | `sudo systemctl stop tareadecastigo` |
| Iniciar backend | `sudo systemctl start tareadecastigo` |
| Ver logs del backend | `sudo journalctl -u tareadecastigo -f` |
| Recargar nginx | `sudo systemctl reload nginx` |
| Ver logs de nginx | `sudo tail -f /var/log/nginx/error.log` |

### Base de Datos

```bash
# Conectar a PostgreSQL
PGPASSWORD=Lqw9XumKrevwYt3y psql -U lucio -d tareasDeCastigo

# Ejecutar script SQL
PGPASSWORD=Lqw9XumKrevwYt3y psql -U lucio -d tareasDeCastigo -f database/init_db.sql
```

---

## Migraciones de Base de Datos

Si hay cambios en el esquema de la base de datos:

```bash
cd /home/lucio/Proyectos/tareaDeCastigo
PGPASSWORD=Lqw9XumKrevwYt3y psql -U lucio -d tareasDeCastigo -f database/init_db.sql
```

O ejecutar comandos SQL específicos:
```bash
PGPASSWORD=Lqw9XumKrevwYt3y psql -U lucio -d tareasDeCastigo -c "TU_COMANDO_SQL_AQUÍ"
```

---

## Archivos de Configuración

| Archivo | Ubicación |
|---------|-----------|
| Servicio systemd | `/etc/systemd/system/tareadecastigo.service` |
| Configuración nginx | `/etc/nginx/sites-available/tareadecastigo.work` |
| Variables de entorno | `/home/lucio/Proyectos/tareaDeCastigo/backend/.env` |
| Frontend compilado | `/home/lucio/Proyectos/tareaDeCastigo/frontend/dist/` |

---

## Solución de Problemas

### El backend no inicia (puerto ocupado)
```bash
sudo fuser -k 8004/tcp
sudo systemctl restart tareadecastigo
```

### Error de permisos en nginx
```bash
chmod 755 /home/lucio
chmod -R 755 /home/lucio/Proyectos/tareaDeCastigo
sudo systemctl reload nginx
```

### Renovar certificado SSL
```bash
sudo certbot renew
```

### Ver errores del backend en tiempo real
```bash
sudo journalctl -u tareadecastigo -f --no-pager
```

---

## Despliegue Completo (desde cero)

```bash
# 1. Clonar repositorio
git clone https://github.com/Haniver/tareasDeCastigo.git
cd tareasDeCastigo

# 2. Configurar backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Editar .env con las credenciales correctas

# 3. Configurar base de datos
PGPASSWORD=tu_password psql -U lucio -d tareasDeCastigo -f ../database/init_db.sql

# 4. Construir frontend
cd ../frontend
npm install
npm run build

# 5. Instalar servicios
sudo cp ../tareadecastigo.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now tareadecastigo

# 6. Configurar nginx
sudo cp ../nginx-tareadecastigo.conf /etc/nginx/sites-available/tareadecastigo.work
sudo ln -sf /etc/nginx/sites-available/tareadecastigo.work /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# 7. Obtener certificado SSL
sudo certbot --nginx -d tareadecastigo.work -d www.tareadecastigo.work
```

---

## Credenciales

- **Panel Admin:** https://tareadecastigo.work/admin
- **Contraseña Admin:** `maestra123` (almacenada en tabla `config`)
