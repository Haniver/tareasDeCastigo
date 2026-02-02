# 📝 Tarea de Castigo

Aplicación web para que alumnos practiquen conjugaciones verbales en español.

## Stack Tecnológico

- **Frontend**: React + Vite
- **Backend**: Python + FastAPI
- **Base de datos**: PostgreSQL

## Requisitos Previos

- Node.js 18+
- Python 3.10+
- PostgreSQL 14+

## Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/tarea-de-castigo.git
cd tarea-de-castigo
```

### 2. Configurar la base de datos

Crear la base de datos en PostgreSQL:

```bash
sudo -u postgres psql -c "CREATE DATABASE \"tareasDeCastigo\" OWNER tu_usuario;"
```

Ejecutar el script de inicialización:

```bash
psql -U tu_usuario -d tareasDeCastigo -f database/init_db.sql
```

### 3. Configurar el backend

```bash
cd backend

# Crear entorno virtual
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales de PostgreSQL
```

### 4. Configurar el frontend

```bash
cd frontend
npm install
```

## Ejecución

### Backend (desde la carpeta `backend/`)

```bash
source venv/bin/activate
uvicorn main:app --reload --port 8004
```

### Frontend (desde la carpeta `frontend/`)

```bash
npm run dev
```

La aplicación estará disponible en:
- **Frontend**: http://localhost:3004
- **Backend API**: http://localhost:8004
- **Documentación API**: http://localhost:8004/docs

## Credenciales por defecto

- **Panel de administración**: `/admin`
- **Contraseña inicial**: `maestra123` (cambiar después del primer login)

## Estructura del Proyecto

```
tarea-de-castigo/
├── backend/
│   ├── main.py           # Punto de entrada FastAPI
│   ├── database.py       # Configuración de BD
│   ├── models.py         # Modelos SQLAlchemy
│   ├── schemas.py        # Esquemas Pydantic
│   └── routers/          # Endpoints de la API
├── frontend/
│   ├── src/
│   │   ├── pages/        # Páginas de la aplicación
│   │   ├── components/   # Componentes reutilizables
│   │   └── api/          # Cliente HTTP
│   └── index.html
└── database/
    └── init_db.sql       # Script de inicialización
```

## Licencia

MIT
