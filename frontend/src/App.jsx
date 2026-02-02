import { Routes, Route } from 'react-router-dom'
import Home from './pages/Home'
import NewStudent from './pages/NewStudent'
import ResumeStudent from './pages/ResumeStudent'
import Task from './pages/Task'
import Punishment from './pages/Punishment'
import Completed from './pages/Completed'
import AdminLogin from './pages/AdminLogin'
import AdminPanel from './pages/AdminPanel'

function App() {
  return (
    <div className="app">
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/nueva" element={<NewStudent />} />
        <Route path="/retomar" element={<ResumeStudent />} />
        <Route path="/tarea/:alumnoId" element={<Task />} />
        <Route path="/castigo/:alumnoId" element={<Punishment />} />
        <Route path="/completado/:alumnoId" element={<Completed />} />
        <Route path="/admin" element={<AdminLogin />} />
        <Route path="/admin/panel" element={<AdminPanel />} />
      </Routes>
    </div>
  )
}

export default App
