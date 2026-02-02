import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { getGruposActivos, getAlumnosGrupo } from '../api/client';

function ResumeStudent() {
  const navigate = useNavigate();
  const [grupos, setGrupos] = useState([]);
  const [grupoId, setGrupoId] = useState('');
  const [alumnos, setAlumnos] = useState([]);
  const [alumnoId, setAlumnoId] = useState('');
  const [loading, setLoading] = useState(true);
  const [loadingAlumnos, setLoadingAlumnos] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    cargarGrupos();
  }, []);

  useEffect(() => {
    if (grupoId) {
      cargarAlumnos();
    } else {
      setAlumnos([]);
      setAlumnoId('');
    }
  }, [grupoId]);

  const cargarGrupos = async () => {
    try {
      const response = await getGruposActivos();
      setGrupos(response.data);
      setLoading(false);
    } catch (err) {
      setError('Error al cargar los grupos');
      setLoading(false);
    }
  };

  const cargarAlumnos = async () => {
    setLoadingAlumnos(true);
    try {
      const response = await getAlumnosGrupo(grupoId);
      setAlumnos(response.data);
      setLoadingAlumnos(false);
    } catch (err) {
      setError('Error al cargar los alumnos');
      setLoadingAlumnos(false);
    }
  };

  const handleContinuar = () => {
    if (!alumnoId) {
      setError('Por favor selecciona tu nombre');
      return;
    }

    const alumno = alumnos.find(a => a.id === parseInt(alumnoId));
    
    if (alumno?.completado) {
      navigate(`/completado/${alumnoId}`);
    } else {
      navigate(`/tarea/${alumnoId}`);
    }
  };

  if (loading) {
    return (
      <div className="container">
        <div className="loading">
          <div className="spinner"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="container">
      <h1>🔄 Retomar Tarea</h1>
      <h2>Selecciona tu grupo y tu nombre</h2>

      {error && <div className="alert alert-error">{error}</div>}

      {grupos.length === 0 ? (
        <div className="alert alert-error">
          No hay grupos con tareas activas en este momento.
        </div>
      ) : (
        <>
          <div className="form-group">
            <label>Selecciona tu grupo:</label>
            <select 
              value={grupoId} 
              onChange={(e) => setGrupoId(e.target.value)}
            >
              <option value="">-- Selecciona un grupo --</option>
              {grupos.map(grupo => (
                <option key={grupo.id} value={grupo.id}>
                  {grupo.nombre}
                </option>
              ))}
            </select>
          </div>

          {grupoId && (
            <div className="form-group">
              <label>Selecciona tu nombre:</label>
              {loadingAlumnos ? (
                <div className="loading">
                  <div className="spinner"></div>
                </div>
              ) : alumnos.length === 0 ? (
                <p style={{ color: '#666' }}>
                  No hay alumnos registrados en este grupo. 
                  <button 
                    onClick={() => navigate('/nueva')}
                    style={{ 
                      background: 'none', 
                      border: 'none', 
                      color: '#667eea', 
                      cursor: 'pointer',
                      textDecoration: 'underline'
                    }}
                  >
                    Inicia una nueva tarea
                  </button>
                </p>
              ) : (
                <select 
                  value={alumnoId} 
                  onChange={(e) => setAlumnoId(e.target.value)}
                >
                  <option value="">-- Selecciona tu nombre --</option>
                  {alumnos.map(alumno => (
                    <option key={alumno.id} value={alumno.id}>
                      {alumno.nombre_completo} {alumno.completado ? '✅' : ''}
                    </option>
                  ))}
                </select>
              )}
            </div>
          )}

          {alumnoId && (
            <button 
              className="btn btn-primary"
              onClick={handleContinuar}
            >
              ✅ Continuar
            </button>
          )}
        </>
      )}

      <button 
        className="btn btn-secondary"
        onClick={() => navigate('/')}
      >
        ← Volver
      </button>
    </div>
  );
}

export default ResumeStudent;
