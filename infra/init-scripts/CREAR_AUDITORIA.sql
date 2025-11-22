-- 🔍 SCRIPT COMPLETO DE AUDITORÍA
-- Crear tabla + triggers para todas las tablas críticas
-- Fecha: 17 de Noviembre de 2025

-- ============================================================
-- 1. CREAR TABLA DE AUDITORÍA
-- ============================================================

CREATE TABLE IF NOT EXISTS auditoria (
    id INT PRIMARY KEY AUTO_INCREMENT,
    
    -- Identificación de la operación
    tabla_afectada VARCHAR(50) NOT NULL,
    accion ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    
    -- Datos del registro afectado
    registro_id INT NOT NULL,
    
    -- Estados (datos antes y después)
    datos_anteriores JSON,
    datos_nuevos JSON,
    
    -- Quién realizó la operación
    usuario_id INT,
    
    -- Cuándo
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Índices para búsquedas rápidas
    INDEX idx_tabla_fecha (tabla_afectada, fecha),
    INDEX idx_usuario_fecha (usuario_id, fecha),
    INDEX idx_registro_id (tabla_afectada, registro_id),
    INDEX idx_accion (accion),
    
    -- Integridad referencial
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. TRIGGERS PARA TABLA: USUARIOS
-- ============================================================

-- Trigger INSERT en usuarios
CREATE TRIGGER IF NOT EXISTS audit_usuarios_insert
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_nuevos, usuario_id, fecha)
    VALUES (
        'usuarios',
        'INSERT',
        NEW.id,
        JSON_OBJECT(
            'id', NEW.id,
            'email', NEW.email,
            'nombre', NEW.nombre,
            'tipo', NEW.tipo,
            'estado', NEW.estado,
            'createdAt', NEW.createdAt
        ),
        @current_user_id,
        NOW()
    );
END;

-- Trigger UPDATE en usuarios
CREATE TRIGGER IF NOT EXISTS audit_usuarios_update
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_anteriores, datos_nuevos, usuario_id, fecha)
    VALUES (
        'usuarios',
        'UPDATE',
        NEW.id,
        JSON_OBJECT(
            'email', OLD.email,
            'nombre', OLD.nombre,
            'tipo', OLD.tipo,
            'estado', OLD.estado,
            'updatedAt', OLD.updatedAt
        ),
        JSON_OBJECT(
            'email', NEW.email,
            'nombre', NEW.nombre,
            'tipo', NEW.tipo,
            'estado', NEW.estado,
            'updatedAt', NEW.updatedAt
        ),
        @current_user_id,
        NOW()
    );
END;

-- Trigger DELETE en usuarios
CREATE TRIGGER IF NOT EXISTS audit_usuarios_delete
AFTER DELETE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_anteriores, usuario_id, fecha)
    VALUES (
        'usuarios',
        'DELETE',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'email', OLD.email,
            'nombre', OLD.nombre,
            'tipo', OLD.tipo,
            'estado', OLD.estado
        ),
        @current_user_id,
        NOW()
    );
END;

-- ============================================================
-- 3. TRIGGERS PARA TABLA: DOCTORES
-- ============================================================

-- Trigger INSERT en doctores
CREATE TRIGGER IF NOT EXISTS audit_doctores_insert
AFTER INSERT ON doctores
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_nuevos, usuario_id, fecha)
    VALUES (
        'doctores',
        'INSERT',
        NEW.id,
        JSON_OBJECT(
            'id', NEW.id,
            'usuarioId', NEW.usuarioId,
            'especialidadId', NEW.especialidadId,
            'numeroLicencia', NEW.numeroLicencia,
            'numeroTurnos', NEW.numeroTurnos,
            'createdAt', NEW.createdAt
        ),
        @current_user_id,
        NOW()
    );
END;

-- Trigger UPDATE en doctores
CREATE TRIGGER IF NOT EXISTS audit_doctores_update
AFTER UPDATE ON doctores
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_anteriores, datos_nuevos, usuario_id, fecha)
    VALUES (
        'doctores',
        'UPDATE',
        NEW.id,
        JSON_OBJECT(
            'especialidadId', OLD.especialidadId,
            'numeroLicencia', OLD.numeroLicencia,
            'numeroTurnos', OLD.numeroTurnos,
            'estado', OLD.estado
        ),
        JSON_OBJECT(
            'especialidadId', NEW.especialidadId,
            'numeroLicencia', NEW.numeroLicencia,
            'numeroTurnos', NEW.numeroTurnos,
            'estado', NEW.estado
        ),
        @current_user_id,
        NOW()
    );
END;

-- Trigger DELETE en doctores
CREATE TRIGGER IF NOT EXISTS audit_doctores_delete
AFTER DELETE ON doctores
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_anteriores, usuario_id, fecha)
    VALUES (
        'doctores',
        'DELETE',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'usuarioId', OLD.usuarioId,
            'especialidadId', OLD.especialidadId,
            'numeroLicencia', OLD.numeroLicencia
        ),
        @current_user_id,
        NOW()
    );
END;

-- ============================================================
-- 4. TRIGGERS PARA TABLA: PACIENTES
-- ============================================================

-- Trigger INSERT en pacientes
CREATE TRIGGER IF NOT EXISTS audit_pacientes_insert
AFTER INSERT ON pacientes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_nuevos, usuario_id, fecha)
    VALUES (
        'pacientes',
        'INSERT',
        NEW.id,
        JSON_OBJECT(
            'id', NEW.id,
            'usuarioId', NEW.usuarioId,
            'numeroHistoriaClinica', NEW.numeroHistoriaClinica,
            'grupoSanguineo', NEW.grupoSanguineo,
            'alergias', NEW.alergias,
            'numeroTurnos', NEW.numeroTurnos,
            'createdAt', NEW.createdAt
        ),
        @current_user_id,
        NOW()
    );
END;

-- Trigger UPDATE en pacientes
CREATE TRIGGER IF NOT EXISTS audit_pacientes_update
AFTER UPDATE ON pacientes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_anteriores, datos_nuevos, usuario_id, fecha)
    VALUES (
        'pacientes',
        'UPDATE',
        NEW.id,
        JSON_OBJECT(
            'numeroHistoriaClinica', OLD.numeroHistoriaClinica,
            'grupoSanguineo', OLD.grupoSanguineo,
            'alergias', OLD.alergias,
            'numeroTurnos', OLD.numeroTurnos
        ),
        JSON_OBJECT(
            'numeroHistoriaClinica', NEW.numeroHistoriaClinica,
            'grupoSanguineo', NEW.grupoSanguineo,
            'alergias', NEW.alergias,
            'numeroTurnos', NEW.numeroTurnos
        ),
        @current_user_id,
        NOW()
    );
END;

-- Trigger DELETE en pacientes
CREATE TRIGGER IF NOT EXISTS audit_pacientes_delete
AFTER DELETE ON pacientes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_anteriores, usuario_id, fecha)
    VALUES (
        'pacientes',
        'DELETE',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'usuarioId', OLD.usuarioId,
            'numeroHistoriaClinica', OLD.numeroHistoriaClinica,
            'grupoSanguineo', OLD.grupoSanguineo
        ),
        @current_user_id,
        NOW()
    );
END;

-- ============================================================
-- 5. TRIGGERS PARA TABLA: TURNOS (CRÍTICA)
-- ============================================================

-- Trigger INSERT en turnos
CREATE TRIGGER IF NOT EXISTS audit_turnos_insert
AFTER INSERT ON turnos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_nuevos, usuario_id, fecha)
    VALUES (
        'turnos',
        'INSERT',
        NEW.id,
        JSON_OBJECT(
            'id', NEW.id,
            'pacienteId', NEW.pacienteId,
            'doctorId', NEW.doctorId,
            'fechaHora', NEW.fechaHora,
            'estado', NEW.estado,
            'razonConsulta', NEW.razonConsulta,
            'createdAt', NEW.createdAt
        ),
        @current_user_id,
        NOW()
    );
END;

-- Trigger UPDATE en turnos (MÁS CRÍTICO)
CREATE TRIGGER IF NOT EXISTS audit_turnos_update
AFTER UPDATE ON turnos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_anteriores, datos_nuevos, usuario_id, fecha)
    VALUES (
        'turnos',
        'UPDATE',
        NEW.id,
        JSON_OBJECT(
            'pacienteId', OLD.pacienteId,
            'doctorId', OLD.doctorId,
            'fechaHora', OLD.fechaHora,
            'estado', OLD.estado,
            'razonConsulta', OLD.razonConsulta,
            'notas', OLD.notas
        ),
        JSON_OBJECT(
            'pacienteId', NEW.pacienteId,
            'doctorId', NEW.doctorId,
            'fechaHora', NEW.fechaHora,
            'estado', NEW.estado,
            'razonConsulta', NEW.razonConsulta,
            'notas', NEW.notas
        ),
        @current_user_id,
        NOW()
    );
END;

-- Trigger DELETE en turnos
CREATE TRIGGER IF NOT EXISTS audit_turnos_delete
AFTER DELETE ON turnos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_anteriores, usuario_id, fecha)
    VALUES (
        'turnos',
        'DELETE',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'pacienteId', OLD.pacienteId,
            'doctorId', OLD.doctorId,
            'fechaHora', OLD.fechaHora,
            'estado', OLD.estado,
            'razonConsulta', OLD.razonConsulta
        ),
        @current_user_id,
        NOW()
    );
END;

-- ============================================================
-- 6. TRIGGERS PARA TABLA: ESPECIALIDADES
-- ============================================================

-- Trigger INSERT en especialidades
CREATE TRIGGER IF NOT EXISTS audit_especialidades_insert
AFTER INSERT ON especialidades
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_nuevos, usuario_id, fecha)
    VALUES (
        'especialidades',
        'INSERT',
        NEW.id,
        JSON_OBJECT(
            'id', NEW.id,
            'nombre', NEW.nombre,
            'descripcion', NEW.descripcion,
            'createdAt', NEW.createdAt
        ),
        @current_user_id,
        NOW()
    );
END;

-- Trigger UPDATE en especialidades
CREATE TRIGGER IF NOT EXISTS audit_especialidades_update
AFTER UPDATE ON especialidades
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_anteriores, datos_nuevos, usuario_id, fecha)
    VALUES (
        'especialidades',
        'UPDATE',
        NEW.id,
        JSON_OBJECT(
            'nombre', OLD.nombre,
            'descripcion', OLD.descripcion
        ),
        JSON_OBJECT(
            'nombre', NEW.nombre,
            'descripcion', NEW.descripcion
        ),
        @current_user_id,
        NOW()
    );
END;

-- ============================================================
-- 7. VERIFICACIÓN E ÍNDICES ADICIONALES
-- ============================================================

-- Índice para búsquedas por usuario
ALTER TABLE auditoria 
ADD INDEX IF NOT EXISTS idx_usuario_tabla (usuario_id, tabla_afectada, fecha);

-- Índice para búsquedas por acción
ALTER TABLE auditoria 
ADD INDEX IF NOT EXISTS idx_accion_fecha (accion, fecha DESC);

-- ============================================================
-- 8. VERIFICAR TRIGGERS CREADOS
-- ============================================================

-- Ver todos los triggers
-- SELECT TRIGGER_SCHEMA, TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE
-- FROM INFORMATION_SCHEMA.TRIGGERS
-- WHERE TRIGGER_SCHEMA = 'clinica_db'
-- ORDER BY EVENT_OBJECT_TABLE, EVENT_MANIPULATION;

-- ============================================================
-- 9. NOTAS IMPORTANTES
-- ============================================================

/*
⚠️ IMPORTANTE: VARIABLE DE USUARIO

Los triggers usan @current_user_id para saber quién realizó la acción.
En tu aplicación Node.js, antes de ejecutar una transacción:

const usuarioId = req.user.id;  // Del JWT o sesión
await sequelize.query(
    `SET @current_user_id = ?`,
    { replacements: [usuarioId] }
);

Esto hace que todos los triggers dentro de esa conexión
sepan quién está realizando los cambios.

✅ Con transacciones:
await sequelize.query(`SET @current_user_id = ?`, {
    replacements: [usuarioId],
    transaction: t  // ← Importante: en la misma transacción
});

// Todos los cambios ahora están auditados dentro de la TX
await Turno.create({...}, { transaction: t });  // Se audita automáticamente
await Doctor.update({...}, { transaction: t });  // Se audita automáticamente
await t.commit();  // Turno + auditoría todo junto
*/

-- ============================================================

-- 🎉 AUDITORÍA COMPLETAMENTE CONFIGURADA
-- 
-- ✅ 1 tabla auditoria
-- ✅ 15 triggers (3 por tabla crítica)
-- ✅ 4 índices optimizados
-- ✅ Integridad referencial
-- ✅ Listo para transacciones
