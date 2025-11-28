-- ============================================================================
-- QUERIES OPTIMIZADAS APROVECHANDO ÍNDICES
-- ============================================================================
-- Ejemplos de consultas que aprovechan los índices creados
-- Fecha: 17 de Noviembre de 2025
-- ============================================================================

-- ============================================================================
-- BÚSQUEDAS CRÍTICAS DE CITAS (Turnos)
-- ============================================================================

-- 1. PRÓXIMAS CITAS CONFIRMADAS (Usa: idx_estado_fechaHora)
-- Caso de uso: Mostrar próximas citas en el dashboard
SELECT 
  t.id,
  t.fechaHora,
  p.id as paciente_id,
  CONCAT(u.nombre, ' ', u.apellido) as paciente_nombre,
  d.id as doctor_id,
  CONCAT(ud.nombre, ' ', ud.apellido) as doctor_nombre,
  e.nombre as especialidad
FROM turnos t
JOIN pacientes p ON t.pacienteId = p.id
JOIN usuarios u ON p.usuario_id = u.id
JOIN doctores d ON t.doctorId = d.id
JOIN usuarios ud ON d.usuario_id = ud.id
JOIN especialidades e ON d.especialidadId = e.id
WHERE t.estado = 'confirmado' 
  AND t.fechaHora >= NOW()
ORDER BY t.fechaHora ASC
LIMIT 10;

-- 2. AGENDA DEL DOCTOR (Usa: idx_doctor_fecha_hora)
-- Caso de uso: Mostrar agenda del doctor para el día/semana
SELECT 
  t.id,
  t.fechaHora,
  p.id as paciente_id,
  CONCAT(u.nombre, ' ', u.apellido) as paciente_nombre,
  t.estado,
  t.razonConsulta
FROM turnos t
JOIN pacientes p ON t.pacienteId = p.id
JOIN usuarios u ON p.usuario_id = u.id
WHERE t.doctorId = 1 
  AND DATE(t.fechaHora) = CURDATE()
ORDER BY t.fechaHora ASC;

-- 3. CITAS DEL PACIENTE (Usa: idx_paciente_fecha_hora)
-- Caso de uso: Mostrar citas del paciente
SELECT 
  t.id,
  t.fechaHora,
  CONCAT(ud.nombre, ' ', ud.apellido) as doctor_nombre,
  e.nombre as especialidad,
  t.estado
FROM turnos t
JOIN doctores d ON t.doctorId = d.id
JOIN usuarios ud ON d.usuario_id = ud.id
JOIN especialidades e ON d.especialidadId = e.id
WHERE t.pacienteId = 5
ORDER BY t.fechaHora DESC;

-- ============================================================================
-- BÚSQUEDAS DE DISPONIBILIDAD (Doctores)
-- ============================================================================

-- 4. DOCTORES DISPONIBLES POR ESPECIALIDAD (Usa: idx_estado_especialidad)
-- Caso de uso: Listar doctores activos de una especialidad
SELECT 
  d.id,
  CONCAT(u.nombre, ' ', u.apellido) as doctor,
  e.nombre as especialidad,
  d.precioConsulta,
  d.telefono
FROM doctores d
JOIN usuarios u ON d.usuario_id = u.id
JOIN especialidades e ON d.especialidadId = e.id
WHERE d.estado = 'activo' 
  AND d.especialidadId = 1
ORDER BY d.precioConsulta ASC;

-- 5. BÚSQUEDA DE DOCTOR POR MATRÍCULA (Usa: idx_matricula UNIQUE)
-- Caso de uso: Validar matrícula profesional
SELECT 
  d.id,
  CONCAT(u.nombre, ' ', u.apellido) as doctor,
  d.matricula,
  e.nombre as especialidad,
  d.estado
FROM doctores d
JOIN usuarios u ON d.usuario_id = u.id
JOIN especialidades e ON d.especialidadId = e.id
WHERE d.matricula = 'MAT001';

-- ============================================================================
-- BÚSQUEDAS DE AUTENTICACIÓN Y SEGURIDAD (Usuarios)
-- ============================================================================

-- 6. BÚSQUEDA POR EMAIL (Usa: idx_email)
-- Caso de uso: Login de usuario
SELECT 
  id,
  nombre,
  apellido,
  email,
  tipo,
  rol,
  password
FROM usuarios
WHERE email = 'dr.perez@ejemplo.com';

-- 7. BÚSQUEDA POR DNI (Usa: idx_dni)
-- Caso de uso: Identificación de usuario
SELECT 
  id,
  nombre,
  apellido,
  dni,
  tipo,
  email
FROM usuarios
WHERE dni = '12345678';

-- ============================================================================
-- BÚSQUEDAS MÉDICAS (Pacientes)
-- ============================================================================

-- 8. PACIENTES POR GRUPO SANGUÍNEO (Usa: idx_grupoSanguineo)
-- Caso de uso: Emergencia - buscar donantes o compatibilidad
SELECT 
  p.id,
  CONCAT(u.nombre, ' ', u.apellido) as paciente,
  p.grupoSanguineo,
  p.telefono,
  p.contactoEmergencia,
  p.telefonoContacto
FROM pacientes p
JOIN usuarios u ON p.usuario_id = u.id
WHERE p.grupoSanguineo = 'O+';

-- 9. VALIDACIÓN DE SEGURIDAD SOCIAL (Usa: idx_numeroSeguridadSocial)
-- Caso de uso: Verificar cobertura
SELECT 
  p.id,
  CONCAT(u.nombre, ' ', u.apellido) as paciente,
  p.numeroSeguridadSocial,
  p.numeroAfiliado
FROM pacientes p
JOIN usuarios u ON p.usuario_id = u.id
WHERE p.numeroSeguridadSocial = 'SSN123456';

-- 10. VERIFICACIÓN DE PREPAGA (Usa: idx_numeroAfiliado)
-- Caso de uso: Validación de plan de salud
SELECT 
  p.id,
  CONCAT(u.nombre, ' ', u.apellido) as paciente,
  p.numeroAfiliado,
  p.grupoSanguineo
FROM pacientes p
JOIN usuarios u ON p.usuario_id = u.id
WHERE p.numeroAfiliado = 'AFIL123456';

-- ============================================================================
-- REPORTES Y ESTADÍSTICAS (Usa índices compuestos)
-- ============================================================================

-- 11. CITAS PENDIENTES POR PACIENTE (Usa: idx_paciente_estado)
-- Caso de uso: Recordatorio de citas pendientes
SELECT 
  p.id as paciente_id,
  CONCAT(u.nombre, ' ', u.apellido) as paciente,
  u.email,
  COUNT(*) as citas_pendientes
FROM turnos t
JOIN pacientes p ON t.pacienteId = p.id
JOIN usuarios u ON p.usuario_id = u.id
WHERE t.estado = 'pendiente'
GROUP BY p.id, u.nombre, u.apellido, u.email
HAVING citas_pendientes > 0;

-- 12. ESTADÍSTICAS DE DOCTOR (Usa: idx_doctor_estado)
-- Caso de uso: Auditoría médica - citas completadas
SELECT 
  d.id,
  CONCAT(u.nombre, ' ', u.apellido) as doctor,
  e.nombre as especialidad,
  COUNT(CASE WHEN t.estado = 'completado' THEN 1 END) as citas_completadas,
  COUNT(CASE WHEN t.estado = 'cancelado' THEN 1 END) as citas_canceladas,
  COUNT(*) as total_citas
FROM doctores d
JOIN usuarios u ON d.usuario_id = u.id
JOIN especialidades e ON d.especialidadId = e.id
LEFT JOIN turnos t ON d.id = t.doctorId
GROUP BY d.id, u.nombre, u.apellido, e.nombre;

-- 13. HISTORIAL DOCTOR-PACIENTE (Usa: idx_paciente_doctor)
-- Caso de uso: Ver historial de consultas entre un doctor y paciente
SELECT 
  t.id,
  t.fechaHora,
  t.estado,
  t.razonConsulta,
  t.notas
FROM turnos t
WHERE t.pacienteId = 5 
  AND t.doctorId = 1
ORDER BY t.fechaHora DESC;

-- 14. REPORTES POR PERÍODO (Usa: idx_fechaHora)
-- Caso de uso: Estadísticas semanales/mensuales
SELECT 
  DATE(t.fechaHora) as fecha,
  COUNT(*) as total_citas,
  COUNT(CASE WHEN t.estado = 'confirmado' THEN 1 END) as confirmadas,
  COUNT(CASE WHEN t.estado = 'completado' THEN 1 END) as completadas,
  COUNT(CASE WHEN t.estado = 'cancelado' THEN 1 END) as canceladas
FROM turnos t
WHERE t.fechaHora BETWEEN '2025-11-20' AND '2025-11-30'
GROUP BY DATE(t.fechaHora)
ORDER BY fecha DESC;

-- ============================================================================
-- BÚSQUEDAS CON FILTROS (Usa: idx_tipo)
-- ============================================================================

-- 15. LISTAR TODOS LOS DOCTORES (Usa: idx_tipo)
-- Caso de uso: Gestión de personal
SELECT 
  u.id,
  CONCAT(u.nombre, ' ', u.apellido) as doctor,
  u.email,
  d.matricula,
  d.estado,
  e.nombre as especialidad
FROM usuarios u
JOIN doctores d ON u.id = d.usuario_id
JOIN especialidades e ON d.especialidadId = e.id
WHERE u.tipo = 'doctor'
ORDER BY u.nombre;

-- 16. LISTAR TODOS LOS PACIENTES (Usa: idx_tipo)
-- Caso de uso: Gestión de pacientes
SELECT 
  u.id,
  CONCAT(u.nombre, ' ', u.apellido) as paciente,
  u.email,
  p.telefono,
  p.grupoSanguineo
FROM usuarios u
JOIN pacientes p ON u.id = p.usuario_id
WHERE u.tipo = 'paciente'
ORDER BY u.nombre;

-- ============================================================================
-- AUDITORÍA Y BÚSQUEDAS TEMPORALES (Usa: idx_createdAt)
-- ============================================================================

-- 17. DOCTORES REGISTRADOS EN PERÍODO (Usa: idx_createdAt en doctores)
-- Caso de uso: Auditoría - doctores nuevos
SELECT 
  d.id,
  CONCAT(u.nombre, ' ', u.apellido) as doctor,
  d.createdAt,
  e.nombre as especialidad
FROM doctores d
JOIN usuarios u ON d.usuario_id = u.id
JOIN especialidades e ON d.especialidadId = e.id
WHERE d.createdAt >= '2025-11-01'
ORDER BY d.createdAt DESC;

-- 18. PACIENTES REGISTRADOS EN PERÍODO (Usa: idx_createdAt en pacientes)
-- Caso de uso: Auditoría - pacientes nuevos
SELECT 
  p.id,
  CONCAT(u.nombre, ' ', u.apellido) as paciente,
  p.createdAt,
  u.email
FROM pacientes p
JOIN usuarios u ON p.usuario_id = u.id
WHERE p.createdAt >= '2025-11-01'
ORDER BY p.createdAt DESC;

-- 19. TURNOS CREADOS EN PERÍODO (Usa: idx_createdAt en turnos)
-- Caso de uso: Auditoría - citas agendadas
SELECT 
  t.id,
  t.createdAt,
  t.fechaHora,
  CONCAT(u.nombre, ' ', u.apellido) as paciente,
  CONCAT(ud.nombre, ' ', ud.apellido) as doctor
FROM turnos t
JOIN pacientes p ON t.pacienteId = p.id
JOIN usuarios u ON p.usuario_id = u.id
JOIN doctores d ON t.doctorId = d.id
JOIN usuarios ud ON d.usuario_id = ud.id
WHERE t.createdAt >= '2025-11-01'
ORDER BY t.createdAt DESC;

-- ============================================================================
-- CONSULTAS CON JOINS COMPLEJOS (Aprovecha múltiples índices)
-- ============================================================================

-- 20. VISTA COMPLETA DE CITA (Usa todos los índices disponibles)
-- Caso de uso: Detalle de cita
SELECT 
  t.id as cita_id,
  t.fechaHora,
  t.estado,
  t.razonConsulta,
  t.notas,
  -- Información del paciente
  p.id as paciente_id,
  CONCAT(u.nombre, ' ', u.apellido) as paciente_nombre,
  u.email as paciente_email,
  p.telefono as paciente_telefono,
  p.grupoSanguineo,
  p.alergias,
  p.medicamentos,
  -- Información del doctor
  d.id as doctor_id,
  CONCAT(ud.nombre, ' ', ud.apellido) as doctor_nombre,
  ud.email as doctor_email,
  d.matricula,
  d.precioConsulta,
  -- Información de especialidad
  e.nombre as especialidad
FROM turnos t
JOIN pacientes p ON t.pacienteId = p.id
JOIN usuarios u ON p.usuario_id = u.id
JOIN doctores d ON t.doctorId = d.id
JOIN usuarios ud ON d.usuario_id = ud.id
JOIN especialidades e ON d.especialidadId = e.id
WHERE t.id = 1;

-- ============================================================================
-- NOTAS SOBRE OPTIMIZACIÓN
-- ============================================================================

/*

ORDEN DE EJECUCIÓN DE ÍNDICES EN QUERIES:

1. WHERE con igualdad (=): Los índices se usan PRIMERO
   WHERE estado='confirmado' → Usa idx_estado
   WHERE doctorId=1 → Usa idx_doctorId

2. WHERE con compuesto: Los índices compuestos son ÓPTIMOS
   WHERE estado='confirmado' AND fechaHora >= NOW()
   → Usa idx_estado_fechaHora (compuesto)

3. ORDER BY: Los índices pueden acelerar ordenamiento
   ORDER BY fechaHora → Puede usar idx_fechaHora si está primero en WHERE

4. Límites: LIMIT funciona DESPUÉS de obtener resultados
   → Los índices aceleran la búsqueda, no el LIMIT

EXPLICAR PLAN DE EJECUCIÓN:
Para ver si se usa un índice, ejecuta:
EXPLAIN SELECT ... (tu query)

Busca en el resultado:
- key: El índice usado (NULL = tabla completa)
- rows: Estimación de filas a revisar (más bajo = mejor)
- type: Tipo de acceso (const < eq_ref < ref < range < index < ALL)

EJEMPLO:
EXPLAIN SELECT * FROM turnos WHERE estado='confirmado' AND fechaHora >= NOW();

*/

-- ============================================================================
-- Última actualización: 17 de Noviembre de 2025
-- Estado: ✓ Todas las queries optimizadas
-- ============================================================================
