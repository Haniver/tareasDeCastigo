import { useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import confetti from 'canvas-confetti';

function Completed() {
  const { alumnoId } = useParams();
  const navigate = useNavigate();

  useEffect(() => {
    // Lanzar confetti
    const duration = 5 * 1000;
    const animationEnd = Date.now() + duration;
    const defaults = { startVelocity: 30, spread: 360, ticks: 60, zIndex: 0 };

    function randomInRange(min, max) {
      return Math.random() * (max - min) + min;
    }

    const interval = setInterval(function() {
      const timeLeft = animationEnd - Date.now();

      if (timeLeft <= 0) {
        return clearInterval(interval);
      }

      const particleCount = 50 * (timeLeft / duration);

      confetti({
        ...defaults,
        particleCount,
        origin: { x: randomInRange(0.1, 0.3), y: Math.random() - 0.2 }
      });
      confetti({
        ...defaults,
        particleCount,
        origin: { x: randomInRange(0.7, 0.9), y: Math.random() - 0.2 }
      });
    }, 250);

    return () => clearInterval(interval);
  }, []);

  return (
    <div className="container">
      <div className="completed-container">
        <div className="trophy">🏆</div>
        
        <h1 style={{ marginTop: '30px' }}>¡Felicidades!</h1>
        
        <p className="completed-message">
          ¡Felicidades por terminar la tarea de castigo! 
          <br /><br />
          A ver si a la próxima te portas mejor y convences a tus compañeros de hacerlo también.
        </p>

        <button 
          className="btn btn-secondary"
          onClick={() => navigate('/')}
        >
          Volver al inicio
        </button>
      </div>
    </div>
  );
}

export default Completed;
