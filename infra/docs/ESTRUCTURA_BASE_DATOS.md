# Estructura de Base de Datos - CLINICA_DB

**Fecha:** 17 de Noviembre de 2025  
**Base de Datos:** clinica_db  
**Motor:** MySQL 8.0  
**Charset:** utf8mb4 (Unicode completo con acentos)  
**Collation:** utf8mb4_unicode_ci

---

## 📊 Diagrama Entidad-Relación

```
┌─────────────────────────────────────┐
│          USUARIOS (PADRE)           │
├─────────────────────────────────────┤
│ id (BIGINT UNSIGNED, PK)            │
│ dni, email, password                │
│ nombre, apellido                    │
│ tipo (ENUM)                         │
│ rol (VARCHAR)                       │
│ createdAt, updatedAt                │
└─────────────────────────────────────┘
         ▲                    ▲
         │ 1:1                │ 1:1
         │                    │
    ┌────┴────────────┐      ┌┴──────────────┐
    │                 │      │                │
    ▼                 ▼      ▼                ▼
┌─────────────┐  ┌──────────────┐    ┌─────────────────┐
│  DOCTORES   │  │  PACIENTES   │    │ ESPECIALIDADES  │
├─────────────┤  ├──────────────┤    ├─────────────────┤
│ id (PK)     │  │ id (PK)      │    │ id (PK)         │
│ usuario_id  │  │ usuario_id   │    │ nombre (UNI)    │
│ matricula   │  │ telefono     │    │ descripcion     │
│ ...         │  │ ...          │    │ createdAt, etc  │
│ especial... │──→ N:1 relation │    │                 │
└─────────────┘  └──────────────┘    └─────────────────┘
      │                    │
      │ 1:N                │ 1:N
      │                    │
      └────────┬───────────┘
               ▼
         ┌──────────────┐
         │   TURNOS     │
         ├──────────────┤
         │ id (PK)      │
         │ pacienteId   │
         │ doctorId     │
         │ fechaHora    │
         │ estado       │
         │ ...          │
         └──────────────┘
```

---

## 📋 Tablas Detalladas

### 1. TABLA: `usuarios`

**Descripción:** Tabla padre que almacena todos los usuarios del sistema (administrativos, doctores y pacientes).

**Tipo de Relación:** Tabla padre (1:1 hacia doctores y pacientes)

| Campo | Tipo | Nullable | PK | UNI | Default | Descripción |
|-------|------|----------|----|----|---------|-------------|
| `id` | BIGINT UNSIGNED | NO | ✓ | | AUTO_INCREMENT | Identificador único del usuario |
| `dni` | VARCHAR(32) | YES | | | NULL | Documento de identidad (DNI) |
| `email` | VARCHAR(255) | YES | | | NULL | Correo electrónico (validado con formato email) |
| `password` | VARCHAR(255) | YES | | | NULL | Contraseña encriptada (bcrypt) |
| `nombre` | VARCHAR(100) | YES | | | NULL | Nombre del usuario |
| `apellido` | VARCHAR(100) | YES | | | NULL | Apellido del usuario |
| `tipo` | ENUM('paciente','doctor','admin') | NO | | | NULL | Tipo de usuario en el sistema |
| `rol` | VARCHAR(50) | NO | | | NULL | Rol específico (admin, doctor, paciente) |
| `createdAt` | DATETIME | NO | | | NULL | Fecha de creación del registro |
| `updatedAt` | DATETIME | NO | | | NULL | Fecha de última actualización |

**Restricciones:**
- `id` es PRIMARY KEY con AUTO_INCREMENT
- `tipo` debe ser uno de los valores del ENUM (no puede ser NULL)
- `rol` debe ser un valor no vacío (NOT NULL)
- Charset: utf8mb4 para soportar acentos

**Datos Actuales:**
- 7 registros totales
- 1 administrador (tipo='admin', rol='admin')
- 3 doctores (tipo='doctor', rol='doctor')
- 3 pacientes (tipo='paciente', rol='paciente')

---

### 2. TABLA: `especialidades`

**Descripción:** Catálogo de especialidades médicas disponibles en la clínica.

**Tipo de Relación:** Tabla padre (1:N hacia doctores)

| Campo | Tipo | Nullable | PK | UNI | Default | Descripción |
|-------|------|----------|----|----|---------|-------------|
| `id` | INT | NO | ✓ | | AUTO_INCREMENT | Identificador único de especialidad |
| `nombre` | VARCHAR(255) | NO | | ✓ | NULL | Nombre de la especialidad (único) |
| `descripcion` | TEXT | YES | | | NULL | Descripción detallada de la especialidad |
| `_version` | INT | YES | | | 0 | Control de versión (legacy, no usado) |
| `createdAt` | DATETIME | NO | | | NULL | Fecha de creación |
| `updatedAt` | DATETIME | NO | | | NULL | Fecha de última actualización |

**Restricciones:**
- `id` es PRIMARY KEY con AUTO_INCREMENT
- `nombre` tiene UNIQUE constraint (no puede haber especialidades duplicadas)
- Charset: utf8mb4

**Datos Actuales:**
```
1. Cardiología - Especialidad del corazón
2. Dermatología - Especialidad de la piel
3. Neurología - Especialidad del sistema nervioso
4. Pediatría - Especialidad en niños
5. Traumatología - Especialidad en huesos y articulaciones
```

---

### 3. TABLA: `doctores`

**Descripción:** Información específica de los doctores que trabajan en la clínica.

**Tipo de Relación:** Tabla intermedia (FK hacia usuarios y especialidades, 1:N hacia turnos)

| Campo | Tipo | Nullable | PK | UNI | Default | Descripción |
|-------|------|----------|----|----|---------|-------------|
| `id` | INT | NO | ✓ | | AUTO_INCREMENT | Identificador único del doctor |
| `usuario_id` | BIGINT UNSIGNED | NO | | ✓ | NULL | **FK** → usuarios.id (relación 1:1) |
| `especialidadId` | INT | NO | | | NULL | **FK** → especialidades.id (relación N:1) |
| `matricula` | VARCHAR(255) | NO | | ✓ | NULL | Número de matrícula profesional (único) |
| `precioConsulta` | DECIMAL(10,2) | NO | | | 0.00 | Precio de la consulta en moneda local |
| `telefono` | VARCHAR(15) | NO | | | NULL | Número de teléfono del doctor |
| `estado` | ENUM('activo','inactivo') | YES | | | 'activo' | Estado del doctor en el sistema |
| `disponibilidad` | JSON | YES | | | NULL | Horarios de disponibilidad (formato JSON) |
| `createdAt` | DATETIME | NO | | | NULL | Fecha de creación |
| `updatedAt` | DATETIME | NO | | | NULL | Fecha de última actualización |

**Restricciones:**
- `id` es PRIMARY KEY con AUTO_INCREMENT
- `usuario_id` tiene UNIQUE constraint (cada doctor está asociado a un único usuario)
- `usuario_id` es FK que referencia `usuarios.id` (NOT NULL)
- `especialidadId` es FK que referencia `especialidades.id` (NOT NULL)
- `matricula` es UNIQUE (no puede haber matriculas duplicadas)

**Índices:**
- `usuario_id` (UNIQUE KEY)
- `especialidadId` (MULTIPLE KEY para búsquedas)
- `matricula` (UNIQUE KEY)

**Datos Actuales:**
```
1. Dr. Juan Pérez (usuario_id=2) - Cardiología - MAT001 - $150.00/consulta
2. Dra. María García (usuario_id=3) - Dermatología - MAT002 - $150.00/consulta
3. Dr. Carlos López (usuario_id=4) - Neurología - MAT003 - $150.00/consulta
```

---

### 4. TABLA: `pacientes`

**Descripción:** Información específica de los pacientes registrados en la clínica.

**Tipo de Relación:** Tabla intermedia (FK hacia usuarios, 1:N hacia turnos)

| Campo | Tipo | Nullable | PK | UNI | Default | Descripción |
|-------|------|----------|----|----|---------|-------------|
| `id` | INT | NO | ✓ | | AUTO_INCREMENT | Identificador único del paciente |
| `usuario_id` | BIGINT UNSIGNED | NO | | ✓ | NULL | **FK** → usuarios.id (relación 1:1) |
| `telefono` | VARCHAR(15) | NO | | | NULL | Número de teléfono del paciente |
| `fechaNacimiento` | DATETIME | NO | | | NULL | Fecha de nacimiento del paciente |
| `numeroSeguridadSocial` | VARCHAR(255) | YES | | | NULL | Número de seguridad social |
| `numeroAfiliado` | VARCHAR(255) | YES | | | NULL | Número de afiliado a prepaga/obra social |
| `grupoSanguineo` | ENUM('O+','O-','A+','A-','B+','B-','AB+','AB-') | YES | | | NULL | Grupo sanguíneo del paciente |
| `alergias` | TEXT | YES | | | NULL | Descripción de alergias conocidas |
| `enfermedadesCronicas` | TEXT | YES | | | NULL | Listado de enfermedades crónicas |
| `medicamentos` | TEXT | YES | | | NULL | Medicamentos que toma actualmente |
| `contactoEmergencia` | VARCHAR(255) | YES | | | NULL | Nombre del contacto de emergencia |
| `telefonoContacto` | VARCHAR(255) | YES | | | NULL | Teléfono del contacto de emergencia |
| `uid_firebase` | VARCHAR(255) | YES | | | NULL | UID de Firebase (para autenticación) |
| `createdAt` | DATETIME | NO | | | NULL | Fecha de creación |
| `updatedAt` | DATETIME | NO | | | NULL | Fecha de última actualización |

**Restricciones:**
- `id` es PRIMARY KEY con AUTO_INCREMENT
- `usuario_id` tiene UNIQUE constraint (cada paciente está asociado a un único usuario)
- `usuario_id` es FK que referencia `usuarios.id` (NOT NULL)
- Campos de información médica son opcionales (nullable)

**Índices:**
- `usuario_id` (UNIQUE KEY)

**Datos Actuales:**
```
1. Ana Rodríguez (usuario_id=5) - Nac: 1985-03-15 - Tel: 5551234567
2. Luis Martínez (usuario_id=6) - Nac: 1992-07-22 - Tel: 5559876543
3. Rosa González (usuario_id=7) - Nac: 1988-11-10 - Tel: 5552468135
```

---

### 5. TABLA: `turnos`

**Descripción:** Registro de citas médicas entre pacientes y doctores.

**Tipo de Relación:** Tabla intermedia (FK hacia pacientes y doctores)

| Campo | Tipo | Nullable | PK | UNI | Default | Descripción |
|-------|------|----------|----|----|---------|-------------|
| `id` | INT | NO | ✓ | | AUTO_INCREMENT | Identificador único del turno |
| `pacienteId` | INT | NO | | | NULL | **FK** → pacientes.id (relación N:1) |
| `doctorId` | INT | NO | | | NULL | **FK** → doctores.id (relación N:1) |
| `fechaHora` | DATETIME | NO | | | NULL | Fecha y hora de la cita |
| `razonConsulta` | TEXT | YES | | | NULL | Motivo o razón de la consulta |
| `estado` | ENUM('pendiente','confirmado','completado','cancelado') | YES | | | 'pendiente' | Estado actual del turno |
| `notas` | TEXT | YES | | | NULL | Notas adicionales del turno |
| `createdAt` | DATETIME | NO | | | NULL | Fecha de creación |
| `updatedAt` | DATETIME | NO | | | NULL | Fecha de última actualización |

**Restricciones:**
- `id` es PRIMARY KEY con AUTO_INCREMENT
- `pacienteId` es FK que referencia `pacientes.id` (NOT NULL)
- `doctorId` es FK que referencia `doctores.id` (NOT NULL)
- `estado` es un ENUM con valores fijos (default: 'pendiente')

**Índices:**
- `pacienteId` (MULTIPLE KEY)
- `doctorId` (MULTIPLE KEY)
- `estado` (MULTIPLE KEY para búsquedas)

**Datos Actuales:**
```
1. Ana (Paciente 1) → Dr. Juan Pérez - 2025-11-20 10:00:00 [confirmado]
2. Ana (Paciente 1) → Dra. María García - 2025-11-21 14:00:00 [confirmado]
3. Luis (Paciente 2) → Dr. Juan Pérez - 2025-11-22 11:00:00 [confirmado]
4. Rosa (Paciente 3) → Dr. Carlos López - 2025-11-23 15:00:00 [confirmado]
```

---

## 🔗 Relaciones (Foreign Keys)

### Definidas en la BD:

| FK Name | Tabla | Columna | Referencia | Relación | Acción |
|---------|-------|---------|-----------|----------|--------|
| `doctores_ibfk_1` | doctores | usuario_id | usuarios.id | N:1 | RESTRICT |
| `doctores_ibfk_2` | doctores | especialidadId | especialidades.id | N:1 | RESTRICT |
| `pacientes_ibfk_1` | pacientes | usuario_id | usuarios.id | N:1 | RESTRICT |
| `turnos_ibfk_1` | turnos | pacienteId | pacientes.id | N:1 | RESTRICT |
| `turnos_ibfk_2` | turnos | doctorId | doctores.id | N:1 | RESTRICT |

### Diagrama de Relaciones:

```
USUARIOS (1) ──────────┬─────────────┐
                       │ 1:1         │ 1:1
                       ▼             ▼
                   DOCTORES     PACIENTES
                       │             │
                       │ 1:N         │ 1:N
                       └──────┬──────┘
                              ▼
                           TURNOS

ESPECIALIDADES (1) ──────┐
                         │ 1:N
                         ▼
                     DOCTORES
```

### Validaciones de Integridad:

- ✓ Todos los doctores (3/3) tienen usuario_id válido
- ✓ Todos los doctores (3/3) tienen especialidadId válido
- ✓ Todos los pacientes (3/3) tienen usuario_id válido
- ✓ Todos los turnos (4/4) tienen pacienteId válido
- ✓ Todos los turnos (4/4) tienen doctorId válido
- ✓ No hay registros huérfanos
- ✓ Todas las FK son válidas

---

## 📈 Estadísticas

| Tabla | Registros | PK | FK | UNI | Índices |
|-------|-----------|----|----|-----|---------|
| usuarios | 7 | 1 | 0 | 0 | 1 (id) |
| especialidades | 5 | 1 | 0 | 1 | 2 (id, nombre) |
| doctores | 3 | 1 | 2 | 2 | 3 (id, usuario_id, matricula) |
| pacientes | 3 | 1 | 1 | 1 | 2 (id, usuario_id) |
| turnos | 4 | 1 | 2 | 0 | 3 (id, pacienteId, doctorId) |
| **TOTAL** | **22** | **5** | **5** | **4** | **11** |

---

## 🔑 Primary Keys

| Tabla | PK | Tipo | Auto-Increment |
|-------|----|----|---|
| usuarios | id | BIGINT UNSIGNED | ✓ |
| especialidades | id | INT | ✓ |
| doctores | id | INT | ✓ |
| pacientes | id | INT | ✓ |
| turnos | id | INT | ✓ |

**Nota:** Los IDs se generan automáticamente al insertar nuevos registros.

---

## 🗃️ Características Especiales

### 1. **Timestamps Automáticos**
Todas las tablas incluyen campos `createdAt` y `updatedAt` que se gestionan automáticamente:
- `createdAt`: Se establece al crear el registro
- `updatedAt`: Se actualiza automáticamente en cada modificación

### 2. **Codificación de Caracteres**
- **Charset:** utf8mb4 (soporta Unicode completo incluyendo emoji)
- **Collation:** utf8mb4_unicode_ci (comparación insensible a mayúsculas/minúsculas)
- **Beneficio:** Soporta perfectamente acentos españoles (á, é, í, ó, ú, ñ)

### 3. **Tipos de Datos Especiales**

#### ENUM Fields
- `usuarios.tipo`: 'paciente', 'doctor', 'admin'
- `doctores.estado`: 'activo', 'inactivo'
- `turnos.estado`: 'pendiente', 'confirmado', 'completado', 'cancelado'
- `pacientes.grupoSanguineo`: 'O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'

#### JSON Fields
- `doctores.disponibilidad`: Horarios en formato JSON (flexible, sin esquema fijo)

#### DECIMAL Fields
- `doctores.precioConsulta`: DECIMAL(10,2) para precisión monetaria (hasta $9,999,999.99)

---

## 📝 Notas Importantes

### Relación Usuarios → Doctores/Pacientes
- Es una relación **1:1** mediante UNIQUE constraint en `usuario_id`
- Un usuario puede ser SOLO doctor O SOLO paciente, nunca ambos
- El campo `tipo` en usuarios define la categoría
- El campo `rol` en usuarios especifica el rol exacto

### Validaciones
- El campo `rol` NO puede ser NULL (obligatorio)
- El campo `tipo` NO puede ser NULL (obligatorio)
- Ambos deben estar sincronizados (tipo='doctor' → rol='doctor')

### Escalabilidad
- Los IDs UNSIGNED permiten hasta 4.2 billones de registros
- Las FK previenen eliminaciones huérfanas
- Los índices optimizan búsquedas por usuario, especialidad y estado

---

## 🔄 Flujo de Datos Típico

```
1. ADMIN crea USUARIO (tipo='doctor', rol='doctor')
   ↓
2. Se crea registro en DOCTORES (usuario_id=X, especialidadId=Y)
   ↓
3. ADMIN asigna ESPECIALIDAD al DOCTOR
   ↓
4. PACIENTE se registra como USUARIO (tipo='paciente', rol='paciente')
   ↓
5. Se crea registro en PACIENTES (usuario_id=Z)
   ↓
6. PACIENTE solicita TURNO con un DOCTOR
   ↓
7. Se crea registro en TURNOS (pacienteId=A, doctorId=B)
   ↓
8. DOCTOR atiende TURNO y cambia estado a 'completado'
```

---

**Última actualización:** 17 de Noviembre de 2025  
**Estado:** ✓ Base de datos operativa y validada
