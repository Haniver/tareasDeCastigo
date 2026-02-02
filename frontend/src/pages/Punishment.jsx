import { useState, useEffect } from 'react';
import { useParams, useNavigate, useLocation } from 'react-router-dom';
import { completarCastigo, completarCastigoIndividual } from '../api/client';
import NoCopyInput from '../components/NoCopyInput';

const PERSONA_LABELS = {
  'yo': 'Yo',
  'tu': 'Tú',
  'el': 'Él/Ella',
  'nosotros': 'Nosotros',
  'vosotros': 'Vosotros',
  'ellos': 'Ellos/Ellas'
};

const REPETICIONES_REQUERIDAS = 10;

function Punishment() {
  const { alumnoId } = useParams();
  const navigate = useNavigate();
  const location = useLocation();
  
  const [errores, setErrores] = useState([]);
  const [formulario, setFormulario] = useState(null);
  const [errorActual, setErrorActual] = useState(0);
  const [repeticiones, setRepeticiones] = useState([]);
  const [completados, setCompletados] = useState([]);
  const [guardando, setGuardando] = useState(false);

  useEffect(() => {
    if (!location.state?.errores || !location.state?.formulario) {
      navigate(`/tarea/${alumnoId}`);
      return;
    }
    
    setErrores(location.state.errores);
    setFormulario(location.state.formulario);
    inicializarRepeticiones(location.state.errores[0]);
  }, []);

  const inicializarRepeticiones = (error) => {
    setRepeticiones(Array(REPETICIONES_REQUERIDAS).fill(''));
    setCompletados(Array(REPETICIONES_REQUERIDAS).fill(false));
  };

  const handleInputChange = (index, value) => {
    const nuevasRepeticiones = [...repeticiones];
    nuevasRepeticiones[index] = value;
    setRepeticiones(nuevasRepeticiones);

    // Verificar si es correcta (case-insensitive)
    const errorActualData = errores[errorActual];
    const esCorrecta = value.toLowerCase().trim() === errorActualData.respuesta_correcta.toLowerCase();
    
    const nuevosCompletados = [...completados];
    nuevosCompletados[index] = esCorrecta;
    setCompletados(nuevosCompletados);
  };

  const todasCorrectas = () => {
    return completados.every(c => c === true);
  };

  const handleSiguiente = async () => {
    setGuardando(true);
    
    try {
      // Marcar el castigo actual como completado si tiene ID (viene de castigos pendientes)
      const errorActualData = errores[errorActual];
      if (errorActualData.castigo_id) {
        await completarCastigoIndividual(alumnoId, errorActualData.castigo_id);
      }
      
      if (errorActual < errores.length - 1) {
        // Siguiente error
        setErrorActual(errorActual + 1);
        inicializarRepeticiones(errores[errorActual + 1]);
        setGuardando(false);
      } else {
        // Todos los errores completados, marcar formulario como completado en el backend
        const response = await completarCastigo(alumnoId, {
          verbo_id: formulario.verbo_id,
          modo: formulario.modo,
          tiempo: formulario.tiempo,
          respuestas: [] // No necesitamos las respuestas, solo marcar como completado
        });
        
        if (response.data.tarea_completada) {
          navigate(`/completado/${alumnoId}`);
        } else {
          navigate(`/tarea/${alumnoId}`, { state: { fromPunishment: true } });
        }
      }
    } catch (err) {
      console.error('Error al guardar progreso:', err);
      setGuardando(false);
      // Aún así, intentar continuar si es el último error
      if (errorActual >= errores.length - 1) {
        navigate(`/tarea/${alumnoId}`, { state: { fromPunishment: true } });
      }
    }
  };

  if (errores.length === 0) {
    return null;
  }

  const errorData = errores[errorActual];

  return (
    <div className="container">
      <h1>✏️ Corrección</h1>
      <h2>
        Escribe correctamente la conjugación {errorActual + 1} de {errores.length}
      </h2>

      <div className="punishment-container">
        <div className="punishment-word">
          <div className="persona">{PERSONA_LABELS[errorData.persona]}</div>
          <div className="correct">{errorData.respuesta_correcta}</div>
          <p style={{ color: '#666', fontSize: '0.9rem', marginTop: '10px' }}>
            Tu respuesta fue: <span style={{ textDecoration: 'line-through', color: '#eb3349' }}>
              {errorData.respuesta_incorrecta}
            </span>
          </p>
        </div>

        <p style={{ textAlign: 'center', marginBottom: '20px', color: '#555' }}>
          Escribe la palabra correcta {REPETICIONES_REQUERIDAS} veces:
        </p>

        <div className="punishment-inputs">
          {repeticiones.map((rep, index) => (
            <NoCopyInput
              key={index}
              value={rep}
              onChange={(value) => handleInputChange(index, value)}
              className={`punishment-input ${completados[index] ? 'correct' : rep && !completados[index] ? 'incorrect' : ''}`}
              placeholder={`${index + 1}`}
            />
          ))}
        </div>

        <div className="counter">
          {completados.filter(c => c).length} de {REPETICIONES_REQUERIDAS} correctas
        </div>
      </div>

      <button 
        className="btn btn-primary"
        disabled={!todasCorrectas() || guardando}
        onClick={handleSiguiente}
      >
        {guardando 
          ? 'Guardando...'
          : errorActual < errores.length - 1 
          ? `Siguiente palabra (${errorActual + 2}/${errores.length}) →`
          : 'Continuar con la tarea →'
        }
      </button>
    </div>
  );
}

export default Punishment;
