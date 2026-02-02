from sqlalchemy import Column, Integer, String, Boolean, Date, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from database import Base


class Config(Base):
    __tablename__ = "config"

    clave = Column(String(50), primary_key=True)
    valor = Column(String, nullable=False)


class Verbo(Base):
    __tablename__ = "verbos"

    id = Column(Integer, primary_key=True, index=True)
    infinitivo = Column(String(50), unique=True, nullable=False)

    conjugaciones = relationship("Conjugacion", back_populates="verbo", cascade="all, delete-orphan")


class Conjugacion(Base):
    __tablename__ = "conjugaciones"

    id = Column(Integer, primary_key=True, index=True)
    verbo_id = Column(Integer, ForeignKey("verbos.id", ondelete="CASCADE"), nullable=False)
    modo = Column(String(20), nullable=False)
    tiempo = Column(String(20), nullable=False)
    persona = Column(String(20), nullable=False)
    forma = Column(String(100), nullable=False)
    forma_alternativa = Column(String(100), nullable=True)

    verbo = relationship("Verbo", back_populates="conjugaciones")

    __table_args__ = (
        UniqueConstraint('verbo_id', 'modo', 'tiempo', 'persona', name='uq_conjugacion'),
    )


class Grupo(Base):
    __tablename__ = "grupos"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), unique=True, nullable=False)

    alumnos = relationship("Alumno", back_populates="grupo", cascade="all, delete-orphan")
    tareas = relationship("Tarea", back_populates="grupo", cascade="all, delete-orphan")


class Tarea(Base):
    __tablename__ = "tareas"

    id = Column(Integer, primary_key=True, index=True)
    grupo_id = Column(Integer, ForeignKey("grupos.id", ondelete="CASCADE"), nullable=False)
    fecha_limite = Column(Date, nullable=False)

    grupo = relationship("Grupo", back_populates="tareas")
    verbos = relationship("TareaVerbo", back_populates="tarea", cascade="all, delete-orphan")
    tiempos = relationship("TareaTiempo", back_populates="tarea", cascade="all, delete-orphan")
    progresos = relationship("ProgresoAlumno", back_populates="tarea", cascade="all, delete-orphan")


class TareaVerbo(Base):
    __tablename__ = "tarea_verbos"

    id = Column(Integer, primary_key=True, index=True)
    tarea_id = Column(Integer, ForeignKey("tareas.id", ondelete="CASCADE"), nullable=False)
    verbo_id = Column(Integer, ForeignKey("verbos.id", ondelete="CASCADE"), nullable=False)

    tarea = relationship("Tarea", back_populates="verbos")
    verbo = relationship("Verbo")

    __table_args__ = (
        UniqueConstraint('tarea_id', 'verbo_id', name='uq_tarea_verbo'),
    )


class TareaTiempo(Base):
    __tablename__ = "tarea_tiempos"

    id = Column(Integer, primary_key=True, index=True)
    tarea_id = Column(Integer, ForeignKey("tareas.id", ondelete="CASCADE"), nullable=False)
    modo = Column(String(20), nullable=False)
    tiempo = Column(String(20), nullable=False)

    tarea = relationship("Tarea", back_populates="tiempos")

    __table_args__ = (
        UniqueConstraint('tarea_id', 'modo', 'tiempo', name='uq_tarea_tiempo'),
    )


class Alumno(Base):
    __tablename__ = "alumnos"

    id = Column(Integer, primary_key=True, index=True)
    grupo_id = Column(Integer, ForeignKey("grupos.id", ondelete="CASCADE"), nullable=False)
    nombre_completo = Column(String(200), nullable=False)
    completado = Column(Boolean, default=False, nullable=False)

    grupo = relationship("Grupo", back_populates="alumnos")
    progresos = relationship("ProgresoAlumno", back_populates="alumno", cascade="all, delete-orphan")

    __table_args__ = (
        UniqueConstraint('grupo_id', 'nombre_completo', name='uq_alumno_grupo'),
    )


class ProgresoAlumno(Base):
    __tablename__ = "progreso_alumno"

    id = Column(Integer, primary_key=True, index=True)
    alumno_id = Column(Integer, ForeignKey("alumnos.id", ondelete="CASCADE"), nullable=False)
    tarea_id = Column(Integer, ForeignKey("tareas.id", ondelete="CASCADE"), nullable=False)
    verbo_id = Column(Integer, ForeignKey("verbos.id", ondelete="CASCADE"), nullable=False)
    modo = Column(String(20), nullable=False)
    tiempo = Column(String(20), nullable=False)
    completado = Column(Boolean, default=False, nullable=False)

    alumno = relationship("Alumno", back_populates="progresos")
    tarea = relationship("Tarea", back_populates="progresos")
    verbo = relationship("Verbo")

    __table_args__ = (
        UniqueConstraint('alumno_id', 'tarea_id', 'verbo_id', 'modo', 'tiempo', name='uq_progreso'),
    )
