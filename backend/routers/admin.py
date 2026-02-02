from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import date

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
    
    # Verificar si hay que hacer limpieza anual
    realizar_limpieza_anual(db)
    
    return schemas.AdminLoginResponse(success=True, message="Login exitoso")


def realizar_limpieza_anual(db: Session):
    """Limpia tareas, grupos y alumnos si es el primer login después del 29 de julio"""
    hoy = date.today()
    
    # Obtener fecha del último reset
    config_reset = db.query(models.Config).filter(models.Config.clave == "ultimo_reset_anual").first()
    
    if not config_reset:
        # Crear configuración si no existe
        config_reset = models.Config(clave="ultimo_reset_anual", valor="2025-07-29")
        db.add(config_reset)
        db.commit()
    
    ultimo_reset = date.fromisoformat(config_reset.valor)
    
    # Calcular la fecha límite para el reset de este año
    anio_actual = hoy.year
    fecha_reset_este_anio = date(anio_actual, 7, 29)
    
    # Si ya pasó el 29 de julio de este año y el último reset fue antes
    if hoy >= fecha_reset_este_anio and ultimo_reset < fecha_reset_este_anio:
        # Eliminar alumnos (esto también elimina su progreso por cascade)
        db.query(models.Alumno).delete()
        
        # Eliminar tareas (esto también elimina tarea_verbos y tarea_tiempos por cascade)
        db.query(models.Tarea).delete()
        
        # Eliminar grupos
        db.query(models.Grupo).delete()
        
        # Actualizar fecha de último reset
        config_reset.valor = hoy.isoformat()
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
