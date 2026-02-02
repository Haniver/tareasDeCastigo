import { useNavigate } from 'react-router-dom';

function Home() {
  const navigate = useNavigate();

  return (
    <div className="container">
      <h1>📝 Tarea de Castigo</h1>
      <h2>Práctica de conjugación de verbos en español</h2>

      <div style={{ marginTop: '40px' }}>
        <button 
          className="btn btn-primary"
          onClick={() => navigate('/nueva')}
        >
          🆕 Iniciar nueva tarea
        </button>

        <button 
          className="btn btn-secondary"
          onClick={() => navigate('/retomar')}
        >
          🔄 Retomar tarea inconclusa
        </button>
      </div>

      <div style={{ marginTop: '60px', textAlign: 'center' }}>
        <button 
          className="btn btn-small"
          style={{ background: 'transparent', color: '#999' }}
          onClick={() => navigate('/admin')}
        >
          🔐 Acceso docente
        </button>
      </div>
    </div>
  );
}

export default Home;
