from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

import models
import schemas
from database import get_db

router = APIRouter(prefix="/api/verbos", tags=["verbos"])


@router.get("/", response_model=List[schemas.Verbo])
def get_verbos(db: Session = Depends(get_db)):
    """Obtiene todos los verbos"""
    return db.query(models.Verbo).order_by(models.Verbo.infinitivo).all()


@router.get("/{verbo_id}", response_model=schemas.VerboConConjugaciones)
def get_verbo(verbo_id: int, db: Session = Depends(get_db)):
    """Obtiene un verbo con todas sus conjugaciones"""
    verbo = db.query(models.Verbo).filter(models.Verbo.id == verbo_id).first()
    if not verbo:
        raise HTTPException(status_code=404, detail="Verbo no encontrado")
    return verbo


@router.post("/", response_model=schemas.Verbo)
def crear_verbo(verbo: schemas.VerboCreateConConjugaciones, db: Session = Depends(get_db)):
    """Crea un verbo con sus conjugaciones"""
    # Verificar que no exista
    existente = db.query(models.Verbo).filter(
        models.Verbo.infinitivo == verbo.infinitivo.lower()
    ).first()
    if existente:
        raise HTTPException(status_code=400, detail="Ya existe un verbo con ese infinitivo")
    
    # Crear el verbo
    nuevo_verbo = models.Verbo(infinitivo=verbo.infinitivo.lower())
    db.add(nuevo_verbo)
    db.flush()  # Para obtener el ID
    
    # Crear las conjugaciones
    for conj in verbo.conjugaciones:
        nueva_conj = models.Conjugacion(
            verbo_id=nuevo_verbo.id,
            modo=conj.modo,
            tiempo=conj.tiempo,
            persona=conj.persona,
            forma=conj.forma,
            forma_alternativa=conj.forma_alternativa
        )
        db.add(nueva_conj)
    
    db.commit()
    db.refresh(nuevo_verbo)
    return nuevo_verbo


@router.put("/{verbo_id}", response_model=schemas.Verbo)
def actualizar_verbo(verbo_id: int, verbo: schemas.VerboCreateConConjugaciones, db: Session = Depends(get_db)):
    """Actualiza un verbo y sus conjugaciones"""
    db_verbo = db.query(models.Verbo).filter(models.Verbo.id == verbo_id).first()
    if not db_verbo:
        raise HTTPException(status_code=404, detail="Verbo no encontrado")
    
    # Verificar que no exista otro verbo con el mismo infinitivo
    existente = db.query(models.Verbo).filter(
        models.Verbo.infinitivo == verbo.infinitivo.lower(),
        models.Verbo.id != verbo_id
    ).first()
    if existente:
        raise HTTPException(status_code=400, detail="Ya existe un verbo con ese infinitivo")
    
    # Actualizar infinitivo
    db_verbo.infinitivo = verbo.infinitivo.lower()
    
    # Eliminar conjugaciones existentes
    db.query(models.Conjugacion).filter(
        models.Conjugacion.verbo_id == verbo_id
    ).delete()
    
    # Crear nuevas conjugaciones
    for conj in verbo.conjugaciones:
        nueva_conj = models.Conjugacion(
            verbo_id=verbo_id,
            modo=conj.modo,
            tiempo=conj.tiempo,
            persona=conj.persona,
            forma=conj.forma,
            forma_alternativa=conj.forma_alternativa
        )
        db.add(nueva_conj)
    
    db.commit()
    db.refresh(db_verbo)
    return db_verbo


@router.delete("/{verbo_id}")
def eliminar_verbo(verbo_id: int, db: Session = Depends(get_db)):
    """Elimina un verbo y todas sus conjugaciones"""
    db_verbo = db.query(models.Verbo).filter(models.Verbo.id == verbo_id).first()
    if not db_verbo:
        raise HTTPException(status_code=404, detail="Verbo no encontrado")
    
    db.delete(db_verbo)
    db.commit()
    return {"message": "Verbo eliminado correctamente"}


@router.get("/{verbo_id}/conjugaciones", response_model=List[schemas.Conjugacion])
def get_conjugaciones_verbo(verbo_id: int, modo: str = None, tiempo: str = None, db: Session = Depends(get_db)):
    """Obtiene conjugaciones de un verbo, opcionalmente filtradas por modo y tiempo"""
    query = db.query(models.Conjugacion).filter(models.Conjugacion.verbo_id == verbo_id)
    
    if modo:
        query = query.filter(models.Conjugacion.modo == modo)
    if tiempo:
        query = query.filter(models.Conjugacion.tiempo == tiempo)
    
    return query.all()
