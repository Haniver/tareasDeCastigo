-- Script de inicialización de la base de datos "tareasDeCastigo"
-- Ejecutar con: psql -U lucio -d tareasDeCastigo -f init_db.sql

-- Tabla de configuración (contraseña admin, fecha último reset)
CREATE TABLE IF NOT EXISTS config (
    clave VARCHAR(50) PRIMARY KEY,
    valor TEXT NOT NULL
);

-- Insertar contraseña por defecto de la maestra
INSERT INTO config (clave, valor) VALUES ('password_admin', 'maestra123') ON CONFLICT DO NOTHING;
INSERT INTO config (clave, valor) VALUES ('ultimo_reset_anual', '2025-07-29') ON CONFLICT DO NOTHING;

-- Tabla de verbos
CREATE TABLE IF NOT EXISTS verbos (
    id SERIAL PRIMARY KEY,
    infinitivo VARCHAR(50) NOT NULL UNIQUE
);

-- Tabla de conjugaciones
CREATE TABLE IF NOT EXISTS conjugaciones (
    id SERIAL PRIMARY KEY,
    verbo_id INTEGER NOT NULL REFERENCES verbos(id) ON DELETE CASCADE,
    modo VARCHAR(20) NOT NULL CHECK (modo IN ('indicativo', 'subjuntivo', 'imperativo')),
    tiempo VARCHAR(20) NOT NULL CHECK (tiempo IN (
        'presente', 'preterito', 'futuro', 'copreterito', 'pospreterito',
        'antepresente', 'antepreterito', 'antefuturo', 'antecopreterito', 'antepospreterito'
    )),
    persona VARCHAR(20) NOT NULL CHECK (persona IN ('yo', 'tu', 'el', 'nosotros', 'vosotros', 'ellos')),
    forma VARCHAR(100) NOT NULL,
    forma_alternativa VARCHAR(100),
    UNIQUE(verbo_id, modo, tiempo, persona)
);

-- Tabla de grupos
CREATE TABLE IF NOT EXISTS grupos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla de tareas
CREATE TABLE IF NOT EXISTS tareas (
    id SERIAL PRIMARY KEY,
    grupo_id INTEGER NOT NULL REFERENCES grupos(id) ON DELETE CASCADE,
    fecha_limite DATE NOT NULL
);

-- Tabla de relación tarea-verbos (qué verbos incluye cada tarea)
CREATE TABLE IF NOT EXISTS tarea_verbos (
    id SERIAL PRIMARY KEY,
    tarea_id INTEGER NOT NULL REFERENCES tareas(id) ON DELETE CASCADE,
    verbo_id INTEGER NOT NULL REFERENCES verbos(id) ON DELETE CASCADE,
    UNIQUE(tarea_id, verbo_id)
);

-- Tabla de relación tarea-tiempos (qué modos/tiempos incluye cada tarea)
CREATE TABLE IF NOT EXISTS tarea_tiempos (
    id SERIAL PRIMARY KEY,
    tarea_id INTEGER NOT NULL REFERENCES tareas(id) ON DELETE CASCADE,
    modo VARCHAR(20) NOT NULL,
    tiempo VARCHAR(20) NOT NULL,
    UNIQUE(tarea_id, modo, tiempo)
);

-- Tabla de alumnos
CREATE TABLE IF NOT EXISTS alumnos (
    id SERIAL PRIMARY KEY,
    grupo_id INTEGER NOT NULL REFERENCES grupos(id) ON DELETE CASCADE,
    nombre_completo VARCHAR(200) NOT NULL,
    completado BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(grupo_id, nombre_completo)
);

-- Tabla de progreso del alumno (qué formularios ha completado)
CREATE TABLE IF NOT EXISTS progreso_alumno (
    id SERIAL PRIMARY KEY,
    alumno_id INTEGER NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
    tarea_id INTEGER NOT NULL REFERENCES tareas(id) ON DELETE CASCADE,
    verbo_id INTEGER NOT NULL REFERENCES verbos(id) ON DELETE CASCADE,
    modo VARCHAR(20) NOT NULL,
    tiempo VARCHAR(20) NOT NULL,
    completado BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(alumno_id, tarea_id, verbo_id, modo, tiempo)
);

-- Índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_conjugaciones_verbo ON conjugaciones(verbo_id);
CREATE INDEX IF NOT EXISTS idx_conjugaciones_modo_tiempo ON conjugaciones(modo, tiempo);
CREATE INDEX IF NOT EXISTS idx_tarea_verbos_tarea ON tarea_verbos(tarea_id);
CREATE INDEX IF NOT EXISTS idx_tarea_tiempos_tarea ON tarea_tiempos(tarea_id);
CREATE INDEX IF NOT EXISTS idx_alumnos_grupo ON alumnos(grupo_id);
CREATE INDEX IF NOT EXISTS idx_progreso_alumno ON progreso_alumno(alumno_id);
CREATE INDEX IF NOT EXISTS idx_tareas_grupo ON tareas(grupo_id);
CREATE INDEX IF NOT EXISTS idx_tareas_fecha ON tareas(fecha_limite);

-- Insertar verbo de ejemplo: "cantar"
INSERT INTO verbos (infinitivo) VALUES ('cantar') ON CONFLICT DO NOTHING;

-- Conjugaciones de "cantar" (verbo regular de primera conjugación)
-- INDICATIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'presente', 'yo', 'canto'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'presente', 'tu', 'cantas'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'presente', 'el', 'canta'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'presente', 'nosotros', 'cantamos'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'presente', 'vosotros', 'cantáis'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'presente', 'ellos', 'cantan')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pretérito
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'preterito', 'yo', 'canté'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'preterito', 'tu', 'cantaste'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'preterito', 'el', 'cantó'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'preterito', 'nosotros', 'cantamos'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'preterito', 'vosotros', 'cantasteis'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'preterito', 'ellos', 'cantaron')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'futuro', 'yo', 'cantaré'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'futuro', 'tu', 'cantarás'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'futuro', 'el', 'cantará'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'futuro', 'nosotros', 'cantaremos'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'futuro', 'vosotros', 'cantaréis'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'futuro', 'ellos', 'cantarán')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Copretérito (Pretérito Imperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'copreterito', 'yo', 'cantaba'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'copreterito', 'tu', 'cantabas'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'copreterito', 'el', 'cantaba'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'copreterito', 'nosotros', 'cantábamos'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'copreterito', 'vosotros', 'cantabais'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'copreterito', 'ellos', 'cantaban')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pospretérito (Condicional)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'pospreterito', 'yo', 'cantaría'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'pospreterito', 'tu', 'cantarías'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'pospreterito', 'el', 'cantaría'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'pospreterito', 'nosotros', 'cantaríamos'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'pospreterito', 'vosotros', 'cantaríais'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'pospreterito', 'ellos', 'cantarían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepresente (Pretérito Perfecto Compuesto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepresente', 'yo', 'he cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepresente', 'tu', 'has cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepresente', 'el', 'ha cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepresente', 'nosotros', 'hemos cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepresente', 'vosotros', 'habéis cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepresente', 'ellos', 'han cantado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepretérito (Pretérito Anterior)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepreterito', 'yo', 'hube cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepreterito', 'tu', 'hubiste cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepreterito', 'el', 'hubo cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepreterito', 'nosotros', 'hubimos cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepreterito', 'vosotros', 'hubisteis cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepreterito', 'ellos', 'hubieron cantado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antefuturo', 'yo', 'habré cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antefuturo', 'tu', 'habrás cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antefuturo', 'el', 'habrá cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antefuturo', 'nosotros', 'habremos cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antefuturo', 'vosotros', 'habréis cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antefuturo', 'ellos', 'habrán cantado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antecopretérito (Pretérito Pluscuamperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antecopreterito', 'yo', 'había cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antecopreterito', 'tu', 'habías cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antecopreterito', 'el', 'había cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antecopreterito', 'nosotros', 'habíamos cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antecopreterito', 'vosotros', 'habíais cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antecopreterito', 'ellos', 'habían cantado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepospretérito (Condicional Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepospreterito', 'yo', 'habría cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepospreterito', 'tu', 'habrías cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepospreterito', 'el', 'habría cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepospreterito', 'nosotros', 'habríamos cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepospreterito', 'vosotros', 'habríais cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'indicativo', 'antepospreterito', 'ellos', 'habrían cantado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'presente', 'yo', 'cante'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'presente', 'tu', 'cantes'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'presente', 'el', 'cante'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'presente', 'nosotros', 'cantemos'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'presente', 'vosotros', 'cantéis'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'presente', 'ellos', 'canten')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Pretérito (con formas alternativas -ra/-se)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'preterito', 'yo', 'cantara', 'cantase'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'preterito', 'tu', 'cantaras', 'cantases'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'preterito', 'el', 'cantara', 'cantase'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'preterito', 'nosotros', 'cantáramos', 'cantásemos'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'preterito', 'vosotros', 'cantarais', 'cantaseis'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'preterito', 'ellos', 'cantaran', 'cantasen')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'futuro', 'yo', 'cantare'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'futuro', 'tu', 'cantares'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'futuro', 'el', 'cantare'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'futuro', 'nosotros', 'cantáremos'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'futuro', 'vosotros', 'cantareis'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'futuro', 'ellos', 'cantaren')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepresente (Pretérito Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antepresente', 'yo', 'haya cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antepresente', 'tu', 'hayas cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antepresente', 'el', 'haya cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antepresente', 'nosotros', 'hayamos cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antepresente', 'vosotros', 'hayáis cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antepresente', 'ellos', 'hayan cantado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepretérito (Pretérito Pluscuamperfecto) con formas alternativas
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antepreterito', 'yo', 'hubiera cantado', 'hubiese cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antepreterito', 'tu', 'hubieras cantado', 'hubieses cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antepreterito', 'el', 'hubiera cantado', 'hubiese cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antepreterito', 'nosotros', 'hubiéramos cantado', 'hubiésemos cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antepreterito', 'vosotros', 'hubierais cantado', 'hubieseis cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antepreterito', 'ellos', 'hubieran cantado', 'hubiesen cantado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antefuturo', 'yo', 'hubiere cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antefuturo', 'tu', 'hubieres cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antefuturo', 'el', 'hubiere cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antefuturo', 'nosotros', 'hubiéremos cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antefuturo', 'vosotros', 'hubiereis cantado'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'subjuntivo', 'antefuturo', 'ellos', 'hubieren cantado')
ON CONFLICT DO NOTHING;

-- IMPERATIVO - Presente (solo tú, nosotros, vosotros)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'imperativo', 'presente', 'tu', 'canta'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'imperativo', 'presente', 'nosotros', 'cantemos'),
((SELECT id FROM verbos WHERE infinitivo = 'cantar'), 'imperativo', 'presente', 'vosotros', 'cantad')
ON CONFLICT DO NOTHING;
