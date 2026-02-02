from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers import grupos, verbos, tareas, alumnos, admin

app = FastAPI(
    title="Tarea de Castigo API",
    description="API para la aplicación de conjugación de verbos en español",
    version="1.0.0"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3004", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Incluir routers
app.include_router(grupos.router)
app.include_router(verbos.router)
app.include_router(tareas.router)
app.include_router(alumnos.router)
app.include_router(admin.router)


@app.get("/")
def root():
    return {"message": "Bienvenido a la API de Tarea de Castigo"}


@app.get("/api/health")
def health_check():
    return {"status": "ok"}
