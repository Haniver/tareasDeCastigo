import axios from 'axios';

const api = axios.create({
  baseURL: '/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Grupos
export const getGruposActivos = () => api.get('/grupos/');
export const getTodosGrupos = () => api.get('/grupos/todos');
export const getGrupo = (id) => api.get(`/grupos/${id}`);
export const getAlumnosGrupo = (grupoId) => api.get(`/grupos/${grupoId}/alumnos`);
export const crearGrupo = (data) => api.post('/grupos/', data);
export const actualizarGrupo = (id, data) => api.put(`/grupos/${id}`, data);
export const eliminarGrupo = (id) => api.delete(`/grupos/${id}`);

// Verbos
export const getVerbos = () => api.get('/verbos/');
export const getVerbo = (id) => api.get(`/verbos/${id}`);
export const crearVerbo = (data) => api.post('/verbos/', data);
export const actualizarVerbo = (id, data) => api.put(`/verbos/${id}`, data);
export const eliminarVerbo = (id) => api.delete(`/verbos/${id}`);

// Tareas
export const getTareas = () => api.get('/tareas/');
export const getTarea = (id) => api.get(`/tareas/${id}`);
export const crearTarea = (data) => api.post('/tareas/', data);
export const actualizarTarea = (id, data) => api.put(`/tareas/${id}`, data);
export const eliminarTarea = (id) => api.delete(`/tareas/${id}`);

// Alumnos
export const crearAlumno = (data) => api.post('/alumnos/', data);
export const getAlumno = (id) => api.get(`/alumnos/${id}`);
export const getFormulario = (alumnoId) => api.get(`/alumnos/${alumnoId}/formulario`);
export const enviarRespuesta = (alumnoId, data) => api.post(`/alumnos/${alumnoId}/respuesta`, data);
export const getProgresoAlumno = (alumnoId) => api.get(`/alumnos/${alumnoId}/progreso`);

// Admin
export const adminLogin = (password) => api.post('/admin/login', { password });
export const getProgresoTodos = () => api.get('/admin/progreso');

export default api;
