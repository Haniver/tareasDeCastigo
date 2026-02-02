import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  getVerbos, crearVerbo, actualizarVerbo, eliminarVerbo,
  getTodosGrupos, crearGrupo, actualizarGrupo, eliminarGrupo,
  getTareas, crearTarea, actualizarTarea, eliminarTarea,
  getProgresoTodos
} from '../api/client';

const MODOS_TIEMPOS = {
  indicativo: {
    simples: ['presente', 'preterito', 'futuro', 'copreterito', 'pospreterito'],
    compuestos: ['antepresente', 'antepreterito', 'antefuturo', 'antecopreterito', 'antepospreterito']
  },
  subjuntivo: {
    simples: ['presente', 'preterito', 'futuro'],
    compuestos: ['antepresente', 'antepreterito', 'antefuturo']
  },
  imperativo: {
    simples: ['presente'],
    compuestos: []
  }
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

const PERSONAS = ['yo', 'tu', 'el', 'nosotros', 'vosotros', 'ellos'];
const PERSONAS_IMPERATIVO = ['tu', 'nosotros', 'vosotros'];

function AdminPanel() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('verbos');
  
  // Estados para cada sección
  const [verbos, setVerbos] = useState([]);
  const [grupos, setGrupos] = useState([]);
  const [tareas, setTareas] = useState([]);
  const [progreso, setProgreso] = useState([]);
  
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  
  // Modales
  const [showVerboModal, setShowVerboModal] = useState(false);
  const [showGrupoModal, setShowGrupoModal] = useState(false);
  const [showTareaModal, setShowTareaModal] = useState(false);
  
  const [editingItem, setEditingItem] = useState(null);

  useEffect(() => {
    // Verificar autenticación
    if (!localStorage.getItem('adminAuth')) {
      navigate('/admin');
      return;
    }
    
    cargarDatos();
  }, []);

  const cargarDatos = async () => {
    setLoading(true);
    try {
      const [verbosRes, gruposRes, tareasRes, progresoRes] = await Promise.all([
        getVerbos(),
        getTodosGrupos(),
        getTareas(),
        getProgresoTodos()
      ]);
      
      setVerbos(verbosRes.data);
      setGrupos(gruposRes.data);
      setTareas(tareasRes.data);
      setProgreso(progresoRes.data);
    } catch (err) {
      setError('Error al cargar datos');
    }
    setLoading(false);
  };

  const handleLogout = () => {
    localStorage.removeItem('adminAuth');
    navigate('/admin');
  };

  if (loading) {
    return (
      <div className="container container-wide">
        <div className="loading">
          <div className="spinner"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="container container-wide">
      <div className="section-header">
        <h1>📚 Panel de Administración</h1>
        <button className="btn btn-small btn-secondary" onClick={handleLogout}>
          Cerrar sesión
        </button>
      </div>

      {error && <div className="alert alert-error">{error}</div>}

      <div className="tabs">
        <button 
          className={`tab ${activeTab === 'verbos' ? 'active' : ''}`}
          onClick={() => setActiveTab('verbos')}
        >
          Verbos
        </button>
        <button 
          className={`tab ${activeTab === 'grupos' ? 'active' : ''}`}
          onClick={() => setActiveTab('grupos')}
        >
          Grupos
        </button>
        <button 
          className={`tab ${activeTab === 'tareas' ? 'active' : ''}`}
          onClick={() => setActiveTab('tareas')}
        >
          Tareas
        </button>
        <button 
          className={`tab ${activeTab === 'progreso' ? 'active' : ''}`}
          onClick={() => setActiveTab('progreso')}
        >
          Progreso
        </button>
      </div>

      {activeTab === 'verbos' && (
        <VerbosTab 
          verbos={verbos} 
          onRefresh={cargarDatos}
          showModal={showVerboModal}
          setShowModal={setShowVerboModal}
          editingItem={editingItem}
          setEditingItem={setEditingItem}
        />
      )}

      {activeTab === 'grupos' && (
        <GruposTab 
          grupos={grupos} 
          onRefresh={cargarDatos}
          showModal={showGrupoModal}
          setShowModal={setShowGrupoModal}
          editingItem={editingItem}
          setEditingItem={setEditingItem}
        />
      )}

      {activeTab === 'tareas' && (
        <TareasTab 
          tareas={tareas} 
          grupos={grupos}
          verbos={verbos}
          onRefresh={cargarDatos}
          showModal={showTareaModal}
          setShowModal={setShowTareaModal}
          editingItem={editingItem}
          setEditingItem={setEditingItem}
        />
      )}

      {activeTab === 'progreso' && (
        <ProgresoTab progreso={progreso} />
      )}
    </div>
  );
}

// Componente para Verbos
function VerbosTab({ verbos, onRefresh, showModal, setShowModal, editingItem, setEditingItem }) {
  const [formData, setFormData] = useState({
    infinitivo: '',
    conjugaciones: []
  });
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const initConjugaciones = () => {
    const conjs = [];
    Object.entries(MODOS_TIEMPOS).forEach(([modo, tiempos]) => {
      [...tiempos.simples, ...tiempos.compuestos].forEach(tiempo => {
        const personas = modo === 'imperativo' ? PERSONAS_IMPERATIVO : PERSONAS;
        personas.forEach(persona => {
          conjs.push({
            modo,
            tiempo,
            persona,
            forma: '',
            forma_alternativa: ''
          });
        });
      });
    });
    return conjs;
  };

  const openCreateModal = () => {
    setFormData({
      infinitivo: '',
      conjugaciones: initConjugaciones()
    });
    setEditingItem(null);
    setShowModal(true);
  };

  const openEditModal = async (verbo) => {
    try {
      const response = await fetch(`/api/verbos/${verbo.id}`);
      const data = await response.json();
      
      // Mapear conjugaciones existentes
      const conjs = initConjugaciones();
      data.conjugaciones.forEach(c => {
        const idx = conjs.findIndex(
          x => x.modo === c.modo && x.tiempo === c.tiempo && x.persona === c.persona
        );
        if (idx !== -1) {
          conjs[idx].forma = c.forma;
          conjs[idx].forma_alternativa = c.forma_alternativa || '';
        }
      });
      
      setFormData({
        infinitivo: data.infinitivo,
        conjugaciones: conjs
      });
      setEditingItem(verbo);
      setShowModal(true);
    } catch (err) {
      setError('Error al cargar verbo');
    }
  };

  const handleSave = async () => {
    if (!formData.infinitivo.trim()) {
      setError('El infinitivo es requerido');
      return;
    }
    
    // Filtrar solo conjugaciones con forma
    const conjugacionesValidas = formData.conjugaciones.filter(c => c.forma.trim());
    
    if (conjugacionesValidas.length === 0) {
      setError('Debes agregar al menos una conjugación');
      return;
    }
    
    setSaving(true);
    setError('');
    
    try {
      const data = {
        infinitivo: formData.infinitivo.trim(),
        conjugaciones: conjugacionesValidas.map(c => ({
          modo: c.modo,
          tiempo: c.tiempo,
          persona: c.persona,
          forma: c.forma.trim(),
          forma_alternativa: c.forma_alternativa?.trim() || null
        }))
      };
      
      if (editingItem) {
        await actualizarVerbo(editingItem.id, data);
      } else {
        await crearVerbo(data);
      }
      
      setShowModal(false);
      onRefresh();
    } catch (err) {
      setError(err.response?.data?.detail || 'Error al guardar');
    }
    
    setSaving(false);
  };

  const handleDelete = async (id) => {
    if (!confirm('¿Seguro que deseas eliminar este verbo?')) return;
    
    try {
      await eliminarVerbo(id);
      onRefresh();
    } catch (err) {
      setError('Error al eliminar');
    }
  };

  const updateConjugacion = (modo, tiempo, persona, field, value) => {
    setFormData(prev => ({
      ...prev,
      conjugaciones: prev.conjugaciones.map(c => 
        c.modo === modo && c.tiempo === tiempo && c.persona === persona
          ? { ...c, [field]: value }
          : c
      )
    }));
  };

  return (
    <div>
      <div className="section-header">
        <h3>Verbos ({verbos.length})</h3>
        <button className="btn btn-small btn-primary" onClick={openCreateModal}>
          + Agregar verbo
        </button>
      </div>

      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Infinitivo</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {verbos.map(verbo => (
              <tr key={verbo.id}>
                <td>{verbo.id}</td>
                <td>{verbo.infinitivo}</td>
                <td>
                  <button 
                    className="btn btn-small btn-secondary"
                    onClick={() => openEditModal(verbo)}
                  >
                    Editar
                  </button>
                  <button 
                    className="btn btn-small btn-danger"
                    onClick={() => handleDelete(verbo.id)}
                  >
                    Eliminar
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div className="modal-overlay">
          <div className="modal">
            <div className="modal-header">
              <h3>{editingItem ? 'Editar Verbo' : 'Nuevo Verbo'}</h3>
              <button className="modal-close" onClick={() => setShowModal(false)}>×</button>
            </div>

            {error && <div className="alert alert-error">{error}</div>}

            <div className="form-group">
              <label>Infinitivo:</label>
              <input
                type="text"
                value={formData.infinitivo}
                onChange={(e) => setFormData({...formData, infinitivo: e.target.value})}
                placeholder="ej: cantar"
              />
            </div>

            <h4>Conjugaciones</h4>
            
            {Object.entries(MODOS_TIEMPOS).map(([modo, tiempos]) => (
              <div key={modo} className="conjugation-section">
                <h4 style={{ textTransform: 'capitalize' }}>{modo}</h4>
                
                {[...tiempos.simples, ...tiempos.compuestos].map(tiempo => {
                  const personas = modo === 'imperativo' ? PERSONAS_IMPERATIVO : PERSONAS;
                  const tieneAlternativa = modo === 'subjuntivo' && 
                    (tiempo === 'preterito' || tiempo === 'antepreterito');
                  
                  return (
                    <div key={tiempo} style={{ marginBottom: '15px' }}>
                      <strong>{TIEMPO_LABELS[tiempo]}</strong>
                      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '10px', marginTop: '5px' }}>
                        {personas.map(persona => {
                          const conj = formData.conjugaciones.find(
                            c => c.modo === modo && c.tiempo === tiempo && c.persona === persona
                          );
                          return (
                            <div key={persona}>
                              <label style={{ fontSize: '0.8rem' }}>{persona}:</label>
                              <input
                                type="text"
                                value={conj?.forma || ''}
                                onChange={(e) => updateConjugacion(modo, tiempo, persona, 'forma', e.target.value)}
                                placeholder="conjugación"
                                style={{ fontSize: '0.9rem', padding: '5px' }}
                              />
                              {tieneAlternativa && (
                                <input
                                  type="text"
                                  value={conj?.forma_alternativa || ''}
                                  onChange={(e) => updateConjugacion(modo, tiempo, persona, 'forma_alternativa', e.target.value)}
                                  placeholder="alternativa"
                                  style={{ fontSize: '0.9rem', padding: '5px', marginTop: '3px' }}
                                />
                              )}
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  );
                })}
              </div>
            ))}

            <div style={{ display: 'flex', gap: '10px', marginTop: '20px' }}>
              <button className="btn btn-primary" onClick={handleSave} disabled={saving}>
                {saving ? 'Guardando...' : 'Guardar'}
              </button>
              <button className="btn btn-secondary" onClick={() => setShowModal(false)}>
                Cancelar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// Componente para Grupos
function GruposTab({ grupos, onRefresh, showModal, setShowModal, editingItem, setEditingItem }) {
  const [nombre, setNombre] = useState('');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const openCreateModal = () => {
    setNombre('');
    setEditingItem(null);
    setShowModal(true);
  };

  const openEditModal = (grupo) => {
    setNombre(grupo.nombre);
    setEditingItem(grupo);
    setShowModal(true);
  };

  const handleSave = async () => {
    if (!nombre.trim()) {
      setError('El nombre es requerido');
      return;
    }
    
    setSaving(true);
    setError('');
    
    try {
      if (editingItem) {
        await actualizarGrupo(editingItem.id, { nombre: nombre.trim() });
      } else {
        await crearGrupo({ nombre: nombre.trim() });
      }
      
      setShowModal(false);
      onRefresh();
    } catch (err) {
      setError(err.response?.data?.detail || 'Error al guardar');
    }
    
    setSaving(false);
  };

  const handleDelete = async (id) => {
    if (!confirm('¿Seguro que deseas eliminar este grupo? Se eliminarán también sus alumnos y tareas.')) return;
    
    try {
      await eliminarGrupo(id);
      onRefresh();
    } catch (err) {
      setError('Error al eliminar');
    }
  };

  return (
    <div>
      <div className="section-header">
        <h3>Grupos ({grupos.length})</h3>
        <button className="btn btn-small btn-primary" onClick={openCreateModal}>
          + Agregar grupo
        </button>
      </div>

      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Nombre</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {grupos.map(grupo => (
              <tr key={grupo.id}>
                <td>{grupo.id}</td>
                <td>{grupo.nombre}</td>
                <td>
                  <button 
                    className="btn btn-small btn-secondary"
                    onClick={() => openEditModal(grupo)}
                  >
                    Editar
                  </button>
                  <button 
                    className="btn btn-small btn-danger"
                    onClick={() => handleDelete(grupo.id)}
                  >
                    Eliminar
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div className="modal-overlay">
          <div className="modal">
            <div className="modal-header">
              <h3>{editingItem ? 'Editar Grupo' : 'Nuevo Grupo'}</h3>
              <button className="modal-close" onClick={() => setShowModal(false)}>×</button>
            </div>

            {error && <div className="alert alert-error">{error}</div>}

            <div className="form-group">
              <label>Nombre del grupo:</label>
              <input
                type="text"
                value={nombre}
                onChange={(e) => setNombre(e.target.value)}
                placeholder="ej: 3ro A"
              />
            </div>

            <div style={{ display: 'flex', gap: '10px' }}>
              <button className="btn btn-primary" onClick={handleSave} disabled={saving}>
                {saving ? 'Guardando...' : 'Guardar'}
              </button>
              <button className="btn btn-secondary" onClick={() => setShowModal(false)}>
                Cancelar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// Componente para Tareas
function TareasTab({ tareas, grupos, verbos, onRefresh, showModal, setShowModal, editingItem, setEditingItem }) {
  const [formData, setFormData] = useState({
    grupo_id: '',
    fecha_limite: '',
    verbo_ids: [],
    tiempos: []
  });
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const openCreateModal = () => {
    setFormData({
      grupo_id: '',
      fecha_limite: '',
      verbo_ids: [],
      tiempos: []
    });
    setEditingItem(null);
    setShowModal(true);
  };

  const openEditModal = (tarea) => {
    setFormData({
      grupo_id: tarea.grupo_id.toString(),
      fecha_limite: tarea.fecha_limite,
      verbo_ids: tarea.verbos.map(v => v.id),
      tiempos: tarea.tiempos.map(t => ({ modo: t.modo, tiempo: t.tiempo }))
    });
    setEditingItem(tarea);
    setShowModal(true);
  };

  const handleSave = async () => {
    if (!formData.grupo_id || !formData.fecha_limite) {
      setError('Grupo y fecha límite son requeridos');
      return;
    }
    
    if (formData.verbo_ids.length === 0) {
      setError('Selecciona al menos un verbo');
      return;
    }
    
    if (formData.tiempos.length === 0) {
      setError('Selecciona al menos un tiempo');
      return;
    }
    
    setSaving(true);
    setError('');
    
    try {
      const data = {
        grupo_id: parseInt(formData.grupo_id),
        fecha_limite: formData.fecha_limite,
        verbo_ids: formData.verbo_ids,
        tiempos: formData.tiempos
      };
      
      if (editingItem) {
        await actualizarTarea(editingItem.id, data);
      } else {
        await crearTarea(data);
      }
      
      setShowModal(false);
      onRefresh();
    } catch (err) {
      setError(err.response?.data?.detail || 'Error al guardar');
    }
    
    setSaving(false);
  };

  const handleDelete = async (id) => {
    if (!confirm('¿Seguro que deseas eliminar esta tarea?')) return;
    
    try {
      await eliminarTarea(id);
      onRefresh();
    } catch (err) {
      setError('Error al eliminar');
    }
  };

  const toggleVerbo = (verboId) => {
    setFormData(prev => ({
      ...prev,
      verbo_ids: prev.verbo_ids.includes(verboId)
        ? prev.verbo_ids.filter(id => id !== verboId)
        : [...prev.verbo_ids, verboId]
    }));
  };

  const toggleTiempo = (modo, tiempo) => {
    setFormData(prev => {
      const exists = prev.tiempos.some(t => t.modo === modo && t.tiempo === tiempo);
      return {
        ...prev,
        tiempos: exists
          ? prev.tiempos.filter(t => !(t.modo === modo && t.tiempo === tiempo))
          : [...prev.tiempos, { modo, tiempo }]
      };
    });
  };

  const getGrupoNombre = (grupoId) => {
    const grupo = grupos.find(g => g.id === grupoId);
    return grupo?.nombre || 'Desconocido';
  };

  return (
    <div>
      <div className="section-header">
        <h3>Tareas ({tareas.length})</h3>
        <button className="btn btn-small btn-primary" onClick={openCreateModal}>
          + Agregar tarea
        </button>
      </div>

      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Grupo</th>
              <th>Fecha límite</th>
              <th>Verbos</th>
              <th>Tiempos</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {tareas.map(tarea => (
              <tr key={tarea.id}>
                <td>{tarea.id}</td>
                <td>{getGrupoNombre(tarea.grupo_id)}</td>
                <td>{tarea.fecha_limite}</td>
                <td>{tarea.verbos.map(v => v.infinitivo).join(', ')}</td>
                <td>{tarea.tiempos.length} tiempos</td>
                <td>
                  <button 
                    className="btn btn-small btn-secondary"
                    onClick={() => openEditModal(tarea)}
                  >
                    Editar
                  </button>
                  <button 
                    className="btn btn-small btn-danger"
                    onClick={() => handleDelete(tarea.id)}
                  >
                    Eliminar
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div className="modal-overlay">
          <div className="modal">
            <div className="modal-header">
              <h3>{editingItem ? 'Editar Tarea' : 'Nueva Tarea'}</h3>
              <button className="modal-close" onClick={() => setShowModal(false)}>×</button>
            </div>

            {error && <div className="alert alert-error">{error}</div>}

            <div className="form-group">
              <label>Grupo:</label>
              <select
                value={formData.grupo_id}
                onChange={(e) => setFormData({...formData, grupo_id: e.target.value})}
              >
                <option value="">-- Selecciona un grupo --</option>
                {grupos.map(grupo => (
                  <option key={grupo.id} value={grupo.id}>{grupo.nombre}</option>
                ))}
              </select>
            </div>

            <div className="form-group">
              <label>Fecha límite:</label>
              <input
                type="date"
                value={formData.fecha_limite}
                onChange={(e) => setFormData({...formData, fecha_limite: e.target.value})}
              />
            </div>

            <div className="form-group">
              <label>Verbos:</label>
              <div className="checkbox-grid">
                {verbos.map(verbo => (
                  <div key={verbo.id} className="checkbox-item">
                    <input
                      type="checkbox"
                      id={`verbo-${verbo.id}`}
                      checked={formData.verbo_ids.includes(verbo.id)}
                      onChange={() => toggleVerbo(verbo.id)}
                    />
                    <label htmlFor={`verbo-${verbo.id}`}>{verbo.infinitivo}</label>
                  </div>
                ))}
              </div>
            </div>

            <div className="form-group">
              <label>Modos y Tiempos:</label>
              {Object.entries(MODOS_TIEMPOS).map(([modo, tiempos]) => (
                <div key={modo} style={{ marginBottom: '15px' }}>
                  <strong style={{ textTransform: 'capitalize' }}>{modo}</strong>
                  <div className="checkbox-grid" style={{ marginTop: '5px' }}>
                    {[...tiempos.simples, ...tiempos.compuestos].map(tiempo => (
                      <div key={`${modo}-${tiempo}`} className="checkbox-item">
                        <input
                          type="checkbox"
                          id={`tiempo-${modo}-${tiempo}`}
                          checked={formData.tiempos.some(t => t.modo === modo && t.tiempo === tiempo)}
                          onChange={() => toggleTiempo(modo, tiempo)}
                        />
                        <label htmlFor={`tiempo-${modo}-${tiempo}`}>{TIEMPO_LABELS[tiempo]}</label>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>

            <div style={{ display: 'flex', gap: '10px' }}>
              <button className="btn btn-primary" onClick={handleSave} disabled={saving}>
                {saving ? 'Guardando...' : 'Guardar'}
              </button>
              <button className="btn btn-secondary" onClick={() => setShowModal(false)}>
                Cancelar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// Componente para Progreso
function ProgresoTab({ progreso }) {
  return (
    <div>
      <h3>Progreso de Alumnos ({progreso.length})</h3>

      {progreso.length === 0 ? (
        <p style={{ color: '#666', textAlign: 'center', padding: '40px' }}>
          No hay alumnos registrados todavía.
        </p>
      ) : (
        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>Nombre</th>
                <th>Grupo</th>
                <th>Progreso</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              {progreso.map(p => (
                <tr key={p.alumno_id}>
                  <td>{p.nombre_completo}</td>
                  <td>{p.grupo_nombre}</td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <div className="progress-bar" style={{ width: '150px', height: '15px' }}>
                        <div 
                          className="progress-fill" 
                          style={{ width: `${p.porcentaje}%` }}
                        ></div>
                      </div>
                      <span>{p.porcentaje}%</span>
                      <span style={{ color: '#666', fontSize: '0.9rem' }}>
                        ({p.formularios_completados}/{p.total_formularios})
                      </span>
                    </div>
                  </td>
                  <td>
                    {p.completado ? (
                      <span style={{ color: '#11998e' }}>✅ Completado</span>
                    ) : (
                      <span style={{ color: '#f5a623' }}>⏳ En progreso</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export default AdminPanel;
