import { useState, useEffect } from 'react';
import { useParams, useNavigate, useLocation } from 'react-router-dom';
import { getFormulario, enviarRespuesta, getAlumno, getProgresoAlumno } from '../api/client';
import NoCopyInput from '../components/NoCopyInput';

const PERSONA_LABELS = {
  'yo': 'Yo',
  'tu': 'Tú',
  'el': 'Él/Ella',
  'nosotros': 'Nosotros',
  'vosotros': 'Vosotros',
  'ellos': 'Ellos/Ellas'
};

const TIEMPO_LABELS = {
  'presente': 'Presente',
  'preterito': 'Pretérito',
  'futuro': 'Futuro',
  'copreterito': 'Copretérito',
  'pospreterito': 'Pospretérito',
  'antepresente': 'Antepresente',
  'antepreterito': 'Antepretérito',
  'antefuturo': 'Antefuturo',
  'antecopreterito': 'Antecopretérito',
  'antepospreterito': 'Antepospretérito'
};

const MODO_LABELS = {
  'indicativo': 'Indicativo',
  'subjuntivo': 'Subjuntivo',
  'imperativo': 'Imperativo'
};

function Task() {
  const { alumnoId } = useParams();
  const navigate = useNavigate();
  const location = useLocation();
  
  const [formulario, setFormulario] = useState(null);
  const [respuestas, setRespuestas] = useState({});
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [progreso, setProgreso] = useState(null);
  const [alumno, setAlumno] = useState(null);

  useEffect(() => {
    cargarDatos();
  }, [alumnoId]);

  // Si venimos del castigo, cargar el formulario siguiente
  useEffect(() => {
    if (location.state?.fromPunishment) {
      cargarFormulario();
    }
  }, [location]);

  const cargarDatos = async () => {
    try {
      const [alumnoRes, progresoRes] = await Promise.all([
        getAlumno(alumnoId),
        getProgresoAlumno(alumnoId)
      ]);
      
      setAlumno(alumnoRes.data);
      setProgreso(progresoRes.data);
      
      if (alumnoRes.data.completado) {
        navigate(`/completado/${alumnoId}`);
        return;
      }
      
      await cargarFormulario();
    } catch (err) {
      setError('Error al cargar los datos');
      setLoading(false);
    }
  };

  const cargarFormulario = async () => {
    setLoading(true);
    try {
      const response = await getFormulario(alumnoId);
      
      if (!response.data) {
        navigate(`/completado/${alumnoId}`);
        return;
      }
      
      setFormulario(response.data);
      
      // Inicializar respuestas vacías
      const inicial = {};
      response.data.personas.forEach(p => {
        inicial[p] = '';
      });
      setRespuestas(inicial);
      
      // Actualizar progreso
      const progresoRes = await getProgresoAlumno(alumnoId);
      setProgreso(progresoRes.data);
      
      setLoading(false);
    } catch (err) {
      setError('Error al cargar el formulario');
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Verificar que todas las respuestas estén llenas
    const vacias = Object.entries(respuestas).filter(([_, v]) => !v.trim());
    if (vacias.length > 0) {
      setError('Por favor completa todas las conjugaciones');
      return;
    }

    setSubmitting(true);
    setError('');

    try {
      const data = {
        verbo_id: formulario.verbo_id,
        modo: formulario.modo,
        tiempo: formulario.tiempo,
        respuestas: Object.entries(respuestas).map(([persona, respuesta]) => ({
          persona,
          respuesta: respuesta.trim()
        }))
      };

      const response = await enviarRespuesta(alumnoId, data);
      
      if (response.data.tarea_completada) {
        navigate(`/completado/${alumnoId}`);
      } else if (response.data.correcto) {
        // Correcto, cargar siguiente formulario
        await cargarFormulario();
      } else {
        // Hay errores, ir a pantalla de castigo
        navigate(`/castigo/${alumnoId}`, { 
          state: { 
            errores: response.data.errores,
            formulario: formulario
          } 
        });
      }
      
      setSubmitting(false);
    } catch (err) {
      setError('Error al enviar las respuestas');
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

  if (!formulario) {
    return (
      <div className="container">
        <div className="alert alert-error">
          No se pudo cargar el formulario
        </div>
        <button className="btn btn-secondary" onClick={() => navigate('/')}>
          Volver al inicio
        </button>
      </div>
    );
  }

  return (
    <div className="container">
      {progreso && (
        <div style={{ marginBottom: '20px' }}>
          <div className="progress-bar">
            <div 
              className="progress-fill" 
              style={{ width: `${progreso.porcentaje}%` }}
            ></div>
          </div>
          <p style={{ textAlign: 'center', marginTop: '5px', color: '#666', fontSize: '0.9rem' }}>
            {progreso.completados} de {progreso.total} formularios completados ({progreso.porcentaje}%)
          </p>
        </div>
      )}

      {error && <div className="alert alert-error">{error}</div>}

      <form onSubmit={handleSubmit}>
        <div className="verb-card">
          <div className="verb-header">
            <div className="verb-infinitive">{formulario.infinitivo}</div>
            <div className="verb-tense">
              {MODO_LABELS[formulario.modo]} - {TIEMPO_LABELS[formulario.tiempo]}
            </div>
          </div>

          <div className="conjugation-grid">
            {formulario.personas.map(persona => (
              <div key={persona} className="conjugation-item">
                <label>{PERSONA_LABELS[persona]}:</label>
                <NoCopyInput
                  value={respuestas[persona] || ''}
                  onChange={(value) => setRespuestas({...respuestas, [persona]: value})}
                  placeholder="Escribe la conjugación"
                />
              </div>
            ))}
          </div>
        </div>

        <button 
          type="submit" 
          className="btn btn-primary"
          disabled={submitting}
        >
          {submitting ? 'Enviando...' : 'Siguiente →'}
        </button>
      </form>
    </div>
  );
}

export default Task;
