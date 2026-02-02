import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { getGruposActivos, crearAlumno } from '../api/client';

function NewStudent() {
  const navigate = useNavigate();
  const [grupos, setGrupos] = useState([]);
  const [grupoId, setGrupoId] = useState('');
  const [nombre, setNombre] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    cargarGrupos();
  }, []);

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

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!grupoId || !nombre.trim()) {
      setError('Por favor completa todos los campos');
      return;
    }

    setSubmitting(true);
    setError('');

    try {
      const response = await crearAlumno({
        grupo_id: parseInt(grupoId),
        nombre_completo: nombre.trim()
      });
      
      navigate(`/tarea/${response.data.id}`);
    } catch (err) {
      if (err.response?.data?.detail) {
        setError(err.response.data.detail);
      } else {
        setError('Error al registrar. Intenta de nuevo.');
      }
      setSubmitting(false);
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
      <h1>🆕 Iniciar Nueva Tarea</h1>
      <h2>Ingresa tus datos para comenzar</h2>

      {error && <div className="alert alert-error">{error}</div>}

      {grupos.length === 0 ? (
        <div className="alert alert-error">
          No hay grupos con tareas activas en este momento.
        </div>
      ) : (
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Selecciona tu grupo:</label>
            <select 
              value={grupoId} 
              onChange={(e) => setGrupoId(e.target.value)}
              required
            >
              <option value="">-- Selecciona un grupo --</option>
              {grupos.map(grupo => (
                <option key={grupo.id} value={grupo.id}>
                  {grupo.nombre}
                </option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label>Tu nombre completo:</label>
            <input
              type="text"
              value={nombre}
              onChange={(e) => setNombre(e.target.value)}
              placeholder="Escribe tu nombre y apellidos"
              required
            />
          </div>

          <button 
            type="submit" 
            className="btn btn-primary"
            disabled={submitting}
          >
            {submitting ? 'Registrando...' : '✅ Comenzar tarea'}
          </button>
        </form>
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

export default NewStudent;
