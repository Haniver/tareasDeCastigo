from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import date, timedelta

import models
import schemas
from database import get_db

router = APIRouter(prefix="/api/admin", tags=["admin"])


@router.post("/login", response_model=schemas.AdminLoginResponse)
def admin_login(login: schemas.AdminLogin, db: Session = Depends(get_db)):
    """Autenticación de la maestra"""
    # Obtener contraseña de la BD
    config = db.query(models.Config).filter(models.Config.clave == "password_admin").first()
    
    if not config:
        raise HTTPException(status_code=500, detail="Configuración no encontrada")
    
    if login.password != config.valor:
        return schemas.AdminLoginResponse(success=False, message="Contraseña incorrecta")
    
    # Limpiar tareas antiguas (más de 45 días después de su fecha límite)
    realizar_limpieza_tareas_antiguas(db)
    
    return schemas.AdminLoginResponse(success=True, message="Login exitoso")


def realizar_limpieza_tareas_antiguas(db: Session):
    """Elimina tareas cuya fecha límite haya pasado hace más de 45 días, junto con sus alumnos asociados"""
    hoy = date.today()
    fecha_corte = hoy - timedelta(days=45)
    
    # Buscar tareas antiguas
    tareas_antiguas = db.query(models.Tarea).filter(
        models.Tarea.fecha_limite < fecha_corte
    ).all()
    
    for tarea in tareas_antiguas:
        # Eliminar alumnos del grupo asociado a esta tarea
        # (el progreso y castigos pendientes se eliminan en cascada)
        db.query(models.Alumno).filter(
            models.Alumno.grupo_id == tarea.grupo_id
        ).delete()
        
        # Eliminar la tarea (tarea_verbos, tarea_tiempos y progresos se eliminan en cascada)
        db.delete(tarea)
    
    if tareas_antiguas:
        db.commit()


@router.get("/progreso", response_model=List[schemas.ProgresoAlumnoAdmin])
def get_progreso_todos(db: Session = Depends(get_db)):
    """Obtiene el progreso de todos los alumnos"""
    alumnos = db.query(models.Alumno).all()
    resultado = []
    
    for alumno in alumnos:
        grupo = db.query(models.Grupo).filter(models.Grupo.id == alumno.grupo_id).first()
        
        # Obtener la tarea del grupo
        tarea = db.query(models.Tarea).filter(
            models.Tarea.grupo_id == alumno.grupo_id
        ).first()
        
        if not tarea:
            continue
        
        # Calcular total de formularios
        num_verbos = len(tarea.verbos)
        num_tiempos = len(tarea.tiempos)
        total = num_verbos * num_tiempos
        
        # Contar completados
        completados = db.query(models.ProgresoAlumno).filter(
            models.ProgresoAlumno.alumno_id == alumno.id,
            models.ProgresoAlumno.tarea_id == tarea.id,
            models.ProgresoAlumno.completado == True
        ).count()
        
        porcentaje = (completados / total * 100) if total > 0 else 0
        
        resultado.append(schemas.ProgresoAlumnoAdmin(
            alumno_id=alumno.id,
            nombre_completo=alumno.nombre_completo,
            grupo_nombre=grupo.nombre if grupo else "Sin grupo",
            fecha_limite=tarea.fecha_limite,
            total_formularios=total,
            formularios_completados=completados,
            porcentaje=round(porcentaje, 2),
            completado=alumno.completado
        ))
    
    return resultado


@router.put("/password")
def cambiar_password(nuevo_password: str, db: Session = Depends(get_db)):
    """Cambia la contraseña de admin"""
    config = db.query(models.Config).filter(models.Config.clave == "password_admin").first()
    
    if not config:
        config = models.Config(clave="password_admin", valor=nuevo_password)
        db.add(config)
    else:
        config.valor = nuevo_password
    
    db.commit()
    return {"message": "Contraseña actualizada"}
