from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date

import models
import schemas
from database import get_db

router = APIRouter(prefix="/api/alumnos", tags=["alumnos"])

# Orden de los tiempos para cada modo
ORDEN_TIEMPOS = {
    "indicativo": [
        "presente", "preterito", "futuro", "copreterito", "pospreterito",
        "antepresente", "antepreterito", "antefuturo", "antecopreterito", "antepospreterito"
    ],
    "subjuntivo": [
        "presente", "preterito", "futuro",
        "antepresente", "antepreterito", "antefuturo"
    ],
    "imperativo": ["presente"]
}

# Orden de los modos
ORDEN_MODOS = ["indicativo", "subjuntivo", "imperativo"]

# Personas por modo
PERSONAS_POR_MODO = {
    "indicativo": ["yo", "tu", "el", "nosotros", "vosotros", "ellos"],
    "subjuntivo": ["yo", "tu", "el", "nosotros", "vosotros", "ellos"],
    "imperativo": ["tu", "nosotros", "vosotros"]
}


def obtener_siguiente_formulario(alumno: models.Alumno, tarea: models.Tarea, db: Session) -> Optional[schemas.FormularioConjugacion]:
    """Determina el siguiente formulario que debe completar el alumno"""
    
    # Obtener verbos y tiempos de la tarea
    verbo_ids = [tv.verbo_id for tv in tarea.verbos]
    tiempos_tarea = [(tt.modo, tt.tiempo) for tt in tarea.tiempos]
    
    # Ordenar tiempos según el orden definido
    tiempos_ordenados = []
    for modo in ORDEN_MODOS:
        for tiempo in ORDEN_TIEMPOS.get(modo, []):
            if (modo, tiempo) in tiempos_tarea:
                tiempos_ordenados.append((modo, tiempo))
    
    # Para cada verbo, buscar el primer tiempo no completado
    for verbo_id in verbo_ids:
        verbo = db.query(models.Verbo).filter(models.Verbo.id == verbo_id).first()
        
        for modo, tiempo in tiempos_ordenados:
            # Verificar si ya está completado
            progreso = db.query(models.ProgresoAlumno).filter(
                models.ProgresoAlumno.alumno_id == alumno.id,
                models.ProgresoAlumno.tarea_id == tarea.id,
                models.ProgresoAlumno.verbo_id == verbo_id,
                models.ProgresoAlumno.modo == modo,
                models.ProgresoAlumno.tiempo == tiempo,
                models.ProgresoAlumno.completado == True
            ).first()
            
            if not progreso:
                # Este es el siguiente formulario
                return schemas.FormularioConjugacion(
                    verbo_id=verbo_id,
                    infinitivo=verbo.infinitivo,
                    modo=modo,
                    tiempo=tiempo,
                    personas=PERSONAS_POR_MODO[modo]
                )
    
    return None


@router.post("/", response_model=schemas.Alumno)
def crear_alumno(alumno: schemas.AlumnoCreate, db: Session = Depends(get_db)):
    """Registra un nuevo alumno"""
    # Verificar que el grupo existe y tiene tarea activa
    hoy = date.today()
    tarea = db.query(models.Tarea).filter(
        models.Tarea.grupo_id == alumno.grupo_id,
        models.Tarea.fecha_limite >= hoy
    ).first()
    
    if not tarea:
        raise HTTPException(status_code=400, detail="El grupo no tiene tareas activas")
    
    # Verificar si ya existe el alumno
    existente = db.query(models.Alumno).filter(
        models.Alumno.grupo_id == alumno.grupo_id,
        models.Alumno.nombre_completo == alumno.nombre_completo
    ).first()
    
    if existente:
        raise HTTPException(status_code=400, detail="Ya existe un alumno con ese nombre en el grupo")
    
    nuevo_alumno = models.Alumno(
        grupo_id=alumno.grupo_id,
        nombre_completo=alumno.nombre_completo
    )
    db.add(nuevo_alumno)
    db.commit()
    db.refresh(nuevo_alumno)
    return nuevo_alumno


@router.get("/{alumno_id}", response_model=schemas.Alumno)
def get_alumno(alumno_id: int, db: Session = Depends(get_db)):
    alumno = db.query(models.Alumno).filter(models.Alumno.id == alumno_id).first()
    if not alumno:
        raise HTTPException(status_code=404, detail="Alumno no encontrado")
    return alumno


@router.get("/{alumno_id}/formulario", response_model=Optional[schemas.FormularioConjugacion])
def get_siguiente_formulario(alumno_id: int, db: Session = Depends(get_db)):
    """Obtiene el siguiente formulario que debe completar el alumno"""
    alumno = db.query(models.Alumno).filter(models.Alumno.id == alumno_id).first()
    if not alumno:
        raise HTTPException(status_code=404, detail="Alumno no encontrado")
    
    if alumno.completado:
        return None
    
    # Obtener la tarea del grupo
    hoy = date.today()
    tarea = db.query(models.Tarea).filter(
        models.Tarea.grupo_id == alumno.grupo_id,
        models.Tarea.fecha_limite >= hoy
    ).first()
    
    if not tarea:
        raise HTTPException(status_code=400, detail="No hay tarea activa para este grupo")
    
    return obtener_siguiente_formulario(alumno, tarea, db)


@router.post("/{alumno_id}/respuesta", response_model=schemas.ResultadoRespuesta)
def enviar_respuesta(alumno_id: int, respuestas: schemas.EnviarRespuestas, db: Session = Depends(get_db)):
    """Envía las respuestas del alumno para un formulario"""
    alumno = db.query(models.Alumno).filter(models.Alumno.id == alumno_id).first()
    if not alumno:
        raise HTTPException(status_code=404, detail="Alumno no encontrado")
    
    # Obtener la tarea
    hoy = date.today()
    tarea = db.query(models.Tarea).filter(
        models.Tarea.grupo_id == alumno.grupo_id,
        models.Tarea.fecha_limite >= hoy
    ).first()
    
    if not tarea:
        raise HTTPException(status_code=400, detail="No hay tarea activa")
    
    # Obtener las conjugaciones correctas
    conjugaciones = db.query(models.Conjugacion).filter(
        models.Conjugacion.verbo_id == respuestas.verbo_id,
        models.Conjugacion.modo == respuestas.modo,
        models.Conjugacion.tiempo == respuestas.tiempo
    ).all()
    
    # Crear diccionario de respuestas correctas
    correctas = {}
    for c in conjugaciones:
        correctas[c.persona] = {
            "forma": c.forma,
            "forma_alternativa": c.forma_alternativa
        }
    
    # Verificar respuestas
    errores = []
    for resp in respuestas.respuestas:
        if resp.persona not in correctas:
            continue
        
        correcta = correctas[resp.persona]
        respuesta_lower = resp.respuesta.strip().lower()
        forma_lower = correcta["forma"].lower()
        forma_alt_lower = correcta["forma_alternativa"].lower() if correcta["forma_alternativa"] else None
        
        es_correcta = (respuesta_lower == forma_lower or 
                      (forma_alt_lower and respuesta_lower == forma_alt_lower))
        
        if not es_correcta:
            errores.append(schemas.ErrorConjugacion(
                persona=resp.persona,
                respuesta_incorrecta=resp.respuesta,
                respuesta_correcta=correcta["forma"]
            ))
    
    if not errores:
        # Todo correcto, marcar como completado
        progreso = db.query(models.ProgresoAlumno).filter(
            models.ProgresoAlumno.alumno_id == alumno_id,
            models.ProgresoAlumno.tarea_id == tarea.id,
            models.ProgresoAlumno.verbo_id == respuestas.verbo_id,
            models.ProgresoAlumno.modo == respuestas.modo,
            models.ProgresoAlumno.tiempo == respuestas.tiempo
        ).first()
        
        if not progreso:
            progreso = models.ProgresoAlumno(
                alumno_id=alumno_id,
                tarea_id=tarea.id,
                verbo_id=respuestas.verbo_id,
                modo=respuestas.modo,
                tiempo=respuestas.tiempo,
                completado=True
            )
            db.add(progreso)
        else:
            progreso.completado = True
        
        db.commit()
        
        # Obtener siguiente formulario
        siguiente = obtener_siguiente_formulario(alumno, tarea, db)
        
        if not siguiente:
            # Tarea completada
            alumno.completado = True
            db.commit()
            return schemas.ResultadoRespuesta(
                correcto=True,
                errores=[],
                siguiente_formulario=None,
                tarea_completada=True
            )
        
        return schemas.ResultadoRespuesta(
            correcto=True,
            errores=[],
            siguiente_formulario=siguiente,
            tarea_completada=False
        )
    
    # Hay errores
    return schemas.ResultadoRespuesta(
        correcto=False,
        errores=errores,
        siguiente_formulario=None,
        tarea_completada=False
    )


@router.post("/{alumno_id}/completar-castigo", response_model=schemas.ResultadoRespuesta)
def completar_castigo(alumno_id: int, datos: schemas.EnviarRespuestas, db: Session = Depends(get_db)):
    """Marca un formulario como completado después del castigo"""
    alumno = db.query(models.Alumno).filter(models.Alumno.id == alumno_id).first()
    if not alumno:
        raise HTTPException(status_code=404, detail="Alumno no encontrado")
    
    # Obtener la tarea
    hoy = date.today()
    tarea = db.query(models.Tarea).filter(
        models.Tarea.grupo_id == alumno.grupo_id,
        models.Tarea.fecha_limite >= hoy
    ).first()
    
    if not tarea:
        raise HTTPException(status_code=400, detail="No hay tarea activa")
    
    # Marcar como completado
    progreso = db.query(models.ProgresoAlumno).filter(
        models.ProgresoAlumno.alumno_id == alumno_id,
        models.ProgresoAlumno.tarea_id == tarea.id,
        models.ProgresoAlumno.verbo_id == datos.verbo_id,
        models.ProgresoAlumno.modo == datos.modo,
        models.ProgresoAlumno.tiempo == datos.tiempo
    ).first()
    
    if not progreso:
        progreso = models.ProgresoAlumno(
            alumno_id=alumno_id,
            tarea_id=tarea.id,
            verbo_id=datos.verbo_id,
            modo=datos.modo,
            tiempo=datos.tiempo,
            completado=True
        )
        db.add(progreso)
    else:
        progreso.completado = True
    
    db.commit()
    
    # Obtener siguiente formulario
    siguiente = obtener_siguiente_formulario(alumno, tarea, db)
    
    if not siguiente:
        # Tarea completada
        alumno.completado = True
        db.commit()
        return schemas.ResultadoRespuesta(
            correcto=True,
            errores=[],
            siguiente_formulario=None,
            tarea_completada=True
        )
    
    return schemas.ResultadoRespuesta(
        correcto=True,
        errores=[],
        siguiente_formulario=siguiente,
        tarea_completada=False
    )


@router.get("/{alumno_id}/progreso")
def get_progreso_alumno(alumno_id: int, db: Session = Depends(get_db)):
    """Obtiene el progreso del alumno"""
    alumno = db.query(models.Alumno).filter(models.Alumno.id == alumno_id).first()
    if not alumno:
        raise HTTPException(status_code=404, detail="Alumno no encontrado")
    
    # Obtener la tarea
    tarea = db.query(models.Tarea).filter(
        models.Tarea.grupo_id == alumno.grupo_id
    ).first()
    
    if not tarea:
        return {"total": 0, "completados": 0, "porcentaje": 0}
    
    # Calcular total de formularios
    num_verbos = len(tarea.verbos)
    num_tiempos = len(tarea.tiempos)
    total = num_verbos * num_tiempos
    
    # Contar completados
    completados = db.query(models.ProgresoAlumno).filter(
        models.ProgresoAlumno.alumno_id == alumno_id,
        models.ProgresoAlumno.tarea_id == tarea.id,
        models.ProgresoAlumno.completado == True
    ).count()
    
    porcentaje = (completados / total * 100) if total > 0 else 0
    
    return {
        "total": total,
        "completados": completados,
        "porcentaje": round(porcentaje, 2),
        "tarea_completada": alumno.completado
    }
