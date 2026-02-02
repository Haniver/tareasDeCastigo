from pydantic import BaseModel
from typing import Optional, List
from datetime import date


# Config
class ConfigBase(BaseModel):
    clave: str
    valor: str


# Verbo
class VerboBase(BaseModel):
    infinitivo: str


class VerboCreate(VerboBase):
    pass


class Verbo(VerboBase):
    id: int

    class Config:
        from_attributes = True


# Conjugacion
class ConjugacionBase(BaseModel):
    modo: str
    tiempo: str
    persona: str
    forma: str
    forma_alternativa: Optional[str] = None


class ConjugacionCreate(ConjugacionBase):
    pass


class Conjugacion(ConjugacionBase):
    id: int
    verbo_id: int

    class Config:
        from_attributes = True


class VerboConConjugaciones(Verbo):
    conjugaciones: List[Conjugacion] = []


# Grupo
class GrupoBase(BaseModel):
    nombre: str


class GrupoCreate(GrupoBase):
    pass


class Grupo(GrupoBase):
    id: int

    class Config:
        from_attributes = True


# Alumno
class AlumnoBase(BaseModel):
    nombre_completo: str
    grupo_id: int


class AlumnoCreate(AlumnoBase):
    pass


class Alumno(AlumnoBase):
    id: int
    completado: bool

    class Config:
        from_attributes = True


class AlumnoResumen(BaseModel):
    id: int
    nombre_completo: str
    completado: bool

    class Config:
        from_attributes = True


# TareaTiempo
class TareaTiempoBase(BaseModel):
    modo: str
    tiempo: str


class TareaTiempoCreate(TareaTiempoBase):
    pass


class TareaTiempo(TareaTiempoBase):
    id: int
    tarea_id: int

    class Config:
        from_attributes = True


# Tarea
class TareaBase(BaseModel):
    grupo_id: int
    fecha_limite: date


class TareaCreate(TareaBase):
    verbo_ids: List[int]
    tiempos: List[TareaTiempoCreate]


class TareaUpdate(BaseModel):
    fecha_limite: Optional[date] = None
    verbo_ids: Optional[List[int]] = None
    tiempos: Optional[List[TareaTiempoCreate]] = None


class TareaVerboInfo(BaseModel):
    id: int
    infinitivo: str

    class Config:
        from_attributes = True


class Tarea(TareaBase):
    id: int
    verbos: List[TareaVerboInfo] = []
    tiempos: List[TareaTiempo] = []

    class Config:
        from_attributes = True


# Progreso
class ProgresoBase(BaseModel):
    alumno_id: int
    tarea_id: int
    verbo_id: int
    modo: str
    tiempo: str
    completado: bool = False


class Progreso(ProgresoBase):
    id: int

    class Config:
        from_attributes = True


# Formulario de conjugación (lo que ve el alumno)
class FormularioConjugacion(BaseModel):
    verbo_id: int
    infinitivo: str
    modo: str
    tiempo: str
    personas: List[str]  # Las personas que debe llenar


class RespuestaConjugacion(BaseModel):
    persona: str
    respuesta: str


class EnviarRespuestas(BaseModel):
    verbo_id: int
    modo: str
    tiempo: str
    respuestas: List[RespuestaConjugacion]


class ErrorConjugacion(BaseModel):
    persona: str
    respuesta_incorrecta: str
    respuesta_correcta: str


class ResultadoRespuesta(BaseModel):
    correcto: bool
    errores: List[ErrorConjugacion] = []
    siguiente_formulario: Optional[FormularioConjugacion] = None
    tarea_completada: bool = False


# Admin
class AdminLogin(BaseModel):
    password: str


class AdminLoginResponse(BaseModel):
    success: bool
    message: str


# Progreso de alumno para el admin
class ProgresoAlumnoAdmin(BaseModel):
    alumno_id: int
    nombre_completo: str
    grupo_nombre: str
    total_formularios: int
    formularios_completados: int
    porcentaje: float
    completado: bool


class VerboCreateConConjugaciones(BaseModel):
    infinitivo: str
    conjugaciones: List[ConjugacionCreate]
