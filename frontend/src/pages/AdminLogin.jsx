import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { adminLogin } from '../api/client';

function AdminLogin() {
  const navigate = useNavigate();
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!password.trim()) {
      setError('Por favor ingresa la contraseña');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const response = await adminLogin(password);
      
      if (response.data.success) {
        // Guardar sesión en localStorage
        localStorage.setItem('adminAuth', 'true');
        navigate('/admin/panel');
      } else {
        setError(response.data.message || 'Contraseña incorrecta');
      }
    } catch (err) {
      setError('Error al iniciar sesión');
    }
    
    setLoading(false);
  };

  return (
    <div className="container">
      <h1>🔐 Acceso Docente</h1>
      <h2>Ingresa tu contraseña para continuar</h2>

      {error && <div className="alert alert-error">{error}</div>}

      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label>Contraseña:</label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Ingresa la contraseña"
          />
        </div>

        <button 
          type="submit" 
          className="btn btn-primary"
          disabled={loading}
        >
          {loading ? 'Verificando...' : 'Ingresar'}
        </button>
      </form>

      <button 
        className="btn btn-secondary"
        onClick={() => navigate('/')}
      >
        ← Volver
      </button>
    </div>
  );
}

export default AdminLogin;
