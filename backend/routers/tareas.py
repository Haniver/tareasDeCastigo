from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

import models
import schemas
from database import get_db

router = APIRouter(prefix="/api/tareas", tags=["tareas"])


@router.get("/", response_model=List[schemas.Tarea])
def get_tareas(db: Session = Depends(get_db)):
    """Obtiene todas las tareas"""
    tareas = db.query(models.Tarea).all()
    result = []
    for tarea in tareas:
        tarea_dict = {
            "id": tarea.id,
            "grupo_id": tarea.grupo_id,
            "fecha_limite": tarea.fecha_limite,
            "verbos": [{"id": tv.verbo.id, "infinitivo": tv.verbo.infinitivo} for tv in tarea.verbos],
            "tiempos": tarea.tiempos
        }
        result.append(tarea_dict)
    return result


@router.get("/{tarea_id}", response_model=schemas.Tarea)
def get_tarea(tarea_id: int, db: Session = Depends(get_db)):
    tarea = db.query(models.Tarea).filter(models.Tarea.id == tarea_id).first()
    if not tarea:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    
    return {
        "id": tarea.id,
        "grupo_id": tarea.grupo_id,
        "fecha_limite": tarea.fecha_limite,
        "verbos": [{"id": tv.verbo.id, "infinitivo": tv.verbo.infinitivo} for tv in tarea.verbos],
        "tiempos": tarea.tiempos
    }


@router.post("/", response_model=schemas.Tarea)
def crear_tarea(tarea: schemas.TareaCreate, db: Session = Depends(get_db)):
    """Crea una nueva tarea con verbos y tiempos"""
    # Verificar que el grupo existe
    grupo = db.query(models.Grupo).filter(models.Grupo.id == tarea.grupo_id).first()
    if not grupo:
        raise HTTPException(status_code=404, detail="Grupo no encontrado")
    
    # Verificar que los verbos existen
    for verbo_id in tarea.verbo_ids:
        verbo = db.query(models.Verbo).filter(models.Verbo.id == verbo_id).first()
        if not verbo:
            raise HTTPException(status_code=404, detail=f"Verbo con id {verbo_id} no encontrado")
    
    # Crear la tarea
    nueva_tarea = models.Tarea(
        grupo_id=tarea.grupo_id,
        fecha_limite=tarea.fecha_limite
    )
    db.add(nueva_tarea)
    db.flush()
    
    # Agregar verbos
    for verbo_id in tarea.verbo_ids:
        tarea_verbo = models.TareaVerbo(tarea_id=nueva_tarea.id, verbo_id=verbo_id)
        db.add(tarea_verbo)
    
    # Agregar tiempos
    for tiempo in tarea.tiempos:
        tarea_tiempo = models.TareaTiempo(
            tarea_id=nueva_tarea.id,
            modo=tiempo.modo,
            tiempo=tiempo.tiempo
        )
        db.add(tarea_tiempo)
    
    db.commit()
    db.refresh(nueva_tarea)
    
    return {
        "id": nueva_tarea.id,
        "grupo_id": nueva_tarea.grupo_id,
        "fecha_limite": nueva_tarea.fecha_limite,
        "verbos": [{"id": tv.verbo.id, "infinitivo": tv.verbo.infinitivo} for tv in nueva_tarea.verbos],
        "tiempos": nueva_tarea.tiempos
    }


@router.put("/{tarea_id}", response_model=schemas.Tarea)
def actualizar_tarea(tarea_id: int, tarea: schemas.TareaUpdate, db: Session = Depends(get_db)):
    """Actualiza una tarea"""
    db_tarea = db.query(models.Tarea).filter(models.Tarea.id == tarea_id).first()
    if not db_tarea:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    
    # Actualizar fecha límite si se proporciona
    if tarea.fecha_limite:
        db_tarea.fecha_limite = tarea.fecha_limite
    
    # Actualizar verbos si se proporcionan
    if tarea.verbo_ids is not None:
        # Eliminar verbos existentes
        db.query(models.TareaVerbo).filter(models.TareaVerbo.tarea_id == tarea_id).delete()
        # Agregar nuevos verbos
        for verbo_id in tarea.verbo_ids:
            tarea_verbo = models.TareaVerbo(tarea_id=tarea_id, verbo_id=verbo_id)
            db.add(tarea_verbo)
    
    # Actualizar tiempos si se proporcionan
    if tarea.tiempos is not None:
        # Eliminar tiempos existentes
        db.query(models.TareaTiempo).filter(models.TareaTiempo.tarea_id == tarea_id).delete()
        # Agregar nuevos tiempos
        for tiempo in tarea.tiempos:
            tarea_tiempo = models.TareaTiempo(
                tarea_id=tarea_id,
                modo=tiempo.modo,
                tiempo=tiempo.tiempo
            )
            db.add(tarea_tiempo)
    
    db.commit()
    db.refresh(db_tarea)
    
    return {
        "id": db_tarea.id,
        "grupo_id": db_tarea.grupo_id,
        "fecha_limite": db_tarea.fecha_limite,
        "verbos": [{"id": tv.verbo.id, "infinitivo": tv.verbo.infinitivo} for tv in db_tarea.verbos],
        "tiempos": db_tarea.tiempos
    }


@router.delete("/{tarea_id}")
def eliminar_tarea(tarea_id: int, db: Session = Depends(get_db)):
    db_tarea = db.query(models.Tarea).filter(models.Tarea.id == tarea_id).first()
    if not db_tarea:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    
    db.delete(db_tarea)
    db.commit()
    return {"message": "Tarea eliminada correctamente"}
