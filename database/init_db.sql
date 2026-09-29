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

-- Tabla de castigos pendientes (errores que el alumno debe corregir)
CREATE TABLE IF NOT EXISTS castigos_pendientes (
    id SERIAL PRIMARY KEY,
    alumno_id INTEGER NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
    tarea_id INTEGER NOT NULL REFERENCES tareas(id) ON DELETE CASCADE,
    verbo_id INTEGER NOT NULL REFERENCES verbos(id) ON DELETE CASCADE,
    modo VARCHAR(20) NOT NULL,
    tiempo VARCHAR(20) NOT NULL,
    persona VARCHAR(20) NOT NULL,
    respuesta_incorrecta VARCHAR(100) NOT NULL,
    respuesta_correcta VARCHAR(100) NOT NULL,
    completado BOOLEAN NOT NULL DEFAULT FALSE
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
CREATE INDEX IF NOT EXISTS idx_castigos_alumno ON castigos_pendientes(alumno_id);

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


-- Insertar verbo: "ser"
INSERT INTO verbos (infinitivo) VALUES ('ser') ON CONFLICT DO NOTHING;

-- INDICATIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'presente', 'yo', 'soy'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'presente', 'tu', 'eres'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'presente', 'el', 'es'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'presente', 'nosotros', 'somos'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'presente', 'vosotros', 'sois'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'presente', 'ellos', 'son')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pretérito
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'preterito', 'yo', 'fui'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'preterito', 'tu', 'fuiste'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'preterito', 'el', 'fue'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'preterito', 'nosotros', 'fuimos'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'preterito', 'vosotros', 'fuisteis'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'preterito', 'ellos', 'fueron')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'futuro', 'yo', 'seré'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'futuro', 'tu', 'serás'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'futuro', 'el', 'será'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'futuro', 'nosotros', 'seremos'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'futuro', 'vosotros', 'seréis'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'futuro', 'ellos', 'serán')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Copretérito (Pretérito Imperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'copreterito', 'yo', 'era'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'copreterito', 'tu', 'eras'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'copreterito', 'el', 'era'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'copreterito', 'nosotros', 'éramos'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'copreterito', 'vosotros', 'erais'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'copreterito', 'ellos', 'eran')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pospretérito (Condicional)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'pospreterito', 'yo', 'sería'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'pospreterito', 'tu', 'serías'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'pospreterito', 'el', 'sería'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'pospreterito', 'nosotros', 'seríamos'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'pospreterito', 'vosotros', 'seríais'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'pospreterito', 'ellos', 'serían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepresente (Pretérito Perfecto Compuesto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepresente', 'yo', 'he sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepresente', 'tu', 'has sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepresente', 'el', 'ha sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepresente', 'nosotros', 'hemos sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepresente', 'vosotros', 'habéis sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepresente', 'ellos', 'han sido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepretérito (Pretérito Anterior)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepreterito', 'yo', 'hube sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepreterito', 'tu', 'hubiste sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepreterito', 'el', 'hubo sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepreterito', 'nosotros', 'hubimos sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepreterito', 'vosotros', 'hubisteis sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepreterito', 'ellos', 'hubieron sido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antefuturo', 'yo', 'habré sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antefuturo', 'tu', 'habrás sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antefuturo', 'el', 'habrá sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antefuturo', 'nosotros', 'habremos sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antefuturo', 'vosotros', 'habréis sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antefuturo', 'ellos', 'habrán sido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antecopretérito (Pretérito Pluscuamperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antecopreterito', 'yo', 'había sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antecopreterito', 'tu', 'habías sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antecopreterito', 'el', 'había sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antecopreterito', 'nosotros', 'habíamos sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antecopreterito', 'vosotros', 'habíais sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antecopreterito', 'ellos', 'habían sido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepospretérito (Condicional Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepospreterito', 'yo', 'habría sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepospreterito', 'tu', 'habrías sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepospreterito', 'el', 'habría sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepospreterito', 'nosotros', 'habríamos sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepospreterito', 'vosotros', 'habríais sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'indicativo', 'antepospreterito', 'ellos', 'habrían sido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'presente', 'yo', 'sea'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'presente', 'tu', 'seas'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'presente', 'el', 'sea'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'presente', 'nosotros', 'seamos'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'presente', 'vosotros', 'seáis'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'presente', 'ellos', 'sean')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Pretérito (con formas alternativas -ra/-se)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'preterito', 'yo', 'fuera', 'fuese'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'preterito', 'tu', 'fueras', 'fueses'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'preterito', 'el', 'fuera', 'fuese'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'preterito', 'nosotros', 'fuéramos', 'fuésemos'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'preterito', 'vosotros', 'fuerais', 'fueseis'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'preterito', 'ellos', 'fueran', 'fuesen')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'futuro', 'yo', 'fuere'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'futuro', 'tu', 'fueres'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'futuro', 'el', 'fuere'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'futuro', 'nosotros', 'fuéremos'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'futuro', 'vosotros', 'fuereis'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'futuro', 'ellos', 'fueren')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepresente (Pretérito Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antepresente', 'yo', 'haya sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antepresente', 'tu', 'hayas sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antepresente', 'el', 'haya sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antepresente', 'nosotros', 'hayamos sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antepresente', 'vosotros', 'hayáis sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antepresente', 'ellos', 'hayan sido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepretérito (Pretérito Pluscuamperfecto) con formas alternativas
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antepreterito', 'yo', 'hubiera sido', 'hubiese sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antepreterito', 'tu', 'hubieras sido', 'hubieses sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antepreterito', 'el', 'hubiera sido', 'hubiese sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antepreterito', 'nosotros', 'hubiéramos sido', 'hubiésemos sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antepreterito', 'vosotros', 'hubierais sido', 'hubieseis sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antepreterito', 'ellos', 'hubieran sido', 'hubiesen sido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antefuturo', 'yo', 'hubiere sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antefuturo', 'tu', 'hubieres sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antefuturo', 'el', 'hubiere sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antefuturo', 'nosotros', 'hubiéremos sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antefuturo', 'vosotros', 'hubiereis sido'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'subjuntivo', 'antefuturo', 'ellos', 'hubieren sido')
ON CONFLICT DO NOTHING;

-- IMPERATIVO - Presente (solo tú, nosotros, vosotros)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'imperativo', 'presente', 'tu', 'sé'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'imperativo', 'presente', 'nosotros', 'seamos'),
((SELECT id FROM verbos WHERE infinitivo = 'ser'), 'imperativo', 'presente', 'vosotros', 'sed')
ON CONFLICT DO NOTHING;

-- Insertar verbo: "hacer"
INSERT INTO verbos (infinitivo) VALUES ('hacer') ON CONFLICT DO NOTHING;

-- INDICATIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'presente', 'yo', 'hago'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'presente', 'tu', 'haces'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'presente', 'el', 'hace'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'presente', 'nosotros', 'hacemos'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'presente', 'vosotros', 'hacéis'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'presente', 'ellos', 'hacen')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pretérito
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'preterito', 'yo', 'hice'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'preterito', 'tu', 'hiciste'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'preterito', 'el', 'hizo'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'preterito', 'nosotros', 'hicimos'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'preterito', 'vosotros', 'hicisteis'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'preterito', 'ellos', 'hicieron')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'futuro', 'yo', 'haré'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'futuro', 'tu', 'harás'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'futuro', 'el', 'hará'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'futuro', 'nosotros', 'haremos'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'futuro', 'vosotros', 'haréis'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'futuro', 'ellos', 'harán')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Copretérito (Pretérito Imperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'copreterito', 'yo', 'hacía'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'copreterito', 'tu', 'hacías'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'copreterito', 'el', 'hacía'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'copreterito', 'nosotros', 'hacíamos'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'copreterito', 'vosotros', 'hacíais'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'copreterito', 'ellos', 'hacían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pospretérito (Condicional)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'pospreterito', 'yo', 'haría'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'pospreterito', 'tu', 'harías'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'pospreterito', 'el', 'haría'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'pospreterito', 'nosotros', 'haríamos'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'pospreterito', 'vosotros', 'haríais'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'pospreterito', 'ellos', 'harían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepresente (Pretérito Perfecto Compuesto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepresente', 'yo', 'he hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepresente', 'tu', 'has hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepresente', 'el', 'ha hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepresente', 'nosotros', 'hemos hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepresente', 'vosotros', 'habéis hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepresente', 'ellos', 'han hecho')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepretérito (Pretérito Anterior)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepreterito', 'yo', 'hube hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepreterito', 'tu', 'hubiste hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepreterito', 'el', 'hubo hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepreterito', 'nosotros', 'hubimos hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepreterito', 'vosotros', 'hubisteis hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepreterito', 'ellos', 'hubieron hecho')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antefuturo', 'yo', 'habré hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antefuturo', 'tu', 'habrás hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antefuturo', 'el', 'habrá hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antefuturo', 'nosotros', 'habremos hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antefuturo', 'vosotros', 'habréis hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antefuturo', 'ellos', 'habrán hecho')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antecopretérito (Pretérito Pluscuamperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antecopreterito', 'yo', 'había hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antecopreterito', 'tu', 'habías hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antecopreterito', 'el', 'había hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antecopreterito', 'nosotros', 'habíamos hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antecopreterito', 'vosotros', 'habíais hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antecopreterito', 'ellos', 'habían hecho')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepospretérito (Condicional Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepospreterito', 'yo', 'habría hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepospreterito', 'tu', 'habrías hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepospreterito', 'el', 'habría hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepospreterito', 'nosotros', 'habríamos hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepospreterito', 'vosotros', 'habríais hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'indicativo', 'antepospreterito', 'ellos', 'habrían hecho')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'presente', 'yo', 'haga'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'presente', 'tu', 'hagas'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'presente', 'el', 'haga'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'presente', 'nosotros', 'hagamos'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'presente', 'vosotros', 'hagáis'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'presente', 'ellos', 'hagan')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Pretérito (con formas alternativas -ra/-se)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'preterito', 'yo', 'hiciera', 'hiciese'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'preterito', 'tu', 'hicieras', 'hicieses'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'preterito', 'el', 'hiciera', 'hiciese'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'preterito', 'nosotros', 'hiciéramos', 'hiciésemos'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'preterito', 'vosotros', 'hicierais', 'hicieseis'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'preterito', 'ellos', 'hicieran', 'hiciesen')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'futuro', 'yo', 'hiciere'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'futuro', 'tu', 'hicieres'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'futuro', 'el', 'hiciere'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'futuro', 'nosotros', 'hiciéremos'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'futuro', 'vosotros', 'hiciereis'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'futuro', 'ellos', 'hicieren')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepresente (Pretérito Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antepresente', 'yo', 'haya hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antepresente', 'tu', 'hayas hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antepresente', 'el', 'haya hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antepresente', 'nosotros', 'hayamos hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antepresente', 'vosotros', 'hayáis hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antepresente', 'ellos', 'hayan hecho')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepretérito (Pretérito Pluscuamperfecto) con formas alternativas
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antepreterito', 'yo', 'hubiera hecho', 'hubiese hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antepreterito', 'tu', 'hubieras hecho', 'hubieses hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antepreterito', 'el', 'hubiera hecho', 'hubiese hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antepreterito', 'nosotros', 'hubiéramos hecho', 'hubiésemos hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antepreterito', 'vosotros', 'hubierais hecho', 'hubieseis hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antepreterito', 'ellos', 'hubieran hecho', 'hubiesen hecho')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antefuturo', 'yo', 'hubiere hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antefuturo', 'tu', 'hubieres hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antefuturo', 'el', 'hubiere hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antefuturo', 'nosotros', 'hubiéremos hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antefuturo', 'vosotros', 'hubiereis hecho'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'subjuntivo', 'antefuturo', 'ellos', 'hubieren hecho')
ON CONFLICT DO NOTHING;

-- IMPERATIVO - Presente (solo tú, nosotros, vosotros)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'imperativo', 'presente', 'tu', 'haz'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'imperativo', 'presente', 'nosotros', 'hagamos'),
((SELECT id FROM verbos WHERE infinitivo = 'hacer'), 'imperativo', 'presente', 'vosotros', 'haced')
ON CONFLICT DO NOTHING;

-- Insertar verbo: "haber"
INSERT INTO verbos (infinitivo) VALUES ('haber') ON CONFLICT DO NOTHING;

-- INDICATIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'presente', 'yo', 'he', NULL),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'presente', 'tu', 'has', NULL),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'presente', 'el', 'ha', 'hay'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'presente', 'nosotros', 'hemos', NULL),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'presente', 'vosotros', 'habéis', NULL),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'presente', 'ellos', 'han', NULL)
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pretérito
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'preterito', 'yo', 'hube'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'preterito', 'tu', 'hubiste'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'preterito', 'el', 'hubo'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'preterito', 'nosotros', 'hubimos'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'preterito', 'vosotros', 'hubisteis'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'preterito', 'ellos', 'hubieron')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'futuro', 'yo', 'habré'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'futuro', 'tu', 'habrás'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'futuro', 'el', 'habrá'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'futuro', 'nosotros', 'habremos'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'futuro', 'vosotros', 'habréis'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'futuro', 'ellos', 'habrán')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Copretérito (Pretérito Imperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'copreterito', 'yo', 'había'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'copreterito', 'tu', 'habías'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'copreterito', 'el', 'había'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'copreterito', 'nosotros', 'habíamos'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'copreterito', 'vosotros', 'habíais'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'copreterito', 'ellos', 'habían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pospretérito (Condicional)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'pospreterito', 'yo', 'habría'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'pospreterito', 'tu', 'habrías'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'pospreterito', 'el', 'habría'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'pospreterito', 'nosotros', 'habríamos'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'pospreterito', 'vosotros', 'habríais'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'pospreterito', 'ellos', 'habrían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepresente (Pretérito Perfecto Compuesto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepresente', 'yo', 'he habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepresente', 'tu', 'has habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepresente', 'el', 'ha habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepresente', 'nosotros', 'hemos habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepresente', 'vosotros', 'habéis habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepresente', 'ellos', 'han habido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepretérito (Pretérito Anterior)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepreterito', 'yo', 'hube habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepreterito', 'tu', 'hubiste habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepreterito', 'el', 'hubo habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepreterito', 'nosotros', 'hubimos habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepreterito', 'vosotros', 'hubisteis habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepreterito', 'ellos', 'hubieron habido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antefuturo', 'yo', 'habré habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antefuturo', 'tu', 'habrás habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antefuturo', 'el', 'habrá habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antefuturo', 'nosotros', 'habremos habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antefuturo', 'vosotros', 'habréis habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antefuturo', 'ellos', 'habrán habido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antecopretérito (Pretérito Pluscuamperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antecopreterito', 'yo', 'había habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antecopreterito', 'tu', 'habías habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antecopreterito', 'el', 'había habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antecopreterito', 'nosotros', 'habíamos habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antecopreterito', 'vosotros', 'habíais habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antecopreterito', 'ellos', 'habían habido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepospretérito (Condicional Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepospreterito', 'yo', 'habría habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepospreterito', 'tu', 'habrías habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepospreterito', 'el', 'habría habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepospreterito', 'nosotros', 'habríamos habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepospreterito', 'vosotros', 'habríais habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'indicativo', 'antepospreterito', 'ellos', 'habrían habido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'presente', 'yo', 'haya'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'presente', 'tu', 'hayas'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'presente', 'el', 'haya'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'presente', 'nosotros', 'hayamos'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'presente', 'vosotros', 'hayáis'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'presente', 'ellos', 'hayan')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Pretérito (con formas alternativas -ra/-se)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'preterito', 'yo', 'hubiera', 'hubiese'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'preterito', 'tu', 'hubieras', 'hubieses'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'preterito', 'el', 'hubiera', 'hubiese'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'preterito', 'nosotros', 'hubiéramos', 'hubiésemos'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'preterito', 'vosotros', 'hubierais', 'hubieseis'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'preterito', 'ellos', 'hubieran', 'hubiesen')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'futuro', 'yo', 'hubiere'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'futuro', 'tu', 'hubieres'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'futuro', 'el', 'hubiere'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'futuro', 'nosotros', 'hubiéremos'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'futuro', 'vosotros', 'hubiereis'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'futuro', 'ellos', 'hubieren')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepresente (Pretérito Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antepresente', 'yo', 'haya habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antepresente', 'tu', 'hayas habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antepresente', 'el', 'haya habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antepresente', 'nosotros', 'hayamos habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antepresente', 'vosotros', 'hayáis habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antepresente', 'ellos', 'hayan habido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepretérito (Pretérito Pluscuamperfecto) con formas alternativas
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antepreterito', 'yo', 'hubiera habido', 'hubiese habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antepreterito', 'tu', 'hubieras habido', 'hubieses habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antepreterito', 'el', 'hubiera habido', 'hubiese habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antepreterito', 'nosotros', 'hubiéramos habido', 'hubiésemos habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antepreterito', 'vosotros', 'hubierais habido', 'hubieseis habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antepreterito', 'ellos', 'hubieran habido', 'hubiesen habido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antefuturo', 'yo', 'hubiere habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antefuturo', 'tu', 'hubieres habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antefuturo', 'el', 'hubiere habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antefuturo', 'nosotros', 'hubiéremos habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antefuturo', 'vosotros', 'hubiereis habido'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'subjuntivo', 'antefuturo', 'ellos', 'hubieren habido')
ON CONFLICT DO NOTHING;

-- IMPERATIVO - Presente (solo tú, nosotros, vosotros)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'imperativo', 'presente', 'tu', 'he'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'imperativo', 'presente', 'nosotros', 'hayamos'),
((SELECT id FROM verbos WHERE infinitivo = 'haber'), 'imperativo', 'presente', 'vosotros', 'habed')
ON CONFLICT DO NOTHING;

-- Insertar verbo: "echar"
INSERT INTO verbos (infinitivo) VALUES ('echar') ON CONFLICT DO NOTHING;

-- INDICATIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'presente', 'yo', 'echo'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'presente', 'tu', 'echas'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'presente', 'el', 'echa'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'presente', 'nosotros', 'echamos'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'presente', 'vosotros', 'echáis'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'presente', 'ellos', 'echan')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pretérito
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'preterito', 'yo', 'eché'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'preterito', 'tu', 'echaste'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'preterito', 'el', 'echó'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'preterito', 'nosotros', 'echamos'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'preterito', 'vosotros', 'echasteis'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'preterito', 'ellos', 'echaron')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'futuro', 'yo', 'echaré'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'futuro', 'tu', 'echarás'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'futuro', 'el', 'echará'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'futuro', 'nosotros', 'echaremos'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'futuro', 'vosotros', 'echaréis'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'futuro', 'ellos', 'echarán')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Copretérito (Pretérito Imperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'copreterito', 'yo', 'echaba'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'copreterito', 'tu', 'echabas'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'copreterito', 'el', 'echaba'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'copreterito', 'nosotros', 'echábamos'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'copreterito', 'vosotros', 'echabais'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'copreterito', 'ellos', 'echaban')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pospretérito (Condicional)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'pospreterito', 'yo', 'echaría'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'pospreterito', 'tu', 'echarías'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'pospreterito', 'el', 'echaría'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'pospreterito', 'nosotros', 'echaríamos'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'pospreterito', 'vosotros', 'echaríais'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'pospreterito', 'ellos', 'echarían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepresente (Pretérito Perfecto Compuesto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepresente', 'yo', 'he echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepresente', 'tu', 'has echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepresente', 'el', 'ha echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepresente', 'nosotros', 'hemos echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepresente', 'vosotros', 'habéis echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepresente', 'ellos', 'han echado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepretérito (Pretérito Anterior)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepreterito', 'yo', 'hube echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepreterito', 'tu', 'hubiste echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepreterito', 'el', 'hubo echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepreterito', 'nosotros', 'hubimos echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepreterito', 'vosotros', 'hubisteis echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepreterito', 'ellos', 'hubieron echado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antefuturo', 'yo', 'habré echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antefuturo', 'tu', 'habrás echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antefuturo', 'el', 'habrá echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antefuturo', 'nosotros', 'habremos echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antefuturo', 'vosotros', 'habréis echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antefuturo', 'ellos', 'habrán echado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antecopretérito (Pretérito Pluscuamperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antecopreterito', 'yo', 'había echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antecopreterito', 'tu', 'habías echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antecopreterito', 'el', 'había echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antecopreterito', 'nosotros', 'habíamos echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antecopreterito', 'vosotros', 'habíais echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antecopreterito', 'ellos', 'habían echado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepospretérito (Condicional Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepospreterito', 'yo', 'habría echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepospreterito', 'tu', 'habrías echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepospreterito', 'el', 'habría echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepospreterito', 'nosotros', 'habríamos echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepospreterito', 'vosotros', 'habríais echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'indicativo', 'antepospreterito', 'ellos', 'habrían echado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'presente', 'yo', 'eche'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'presente', 'tu', 'eches'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'presente', 'el', 'eche'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'presente', 'nosotros', 'echemos'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'presente', 'vosotros', 'echéis'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'presente', 'ellos', 'echen')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Pretérito (con formas alternativas -ra/-se)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'preterito', 'yo', 'echara', 'echase'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'preterito', 'tu', 'echaras', 'echases'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'preterito', 'el', 'echara', 'echase'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'preterito', 'nosotros', 'echáramos', 'echásemos'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'preterito', 'vosotros', 'echarais', 'echaseis'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'preterito', 'ellos', 'echaran', 'echasen')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'futuro', 'yo', 'echare'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'futuro', 'tu', 'echares'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'futuro', 'el', 'echare'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'futuro', 'nosotros', 'echáremos'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'futuro', 'vosotros', 'echareis'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'futuro', 'ellos', 'echaren')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepresente (Pretérito Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antepresente', 'yo', 'haya echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antepresente', 'tu', 'hayas echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antepresente', 'el', 'haya echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antepresente', 'nosotros', 'hayamos echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antepresente', 'vosotros', 'hayáis echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antepresente', 'ellos', 'hayan echado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepretérito (Pretérito Pluscuamperfecto) con formas alternativas
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antepreterito', 'yo', 'hubiera echado', 'hubiese echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antepreterito', 'tu', 'hubieras echado', 'hubieses echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antepreterito', 'el', 'hubiera echado', 'hubiese echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antepreterito', 'nosotros', 'hubiéramos echado', 'hubiésemos echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antepreterito', 'vosotros', 'hubierais echado', 'hubieseis echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antepreterito', 'ellos', 'hubieran echado', 'hubiesen echado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antefuturo', 'yo', 'hubiere echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antefuturo', 'tu', 'hubieres echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antefuturo', 'el', 'hubiere echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antefuturo', 'nosotros', 'hubiéremos echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antefuturo', 'vosotros', 'hubiereis echado'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'subjuntivo', 'antefuturo', 'ellos', 'hubieren echado')
ON CONFLICT DO NOTHING;

-- IMPERATIVO - Presente (solo tú, nosotros, vosotros)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'imperativo', 'presente', 'tu', 'echa'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'imperativo', 'presente', 'nosotros', 'echemos'),
((SELECT id FROM verbos WHERE infinitivo = 'echar'), 'imperativo', 'presente', 'vosotros', 'echad')
ON CONFLICT DO NOTHING;

-- Insertar verbo: "estar"
INSERT INTO verbos (infinitivo) VALUES ('estar') ON CONFLICT DO NOTHING;

-- INDICATIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'presente', 'yo', 'estoy'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'presente', 'tu', 'estás'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'presente', 'el', 'está'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'presente', 'nosotros', 'estamos'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'presente', 'vosotros', 'estáis'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'presente', 'ellos', 'están')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pretérito
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'preterito', 'yo', 'estuve'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'preterito', 'tu', 'estuviste'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'preterito', 'el', 'estuvo'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'preterito', 'nosotros', 'estuvimos'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'preterito', 'vosotros', 'estuvisteis'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'preterito', 'ellos', 'estuvieron')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'futuro', 'yo', 'estaré'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'futuro', 'tu', 'estarás'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'futuro', 'el', 'estará'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'futuro', 'nosotros', 'estaremos'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'futuro', 'vosotros', 'estaréis'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'futuro', 'ellos', 'estarán')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Copretérito (Pretérito Imperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'copreterito', 'yo', 'estaba'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'copreterito', 'tu', 'estabas'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'copreterito', 'el', 'estaba'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'copreterito', 'nosotros', 'estábamos'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'copreterito', 'vosotros', 'estabais'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'copreterito', 'ellos', 'estaban')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pospretérito (Condicional)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'pospreterito', 'yo', 'estaría'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'pospreterito', 'tu', 'estarías'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'pospreterito', 'el', 'estaría'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'pospreterito', 'nosotros', 'estaríamos'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'pospreterito', 'vosotros', 'estaríais'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'pospreterito', 'ellos', 'estarían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepresente (Pretérito Perfecto Compuesto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepresente', 'yo', 'he estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepresente', 'tu', 'has estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepresente', 'el', 'ha estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepresente', 'nosotros', 'hemos estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepresente', 'vosotros', 'habéis estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepresente', 'ellos', 'han estado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepretérito (Pretérito Anterior)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepreterito', 'yo', 'hube estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepreterito', 'tu', 'hubiste estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepreterito', 'el', 'hubo estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepreterito', 'nosotros', 'hubimos estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepreterito', 'vosotros', 'hubisteis estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepreterito', 'ellos', 'hubieron estado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antefuturo', 'yo', 'habré estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antefuturo', 'tu', 'habrás estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antefuturo', 'el', 'habrá estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antefuturo', 'nosotros', 'habremos estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antefuturo', 'vosotros', 'habréis estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antefuturo', 'ellos', 'habrán estado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antecopretérito (Pretérito Pluscuamperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antecopreterito', 'yo', 'había estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antecopreterito', 'tu', 'habías estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antecopreterito', 'el', 'había estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antecopreterito', 'nosotros', 'habíamos estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antecopreterito', 'vosotros', 'habíais estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antecopreterito', 'ellos', 'habían estado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepospretérito (Condicional Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepospreterito', 'yo', 'habría estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepospreterito', 'tu', 'habrías estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepospreterito', 'el', 'habría estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepospreterito', 'nosotros', 'habríamos estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepospreterito', 'vosotros', 'habríais estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'indicativo', 'antepospreterito', 'ellos', 'habrían estado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'presente', 'yo', 'esté'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'presente', 'tu', 'estés'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'presente', 'el', 'esté'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'presente', 'nosotros', 'estemos'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'presente', 'vosotros', 'estéis'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'presente', 'ellos', 'estén')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Pretérito (con formas alternativas -ra/-se)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'preterito', 'yo', 'estuviera', 'estuviese'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'preterito', 'tu', 'estuvieras', 'estuvieses'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'preterito', 'el', 'estuviera', 'estuviese'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'preterito', 'nosotros', 'estuviéramos', 'estuviésemos'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'preterito', 'vosotros', 'estuvierais', 'estuvieseis'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'preterito', 'ellos', 'estuvieran', 'estuviesen')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'futuro', 'yo', 'estuviere'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'futuro', 'tu', 'estuvieres'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'futuro', 'el', 'estuviere'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'futuro', 'nosotros', 'estuviéremos'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'futuro', 'vosotros', 'estuviereis'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'futuro', 'ellos', 'estuvieren')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepresente (Pretérito Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antepresente', 'yo', 'haya estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antepresente', 'tu', 'hayas estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antepresente', 'el', 'haya estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antepresente', 'nosotros', 'hayamos estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antepresente', 'vosotros', 'hayáis estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antepresente', 'ellos', 'hayan estado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepretérito (Pretérito Pluscuamperfecto) con formas alternativas
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antepreterito', 'yo', 'hubiera estado', 'hubiese estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antepreterito', 'tu', 'hubieras estado', 'hubieses estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antepreterito', 'el', 'hubiera estado', 'hubiese estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antepreterito', 'nosotros', 'hubiéramos estado', 'hubiésemos estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antepreterito', 'vosotros', 'hubierais estado', 'hubieseis estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antepreterito', 'ellos', 'hubieran estado', 'hubiesen estado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antefuturo', 'yo', 'hubiere estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antefuturo', 'tu', 'hubieres estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antefuturo', 'el', 'hubiere estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antefuturo', 'nosotros', 'hubiéremos estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antefuturo', 'vosotros', 'hubiereis estado'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'subjuntivo', 'antefuturo', 'ellos', 'hubieren estado')
ON CONFLICT DO NOTHING;

-- IMPERATIVO - Presente (solo tú, nosotros, vosotros)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'imperativo', 'presente', 'tu', 'está'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'imperativo', 'presente', 'nosotros', 'estemos'),
((SELECT id FROM verbos WHERE infinitivo = 'estar'), 'imperativo', 'presente', 'vosotros', 'estad')
ON CONFLICT DO NOTHING;

-- Insertar verbo: "andar"
INSERT INTO verbos (infinitivo) VALUES ('andar') ON CONFLICT DO NOTHING;

-- INDICATIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'presente', 'yo', 'ando'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'presente', 'tu', 'andas'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'presente', 'el', 'anda'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'presente', 'nosotros', 'andamos'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'presente', 'vosotros', 'andáis'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'presente', 'ellos', 'andan')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pretérito
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'preterito', 'yo', 'anduve'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'preterito', 'tu', 'anduviste'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'preterito', 'el', 'anduvo'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'preterito', 'nosotros', 'anduvimos'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'preterito', 'vosotros', 'anduvisteis'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'preterito', 'ellos', 'anduvieron')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'futuro', 'yo', 'andaré'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'futuro', 'tu', 'andarás'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'futuro', 'el', 'andará'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'futuro', 'nosotros', 'andaremos'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'futuro', 'vosotros', 'andaréis'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'futuro', 'ellos', 'andarán')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Copretérito (Pretérito Imperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'copreterito', 'yo', 'andaba'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'copreterito', 'tu', 'andabas'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'copreterito', 'el', 'andaba'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'copreterito', 'nosotros', 'andábamos'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'copreterito', 'vosotros', 'andabais'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'copreterito', 'ellos', 'andaban')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pospretérito (Condicional)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'pospreterito', 'yo', 'andaría'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'pospreterito', 'tu', 'andarías'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'pospreterito', 'el', 'andaría'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'pospreterito', 'nosotros', 'andaríamos'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'pospreterito', 'vosotros', 'andaríais'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'pospreterito', 'ellos', 'andarían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepresente (Pretérito Perfecto Compuesto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepresente', 'yo', 'he andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepresente', 'tu', 'has andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepresente', 'el', 'ha andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepresente', 'nosotros', 'hemos andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepresente', 'vosotros', 'habéis andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepresente', 'ellos', 'han andado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepretérito (Pretérito Anterior)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepreterito', 'yo', 'hube andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepreterito', 'tu', 'hubiste andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepreterito', 'el', 'hubo andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepreterito', 'nosotros', 'hubimos andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepreterito', 'vosotros', 'hubisteis andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepreterito', 'ellos', 'hubieron andado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antefuturo', 'yo', 'habré andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antefuturo', 'tu', 'habrás andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antefuturo', 'el', 'habrá andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antefuturo', 'nosotros', 'habremos andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antefuturo', 'vosotros', 'habréis andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antefuturo', 'ellos', 'habrán andado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antecopretérito (Pretérito Pluscuamperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antecopreterito', 'yo', 'había andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antecopreterito', 'tu', 'habías andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antecopreterito', 'el', 'había andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antecopreterito', 'nosotros', 'habíamos andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antecopreterito', 'vosotros', 'habíais andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antecopreterito', 'ellos', 'habían andado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepospretérito (Condicional Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepospreterito', 'yo', 'habría andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepospreterito', 'tu', 'habrías andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepospreterito', 'el', 'habría andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepospreterito', 'nosotros', 'habríamos andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepospreterito', 'vosotros', 'habríais andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'indicativo', 'antepospreterito', 'ellos', 'habrían andado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'presente', 'yo', 'ande'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'presente', 'tu', 'andes'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'presente', 'el', 'ande'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'presente', 'nosotros', 'andemos'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'presente', 'vosotros', 'andéis'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'presente', 'ellos', 'anden')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Pretérito (con formas alternativas -ra/-se)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'preterito', 'yo', 'anduviera', 'anduviese'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'preterito', 'tu', 'anduvieras', 'anduvieses'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'preterito', 'el', 'anduviera', 'anduviese'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'preterito', 'nosotros', 'anduviéramos', 'anduviésemos'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'preterito', 'vosotros', 'anduvierais', 'anduvieseis'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'preterito', 'ellos', 'anduvieran', 'anduviesen')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'futuro', 'yo', 'anduviere'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'futuro', 'tu', 'anduvieres'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'futuro', 'el', 'anduviere'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'futuro', 'nosotros', 'anduviéremos'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'futuro', 'vosotros', 'anduviereis'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'futuro', 'ellos', 'anduvieren')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepresente (Pretérito Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antepresente', 'yo', 'haya andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antepresente', 'tu', 'hayas andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antepresente', 'el', 'haya andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antepresente', 'nosotros', 'hayamos andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antepresente', 'vosotros', 'hayáis andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antepresente', 'ellos', 'hayan andado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepretérito (Pretérito Pluscuamperfecto) con formas alternativas
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antepreterito', 'yo', 'hubiera andado', 'hubiese andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antepreterito', 'tu', 'hubieras andado', 'hubieses andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antepreterito', 'el', 'hubiera andado', 'hubiese andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antepreterito', 'nosotros', 'hubiéramos andado', 'hubiésemos andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antepreterito', 'vosotros', 'hubierais andado', 'hubieseis andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antepreterito', 'ellos', 'hubieran andado', 'hubiesen andado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antefuturo', 'yo', 'hubiere andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antefuturo', 'tu', 'hubieres andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antefuturo', 'el', 'hubiere andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antefuturo', 'nosotros', 'hubiéremos andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antefuturo', 'vosotros', 'hubiereis andado'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'subjuntivo', 'antefuturo', 'ellos', 'hubieren andado')
ON CONFLICT DO NOTHING;

-- IMPERATIVO - Presente (solo tú, nosotros, vosotros)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'imperativo', 'presente', 'tu', 'anda'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'imperativo', 'presente', 'nosotros', 'andemos'),
((SELECT id FROM verbos WHERE infinitivo = 'andar'), 'imperativo', 'presente', 'vosotros', 'andad')
ON CONFLICT DO NOTHING;

-- Insertar verbo: "tener"
INSERT INTO verbos (infinitivo) VALUES ('tener') ON CONFLICT DO NOTHING;

-- INDICATIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'presente', 'yo', 'tengo'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'presente', 'tu', 'tienes'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'presente', 'el', 'tiene'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'presente', 'nosotros', 'tenemos'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'presente', 'vosotros', 'tenéis'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'presente', 'ellos', 'tienen')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pretérito
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'preterito', 'yo', 'tuve'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'preterito', 'tu', 'tuviste'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'preterito', 'el', 'tuvo'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'preterito', 'nosotros', 'tuvimos'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'preterito', 'vosotros', 'tuvisteis'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'preterito', 'ellos', 'tuvieron')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'futuro', 'yo', 'tendré'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'futuro', 'tu', 'tendrás'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'futuro', 'el', 'tendrá'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'futuro', 'nosotros', 'tendremos'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'futuro', 'vosotros', 'tendréis'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'futuro', 'ellos', 'tendrán')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Copretérito (Pretérito Imperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'copreterito', 'yo', 'tenía'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'copreterito', 'tu', 'tenías'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'copreterito', 'el', 'tenía'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'copreterito', 'nosotros', 'teníamos'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'copreterito', 'vosotros', 'teníais'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'copreterito', 'ellos', 'tenían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pospretérito (Condicional)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'pospreterito', 'yo', 'tendría'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'pospreterito', 'tu', 'tendrías'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'pospreterito', 'el', 'tendría'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'pospreterito', 'nosotros', 'tendríamos'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'pospreterito', 'vosotros', 'tendríais'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'pospreterito', 'ellos', 'tendrían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepresente (Pretérito Perfecto Compuesto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepresente', 'yo', 'he tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepresente', 'tu', 'has tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepresente', 'el', 'ha tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepresente', 'nosotros', 'hemos tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepresente', 'vosotros', 'habéis tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepresente', 'ellos', 'han tenido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepretérito (Pretérito Anterior)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepreterito', 'yo', 'hube tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepreterito', 'tu', 'hubiste tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepreterito', 'el', 'hubo tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepreterito', 'nosotros', 'hubimos tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepreterito', 'vosotros', 'hubisteis tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepreterito', 'ellos', 'hubieron tenido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antefuturo', 'yo', 'habré tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antefuturo', 'tu', 'habrás tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antefuturo', 'el', 'habrá tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antefuturo', 'nosotros', 'habremos tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antefuturo', 'vosotros', 'habréis tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antefuturo', 'ellos', 'habrán tenido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antecopretérito (Pretérito Pluscuamperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antecopreterito', 'yo', 'había tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antecopreterito', 'tu', 'habías tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antecopreterito', 'el', 'había tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antecopreterito', 'nosotros', 'habíamos tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antecopreterito', 'vosotros', 'habíais tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antecopreterito', 'ellos', 'habían tenido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepospretérito (Condicional Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepospreterito', 'yo', 'habría tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepospreterito', 'tu', 'habrías tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepospreterito', 'el', 'habría tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepospreterito', 'nosotros', 'habríamos tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepospreterito', 'vosotros', 'habríais tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'indicativo', 'antepospreterito', 'ellos', 'habrían tenido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'presente', 'yo', 'tenga'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'presente', 'tu', 'tengas'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'presente', 'el', 'tenga'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'presente', 'nosotros', 'tengamos'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'presente', 'vosotros', 'tengáis'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'presente', 'ellos', 'tengan')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Pretérito (con formas alternativas -ra/-se)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'preterito', 'yo', 'tuviera', 'tuviese'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'preterito', 'tu', 'tuvieras', 'tuvieses'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'preterito', 'el', 'tuviera', 'tuviese'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'preterito', 'nosotros', 'tuviéramos', 'tuviésemos'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'preterito', 'vosotros', 'tuvierais', 'tuvieseis'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'preterito', 'ellos', 'tuvieran', 'tuviesen')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'futuro', 'yo', 'tuviere'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'futuro', 'tu', 'tuvieres'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'futuro', 'el', 'tuviere'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'futuro', 'nosotros', 'tuviéremos'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'futuro', 'vosotros', 'tuviereis'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'futuro', 'ellos', 'tuvieren')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepresente (Pretérito Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antepresente', 'yo', 'haya tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antepresente', 'tu', 'hayas tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antepresente', 'el', 'haya tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antepresente', 'nosotros', 'hayamos tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antepresente', 'vosotros', 'hayáis tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antepresente', 'ellos', 'hayan tenido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepretérito (Pretérito Pluscuamperfecto) con formas alternativas
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antepreterito', 'yo', 'hubiera tenido', 'hubiese tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antepreterito', 'tu', 'hubieras tenido', 'hubieses tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antepreterito', 'el', 'hubiera tenido', 'hubiese tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antepreterito', 'nosotros', 'hubiéramos tenido', 'hubiésemos tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antepreterito', 'vosotros', 'hubierais tenido', 'hubieseis tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antepreterito', 'ellos', 'hubieran tenido', 'hubiesen tenido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antefuturo', 'yo', 'hubiere tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antefuturo', 'tu', 'hubieres tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antefuturo', 'el', 'hubiere tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antefuturo', 'nosotros', 'hubiéremos tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antefuturo', 'vosotros', 'hubiereis tenido'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'subjuntivo', 'antefuturo', 'ellos', 'hubieren tenido')
ON CONFLICT DO NOTHING;

-- IMPERATIVO - Presente (solo tú, nosotros, vosotros)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'imperativo', 'presente', 'tu', 'ten'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'imperativo', 'presente', 'nosotros', 'tengamos'),
((SELECT id FROM verbos WHERE infinitivo = 'tener'), 'imperativo', 'presente', 'vosotros', 'tened')
ON CONFLICT DO NOTHING;

-- Insertar verbo: "ver"
INSERT INTO verbos (infinitivo) VALUES ('ver') ON CONFLICT DO NOTHING;

-- INDICATIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'presente', 'yo', 'veo'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'presente', 'tu', 'ves'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'presente', 'el', 've'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'presente', 'nosotros', 'vemos'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'presente', 'vosotros', 'veis'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'presente', 'ellos', 'ven')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pretérito
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'preterito', 'yo', 'vi'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'preterito', 'tu', 'viste'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'preterito', 'el', 'vio'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'preterito', 'nosotros', 'vimos'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'preterito', 'vosotros', 'visteis'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'preterito', 'ellos', 'vieron')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'futuro', 'yo', 'veré'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'futuro', 'tu', 'verás'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'futuro', 'el', 'verá'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'futuro', 'nosotros', 'veremos'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'futuro', 'vosotros', 'veréis'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'futuro', 'ellos', 'verán')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Copretérito (Pretérito Imperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'copreterito', 'yo', 'veía'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'copreterito', 'tu', 'veías'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'copreterito', 'el', 'veía'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'copreterito', 'nosotros', 'veíamos'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'copreterito', 'vosotros', 'veíais'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'copreterito', 'ellos', 'veían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pospretérito (Condicional)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'pospreterito', 'yo', 'vería'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'pospreterito', 'tu', 'verías'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'pospreterito', 'el', 'vería'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'pospreterito', 'nosotros', 'veríamos'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'pospreterito', 'vosotros', 'veríais'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'pospreterito', 'ellos', 'verían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepresente (Pretérito Perfecto Compuesto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepresente', 'yo', 'he visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepresente', 'tu', 'has visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepresente', 'el', 'ha visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepresente', 'nosotros', 'hemos visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepresente', 'vosotros', 'habéis visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepresente', 'ellos', 'han visto')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepretérito (Pretérito Anterior)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepreterito', 'yo', 'hube visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepreterito', 'tu', 'hubiste visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepreterito', 'el', 'hubo visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepreterito', 'nosotros', 'hubimos visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepreterito', 'vosotros', 'hubisteis visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepreterito', 'ellos', 'hubieron visto')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antefuturo', 'yo', 'habré visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antefuturo', 'tu', 'habrás visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antefuturo', 'el', 'habrá visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antefuturo', 'nosotros', 'habremos visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antefuturo', 'vosotros', 'habréis visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antefuturo', 'ellos', 'habrán visto')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antecopretérito (Pretérito Pluscuamperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antecopreterito', 'yo', 'había visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antecopreterito', 'tu', 'habías visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antecopreterito', 'el', 'había visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antecopreterito', 'nosotros', 'habíamos visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antecopreterito', 'vosotros', 'habíais visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antecopreterito', 'ellos', 'habían visto')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepospretérito (Condicional Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepospreterito', 'yo', 'habría visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepospreterito', 'tu', 'habrías visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepospreterito', 'el', 'habría visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepospreterito', 'nosotros', 'habríamos visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepospreterito', 'vosotros', 'habríais visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'indicativo', 'antepospreterito', 'ellos', 'habrían visto')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'presente', 'yo', 'vea'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'presente', 'tu', 'veas'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'presente', 'el', 'vea'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'presente', 'nosotros', 'veamos'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'presente', 'vosotros', 'veáis'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'presente', 'ellos', 'vean')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Pretérito (con formas alternativas -ra/-se)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'preterito', 'yo', 'viera', 'viese'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'preterito', 'tu', 'vieras', 'vieses'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'preterito', 'el', 'viera', 'viese'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'preterito', 'nosotros', 'viéramos', 'viésemos'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'preterito', 'vosotros', 'vierais', 'vieseis'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'preterito', 'ellos', 'vieran', 'viesen')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'futuro', 'yo', 'viere'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'futuro', 'tu', 'vieres'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'futuro', 'el', 'viere'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'futuro', 'nosotros', 'viéremos'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'futuro', 'vosotros', 'viereis'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'futuro', 'ellos', 'vieren')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepresente (Pretérito Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antepresente', 'yo', 'haya visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antepresente', 'tu', 'hayas visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antepresente', 'el', 'haya visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antepresente', 'nosotros', 'hayamos visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antepresente', 'vosotros', 'hayáis visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antepresente', 'ellos', 'hayan visto')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepretérito (Pretérito Pluscuamperfecto) con formas alternativas
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antepreterito', 'yo', 'hubiera visto', 'hubiese visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antepreterito', 'tu', 'hubieras visto', 'hubieses visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antepreterito', 'el', 'hubiera visto', 'hubiese visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antepreterito', 'nosotros', 'hubiéramos visto', 'hubiésemos visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antepreterito', 'vosotros', 'hubierais visto', 'hubieseis visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antepreterito', 'ellos', 'hubieran visto', 'hubiesen visto')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antefuturo', 'yo', 'hubiere visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antefuturo', 'tu', 'hubieres visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antefuturo', 'el', 'hubiere visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antefuturo', 'nosotros', 'hubiéremos visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antefuturo', 'vosotros', 'hubiereis visto'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'subjuntivo', 'antefuturo', 'ellos', 'hubieren visto')
ON CONFLICT DO NOTHING;

-- IMPERATIVO - Presente (solo tú, nosotros, vosotros)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'imperativo', 'presente', 'tu', 've'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'imperativo', 'presente', 'nosotros', 'veamos'),
((SELECT id FROM verbos WHERE infinitivo = 'ver'), 'imperativo', 'presente', 'vosotros', 'ved')
ON CONFLICT DO NOTHING;

-- Insertar verbo: "hervir"
INSERT INTO verbos (infinitivo) VALUES ('hervir') ON CONFLICT DO NOTHING;

-- INDICATIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'presente', 'yo', 'hiervo'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'presente', 'tu', 'hierves'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'presente', 'el', 'hierve'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'presente', 'nosotros', 'hervimos'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'presente', 'vosotros', 'hervís'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'presente', 'ellos', 'hierven')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pretérito
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'preterito', 'yo', 'herví'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'preterito', 'tu', 'herviste'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'preterito', 'el', 'hirvió'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'preterito', 'nosotros', 'hervimos'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'preterito', 'vosotros', 'hervisteis'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'preterito', 'ellos', 'hirvieron')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'futuro', 'yo', 'herviré'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'futuro', 'tu', 'hervirás'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'futuro', 'el', 'hervirá'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'futuro', 'nosotros', 'herviremos'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'futuro', 'vosotros', 'herviréis'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'futuro', 'ellos', 'hervirán')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Copretérito (Pretérito Imperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'copreterito', 'yo', 'hervía'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'copreterito', 'tu', 'hervías'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'copreterito', 'el', 'hervía'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'copreterito', 'nosotros', 'hervíamos'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'copreterito', 'vosotros', 'hervíais'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'copreterito', 'ellos', 'hervían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pospretérito (Condicional)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'pospreterito', 'yo', 'herviría'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'pospreterito', 'tu', 'hervirías'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'pospreterito', 'el', 'herviría'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'pospreterito', 'nosotros', 'herviríamos'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'pospreterito', 'vosotros', 'herviríais'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'pospreterito', 'ellos', 'hervirían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepresente (Pretérito Perfecto Compuesto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepresente', 'yo', 'he hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepresente', 'tu', 'has hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepresente', 'el', 'ha hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepresente', 'nosotros', 'hemos hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepresente', 'vosotros', 'habéis hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepresente', 'ellos', 'han hervido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepretérito (Pretérito Anterior)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepreterito', 'yo', 'hube hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepreterito', 'tu', 'hubiste hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepreterito', 'el', 'hubo hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepreterito', 'nosotros', 'hubimos hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepreterito', 'vosotros', 'hubisteis hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepreterito', 'ellos', 'hubieron hervido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antefuturo', 'yo', 'habré hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antefuturo', 'tu', 'habrás hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antefuturo', 'el', 'habrá hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antefuturo', 'nosotros', 'habremos hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antefuturo', 'vosotros', 'habréis hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antefuturo', 'ellos', 'habrán hervido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antecopretérito (Pretérito Pluscuamperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antecopreterito', 'yo', 'había hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antecopreterito', 'tu', 'habías hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antecopreterito', 'el', 'había hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antecopreterito', 'nosotros', 'habíamos hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antecopreterito', 'vosotros', 'habíais hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antecopreterito', 'ellos', 'habían hervido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepospretérito (Condicional Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepospreterito', 'yo', 'habría hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepospreterito', 'tu', 'habrías hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepospreterito', 'el', 'habría hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepospreterito', 'nosotros', 'habríamos hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepospreterito', 'vosotros', 'habríais hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'indicativo', 'antepospreterito', 'ellos', 'habrían hervido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'presente', 'yo', 'hierva'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'presente', 'tu', 'hiervas'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'presente', 'el', 'hierva'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'presente', 'nosotros', 'hirvamos'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'presente', 'vosotros', 'hirváis'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'presente', 'ellos', 'hiervan')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Pretérito (con formas alternativas -ra/-se)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'preterito', 'yo', 'hirviera', 'hirviese'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'preterito', 'tu', 'hirvieras', 'hirvieses'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'preterito', 'el', 'hirviera', 'hirviese'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'preterito', 'nosotros', 'hirviéramos', 'hirviésemos'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'preterito', 'vosotros', 'hirvierais', 'hirvieseis'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'preterito', 'ellos', 'hirvieran', 'hirviesen')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'futuro', 'yo', 'hirviere'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'futuro', 'tu', 'hirvieres'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'futuro', 'el', 'hirviere'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'futuro', 'nosotros', 'hirviéremos'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'futuro', 'vosotros', 'hirviereis'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'futuro', 'ellos', 'hirvieren')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepresente (Pretérito Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antepresente', 'yo', 'haya hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antepresente', 'tu', 'hayas hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antepresente', 'el', 'haya hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antepresente', 'nosotros', 'hayamos hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antepresente', 'vosotros', 'hayáis hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antepresente', 'ellos', 'hayan hervido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepretérito (Pretérito Pluscuamperfecto) con formas alternativas
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antepreterito', 'yo', 'hubiera hervido', 'hubiese hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antepreterito', 'tu', 'hubieras hervido', 'hubieses hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antepreterito', 'el', 'hubiera hervido', 'hubiese hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antepreterito', 'nosotros', 'hubiéramos hervido', 'hubiésemos hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antepreterito', 'vosotros', 'hubierais hervido', 'hubieseis hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antepreterito', 'ellos', 'hubieran hervido', 'hubiesen hervido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antefuturo', 'yo', 'hubiere hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antefuturo', 'tu', 'hubieres hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antefuturo', 'el', 'hubiere hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antefuturo', 'nosotros', 'hubiéremos hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antefuturo', 'vosotros', 'hubiereis hervido'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'subjuntivo', 'antefuturo', 'ellos', 'hubieren hervido')
ON CONFLICT DO NOTHING;

-- IMPERATIVO - Presente (solo tú, nosotros, vosotros)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'imperativo', 'presente', 'tu', 'hierve'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'imperativo', 'presente', 'nosotros', 'hirvamos'),
((SELECT id FROM verbos WHERE infinitivo = 'hervir'), 'imperativo', 'presente', 'vosotros', 'hervid')
ON CONFLICT DO NOTHING;

-- Insertar verbo: "servir"
INSERT INTO verbos (infinitivo) VALUES ('servir') ON CONFLICT DO NOTHING;

-- INDICATIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'presente', 'yo', 'sirvo'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'presente', 'tu', 'sirves'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'presente', 'el', 'sirve'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'presente', 'nosotros', 'servimos'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'presente', 'vosotros', 'servís'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'presente', 'ellos', 'sirven')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pretérito
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'preterito', 'yo', 'serví'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'preterito', 'tu', 'serviste'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'preterito', 'el', 'sirvió'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'preterito', 'nosotros', 'servimos'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'preterito', 'vosotros', 'servisteis'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'preterito', 'ellos', 'sirvieron')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'futuro', 'yo', 'serviré'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'futuro', 'tu', 'servirás'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'futuro', 'el', 'servirá'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'futuro', 'nosotros', 'serviremos'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'futuro', 'vosotros', 'serviréis'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'futuro', 'ellos', 'servirán')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Copretérito (Pretérito Imperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'copreterito', 'yo', 'servía'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'copreterito', 'tu', 'servías'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'copreterito', 'el', 'servía'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'copreterito', 'nosotros', 'servíamos'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'copreterito', 'vosotros', 'servíais'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'copreterito', 'ellos', 'servían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pospretérito (Condicional)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'pospreterito', 'yo', 'serviría'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'pospreterito', 'tu', 'servirías'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'pospreterito', 'el', 'serviría'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'pospreterito', 'nosotros', 'serviríamos'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'pospreterito', 'vosotros', 'serviríais'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'pospreterito', 'ellos', 'servirían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepresente (Pretérito Perfecto Compuesto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepresente', 'yo', 'he servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepresente', 'tu', 'has servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepresente', 'el', 'ha servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepresente', 'nosotros', 'hemos servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepresente', 'vosotros', 'habéis servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepresente', 'ellos', 'han servido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepretérito (Pretérito Anterior)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepreterito', 'yo', 'hube servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepreterito', 'tu', 'hubiste servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepreterito', 'el', 'hubo servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepreterito', 'nosotros', 'hubimos servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepreterito', 'vosotros', 'hubisteis servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepreterito', 'ellos', 'hubieron servido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antefuturo', 'yo', 'habré servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antefuturo', 'tu', 'habrás servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antefuturo', 'el', 'habrá servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antefuturo', 'nosotros', 'habremos servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antefuturo', 'vosotros', 'habréis servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antefuturo', 'ellos', 'habrán servido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antecopretérito (Pretérito Pluscuamperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antecopreterito', 'yo', 'había servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antecopreterito', 'tu', 'habías servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antecopreterito', 'el', 'había servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antecopreterito', 'nosotros', 'habíamos servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antecopreterito', 'vosotros', 'habíais servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antecopreterito', 'ellos', 'habían servido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepospretérito (Condicional Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepospreterito', 'yo', 'habría servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepospreterito', 'tu', 'habrías servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepospreterito', 'el', 'habría servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepospreterito', 'nosotros', 'habríamos servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepospreterito', 'vosotros', 'habríais servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'indicativo', 'antepospreterito', 'ellos', 'habrían servido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'presente', 'yo', 'sirva'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'presente', 'tu', 'sirvas'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'presente', 'el', 'sirva'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'presente', 'nosotros', 'sirvamos'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'presente', 'vosotros', 'sirváis'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'presente', 'ellos', 'sirvan')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Pretérito (con formas alternativas -ra/-se)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'preterito', 'yo', 'sirviera', 'sirviese'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'preterito', 'tu', 'sirvieras', 'sirvieses'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'preterito', 'el', 'sirviera', 'sirviese'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'preterito', 'nosotros', 'sirviéramos', 'sirviésemos'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'preterito', 'vosotros', 'sirvierais', 'sirvieseis'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'preterito', 'ellos', 'sirvieran', 'sirviesen')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'futuro', 'yo', 'sirviere'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'futuro', 'tu', 'sirvieres'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'futuro', 'el', 'sirviere'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'futuro', 'nosotros', 'sirviéremos'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'futuro', 'vosotros', 'sirviereis'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'futuro', 'ellos', 'sirvieren')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepresente (Pretérito Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antepresente', 'yo', 'haya servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antepresente', 'tu', 'hayas servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antepresente', 'el', 'haya servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antepresente', 'nosotros', 'hayamos servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antepresente', 'vosotros', 'hayáis servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antepresente', 'ellos', 'hayan servido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepretérito (Pretérito Pluscuamperfecto) con formas alternativas
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antepreterito', 'yo', 'hubiera servido', 'hubiese servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antepreterito', 'tu', 'hubieras servido', 'hubieses servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antepreterito', 'el', 'hubiera servido', 'hubiese servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antepreterito', 'nosotros', 'hubiéramos servido', 'hubiésemos servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antepreterito', 'vosotros', 'hubierais servido', 'hubieseis servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antepreterito', 'ellos', 'hubieran servido', 'hubiesen servido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antefuturo', 'yo', 'hubiere servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antefuturo', 'tu', 'hubieres servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antefuturo', 'el', 'hubiere servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antefuturo', 'nosotros', 'hubiéremos servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antefuturo', 'vosotros', 'hubiereis servido'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'subjuntivo', 'antefuturo', 'ellos', 'hubieren servido')
ON CONFLICT DO NOTHING;

-- IMPERATIVO - Presente (solo tú, nosotros, vosotros)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'imperativo', 'presente', 'tu', 'sirve'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'imperativo', 'presente', 'nosotros', 'sirvamos'),
((SELECT id FROM verbos WHERE infinitivo = 'servir'), 'imperativo', 'presente', 'vosotros', 'servid')
ON CONFLICT DO NOTHING;

-- Insertar verbo: "vivir"
INSERT INTO verbos (infinitivo) VALUES ('vivir') ON CONFLICT DO NOTHING;

-- INDICATIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'presente', 'yo', 'vivo'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'presente', 'tu', 'vives'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'presente', 'el', 'vive'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'presente', 'nosotros', 'vivimos'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'presente', 'vosotros', 'vivís'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'presente', 'ellos', 'viven')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pretérito
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'preterito', 'yo', 'viví'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'preterito', 'tu', 'viviste'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'preterito', 'el', 'vivió'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'preterito', 'nosotros', 'vivimos'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'preterito', 'vosotros', 'vivisteis'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'preterito', 'ellos', 'vivieron')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'futuro', 'yo', 'viviré'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'futuro', 'tu', 'vivirás'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'futuro', 'el', 'vivirá'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'futuro', 'nosotros', 'viviremos'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'futuro', 'vosotros', 'viviréis'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'futuro', 'ellos', 'vivirán')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Copretérito (Pretérito Imperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'copreterito', 'yo', 'vivía'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'copreterito', 'tu', 'vivías'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'copreterito', 'el', 'vivía'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'copreterito', 'nosotros', 'vivíamos'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'copreterito', 'vosotros', 'vivíais'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'copreterito', 'ellos', 'vivían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pospretérito (Condicional)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'pospreterito', 'yo', 'viviría'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'pospreterito', 'tu', 'vivirías'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'pospreterito', 'el', 'viviría'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'pospreterito', 'nosotros', 'viviríamos'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'pospreterito', 'vosotros', 'viviríais'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'pospreterito', 'ellos', 'vivirían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepresente (Pretérito Perfecto Compuesto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepresente', 'yo', 'he vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepresente', 'tu', 'has vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepresente', 'el', 'ha vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepresente', 'nosotros', 'hemos vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepresente', 'vosotros', 'habéis vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepresente', 'ellos', 'han vivido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepretérito (Pretérito Anterior)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepreterito', 'yo', 'hube vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepreterito', 'tu', 'hubiste vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepreterito', 'el', 'hubo vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepreterito', 'nosotros', 'hubimos vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepreterito', 'vosotros', 'hubisteis vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepreterito', 'ellos', 'hubieron vivido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antefuturo', 'yo', 'habré vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antefuturo', 'tu', 'habrás vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antefuturo', 'el', 'habrá vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antefuturo', 'nosotros', 'habremos vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antefuturo', 'vosotros', 'habréis vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antefuturo', 'ellos', 'habrán vivido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antecopretérito (Pretérito Pluscuamperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antecopreterito', 'yo', 'había vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antecopreterito', 'tu', 'habías vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antecopreterito', 'el', 'había vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antecopreterito', 'nosotros', 'habíamos vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antecopreterito', 'vosotros', 'habíais vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antecopreterito', 'ellos', 'habían vivido')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepospretérito (Condicional Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepospreterito', 'yo', 'habría vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepospreterito', 'tu', 'habrías vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepospreterito', 'el', 'habría vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepospreterito', 'nosotros', 'habríamos vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepospreterito', 'vosotros', 'habríais vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'indicativo', 'antepospreterito', 'ellos', 'habrían vivido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'presente', 'yo', 'viva'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'presente', 'tu', 'vivas'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'presente', 'el', 'viva'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'presente', 'nosotros', 'vivamos'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'presente', 'vosotros', 'viváis'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'presente', 'ellos', 'vivan')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Pretérito (con formas alternativas -ra/-se)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'preterito', 'yo', 'viviera', 'viviese'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'preterito', 'tu', 'vivieras', 'vivieses'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'preterito', 'el', 'viviera', 'viviese'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'preterito', 'nosotros', 'viviéramos', 'viviésemos'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'preterito', 'vosotros', 'vivierais', 'vivieseis'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'preterito', 'ellos', 'vivieran', 'viviesen')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'futuro', 'yo', 'viviere'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'futuro', 'tu', 'vivieres'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'futuro', 'el', 'viviere'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'futuro', 'nosotros', 'viviéremos'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'futuro', 'vosotros', 'viviereis'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'futuro', 'ellos', 'vivieren')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepresente (Pretérito Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antepresente', 'yo', 'haya vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antepresente', 'tu', 'hayas vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antepresente', 'el', 'haya vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antepresente', 'nosotros', 'hayamos vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antepresente', 'vosotros', 'hayáis vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antepresente', 'ellos', 'hayan vivido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepretérito (Pretérito Pluscuamperfecto) con formas alternativas
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antepreterito', 'yo', 'hubiera vivido', 'hubiese vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antepreterito', 'tu', 'hubieras vivido', 'hubieses vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antepreterito', 'el', 'hubiera vivido', 'hubiese vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antepreterito', 'nosotros', 'hubiéramos vivido', 'hubiésemos vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antepreterito', 'vosotros', 'hubierais vivido', 'hubieseis vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antepreterito', 'ellos', 'hubieran vivido', 'hubiesen vivido')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antefuturo', 'yo', 'hubiere vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antefuturo', 'tu', 'hubieres vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antefuturo', 'el', 'hubiere vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antefuturo', 'nosotros', 'hubiéremos vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antefuturo', 'vosotros', 'hubiereis vivido'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'subjuntivo', 'antefuturo', 'ellos', 'hubieren vivido')
ON CONFLICT DO NOTHING;

-- IMPERATIVO - Presente (solo tú, nosotros, vosotros)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'imperativo', 'presente', 'tu', 'vive'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'imperativo', 'presente', 'nosotros', 'vivamos'),
((SELECT id FROM verbos WHERE infinitivo = 'vivir'), 'imperativo', 'presente', 'vosotros', 'vivid')
ON CONFLICT DO NOTHING;

-- Insertar verbo: "dar"
INSERT INTO verbos (infinitivo) VALUES ('dar') ON CONFLICT DO NOTHING;

-- INDICATIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'presente', 'yo', 'doy'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'presente', 'tu', 'das'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'presente', 'el', 'da'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'presente', 'nosotros', 'damos'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'presente', 'vosotros', 'dais'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'presente', 'ellos', 'dan')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pretérito
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'preterito', 'yo', 'di'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'preterito', 'tu', 'diste'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'preterito', 'el', 'dio'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'preterito', 'nosotros', 'dimos'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'preterito', 'vosotros', 'disteis'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'preterito', 'ellos', 'dieron')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'futuro', 'yo', 'daré'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'futuro', 'tu', 'darás'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'futuro', 'el', 'dará'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'futuro', 'nosotros', 'daremos'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'futuro', 'vosotros', 'daréis'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'futuro', 'ellos', 'darán')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Copretérito (Pretérito Imperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'copreterito', 'yo', 'daba'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'copreterito', 'tu', 'dabas'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'copreterito', 'el', 'daba'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'copreterito', 'nosotros', 'dábamos'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'copreterito', 'vosotros', 'dabais'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'copreterito', 'ellos', 'daban')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Pospretérito (Condicional)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'pospreterito', 'yo', 'daría'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'pospreterito', 'tu', 'darías'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'pospreterito', 'el', 'daría'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'pospreterito', 'nosotros', 'daríamos'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'pospreterito', 'vosotros', 'daríais'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'pospreterito', 'ellos', 'darían')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepresente (Pretérito Perfecto Compuesto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepresente', 'yo', 'he dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepresente', 'tu', 'has dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepresente', 'el', 'ha dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepresente', 'nosotros', 'hemos dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepresente', 'vosotros', 'habéis dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepresente', 'ellos', 'han dado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepretérito (Pretérito Anterior)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepreterito', 'yo', 'hube dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepreterito', 'tu', 'hubiste dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepreterito', 'el', 'hubo dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepreterito', 'nosotros', 'hubimos dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepreterito', 'vosotros', 'hubisteis dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepreterito', 'ellos', 'hubieron dado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antefuturo', 'yo', 'habré dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antefuturo', 'tu', 'habrás dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antefuturo', 'el', 'habrá dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antefuturo', 'nosotros', 'habremos dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antefuturo', 'vosotros', 'habréis dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antefuturo', 'ellos', 'habrán dado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antecopretérito (Pretérito Pluscuamperfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antecopreterito', 'yo', 'había dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antecopreterito', 'tu', 'habías dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antecopreterito', 'el', 'había dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antecopreterito', 'nosotros', 'habíamos dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antecopreterito', 'vosotros', 'habíais dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antecopreterito', 'ellos', 'habían dado')
ON CONFLICT DO NOTHING;

-- INDICATIVO - Antepospretérito (Condicional Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepospreterito', 'yo', 'habría dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepospreterito', 'tu', 'habrías dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepospreterito', 'el', 'habría dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepospreterito', 'nosotros', 'habríamos dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepospreterito', 'vosotros', 'habríais dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'indicativo', 'antepospreterito', 'ellos', 'habrían dado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Presente
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'presente', 'yo', 'dé'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'presente', 'tu', 'des'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'presente', 'el', 'dé'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'presente', 'nosotros', 'demos'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'presente', 'vosotros', 'deis'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'presente', 'ellos', 'den')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Pretérito (con formas alternativas -ra/-se)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'preterito', 'yo', 'diera', 'diese'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'preterito', 'tu', 'dieras', 'dieses'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'preterito', 'el', 'diera', 'diese'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'preterito', 'nosotros', 'diéramos', 'diésemos'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'preterito', 'vosotros', 'dierais', 'dieseis'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'preterito', 'ellos', 'dieran', 'diesen')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Futuro
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'futuro', 'yo', 'diere'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'futuro', 'tu', 'dieres'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'futuro', 'el', 'diere'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'futuro', 'nosotros', 'diéremos'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'futuro', 'vosotros', 'diereis'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'futuro', 'ellos', 'dieren')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepresente (Pretérito Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antepresente', 'yo', 'haya dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antepresente', 'tu', 'hayas dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antepresente', 'el', 'haya dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antepresente', 'nosotros', 'hayamos dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antepresente', 'vosotros', 'hayáis dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antepresente', 'ellos', 'hayan dado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antepretérito (Pretérito Pluscuamperfecto) con formas alternativas
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma, forma_alternativa) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antepreterito', 'yo', 'hubiera dado', 'hubiese dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antepreterito', 'tu', 'hubieras dado', 'hubieses dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antepreterito', 'el', 'hubiera dado', 'hubiese dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antepreterito', 'nosotros', 'hubiéramos dado', 'hubiésemos dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antepreterito', 'vosotros', 'hubierais dado', 'hubieseis dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antepreterito', 'ellos', 'hubieran dado', 'hubiesen dado')
ON CONFLICT DO NOTHING;

-- SUBJUNTIVO - Antefuturo (Futuro Perfecto)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antefuturo', 'yo', 'hubiere dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antefuturo', 'tu', 'hubieres dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antefuturo', 'el', 'hubiere dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antefuturo', 'nosotros', 'hubiéremos dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antefuturo', 'vosotros', 'hubiereis dado'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'subjuntivo', 'antefuturo', 'ellos', 'hubieren dado')
ON CONFLICT DO NOTHING;

-- IMPERATIVO - Presente (solo tú, nosotros, vosotros)
INSERT INTO conjugaciones (verbo_id, modo, tiempo, persona, forma) VALUES
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'imperativo', 'presente', 'tu', 'da'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'imperativo', 'presente', 'nosotros', 'demos'),
((SELECT id FROM verbos WHERE infinitivo = 'dar'), 'imperativo', 'presente', 'vosotros', 'dad')
ON CONFLICT DO NOTHING;
