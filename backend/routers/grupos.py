from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import date

import models
import schemas
from database import get_db

router = APIRouter(prefix="/api/grupos", tags=["grupos"])


@router.get("/", response_model=List[schemas.Grupo])
def get_grupos_activos(db: Session = Depends(get_db)):
    """Obtiene grupos con fecha límite vigente (para el combo box de alumnos)"""
    hoy = date.today()
    grupos = db.query(models.Grupo).join(models.Tarea).filter(
        models.Tarea.fecha_limite >= hoy
    ).distinct().all()
    return grupos


@router.get("/todos", response_model=List[schemas.Grupo])
def get_todos_grupos(db: Session = Depends(get_db)):
    """Obtiene todos los grupos (para admin)"""
    return db.query(models.Grupo).all()


@router.get("/{grupo_id}", response_model=schemas.Grupo)
def get_grupo(grupo_id: int, db: Session = Depends(get_db)):
    grupo = db.query(models.Grupo).filter(models.Grupo.id == grupo_id).first()
    if not grupo:
        raise HTTPException(status_code=404, detail="Grupo no encontrado")
    return grupo


@router.get("/{grupo_id}/alumnos", response_model=List[schemas.AlumnoResumen])
def get_alumnos_grupo(grupo_id: int, db: Session = Depends(get_db)):
    """Obtiene alumnos que ya iniciaron en un grupo (para retomar tarea)"""
    alumnos = db.query(models.Alumno).filter(
        models.Alumno.grupo_id == grupo_id
    ).all()
    return alumnos


@router.post("/", response_model=schemas.Grupo)
def crear_grupo(grupo: schemas.GrupoCreate, db: Session = Depends(get_db)):
    db_grupo = db.query(models.Grupo).filter(
        models.Grupo.nombre == grupo.nombre
    ).first()
    if db_grupo:
        raise HTTPException(status_code=400, detail="Ya existe un grupo con ese nombre")
    
    nuevo_grupo = models.Grupo(nombre=grupo.nombre)
    db.add(nuevo_grupo)
    db.commit()
    db.refresh(nuevo_grupo)
    return nuevo_grupo


@router.put("/{grupo_id}", response_model=schemas.Grupo)
def actualizar_grupo(grupo_id: int, grupo: schemas.GrupoCreate, db: Session = Depends(get_db)):
    db_grupo = db.query(models.Grupo).filter(models.Grupo.id == grupo_id).first()
    if not db_grupo:
        raise HTTPException(status_code=404, detail="Grupo no encontrado")
    
    # Verificar que no exista otro grupo con el mismo nombre
    existente = db.query(models.Grupo).filter(
        models.Grupo.nombre == grupo.nombre,
        models.Grupo.id != grupo_id
    ).first()
    if existente:
        raise HTTPException(status_code=400, detail="Ya existe un grupo con ese nombre")
    
    db_grupo.nombre = grupo.nombre
    db.commit()
    db.refresh(db_grupo)
    return db_grupo


@router.delete("/{grupo_id}")
def eliminar_grupo(grupo_id: int, db: Session = Depends(get_db)):
    db_grupo = db.query(models.Grupo).filter(models.Grupo.id == grupo_id).first()
    if not db_grupo:
        raise HTTPException(status_code=404, detail="Grupo no encontrado")
    
    db.delete(db_grupo)
    db.commit()
    return {"message": "Grupo eliminado correctamente"}
