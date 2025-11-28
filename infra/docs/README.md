# Tests - Proyecto Clínica

Colección de scripts de test para validar la infraestructura de la aplicación.

## Scripts Disponibles

### 1. `1_lead_test_read.sh` - Test de Lectura (Lead)
**Propósito:** Validar la lectura de datos desde la base de datos.

**Uso:**
```bash
./1_lead_test_read.sh
```

---

### 2. `2_failover_test.sh` - Test de Failover
**Propósito:** Validar el comportamiento del sistema ante fallos en los nodos.

**Uso:**
```bash
./2_failover_test.sh
```

---

### 3. `3_replication_test.sh` - Test de Replicación MySQL Master-Slave ✨ NUEVO

**Propósito:** Validar que la replicación MySQL entre Master y Slave funciona correctamente.

**Validaciones incluidas:**

#### 1️⃣ Estado del Master
- ✅ Conectividad al servidor Master
- ✅ Binary Log habilitado
- ✅ GTID (Global Transaction IDs) funcionando
- ✅ Estado actual del binary log

#### 2️⃣ Estado del Slave
- ✅ Conectividad al servidor Slave
- ✅ I/O thread activo (Slave_IO_Running)
- ✅ SQL thread activo (Slave_SQL_Running)
- ✅ Sincronización (Seconds_Behind_Master)

#### 3️⃣ Sincronización de Datos
- ✅ Mismo número de bases de datos
- ✅ Mismo número total de tablas

#### 4️⃣ Conectividad
- ✅ Usuario 'replica' existente en Master
- ✅ Comunicación entre contenedores (ping)

#### 5️⃣ Test Práctico de Replicación
- ✅ Crear base de datos de prueba en Master
- ✅ Verificar que se replica en Slave
- ✅ Crear tabla de prueba
- ✅ Insertar datos
- ✅ Verificar replicación de datos
- ✅ Validar datos específicos en Slave
- ✅ Limpiar datos (eliminar base de datos)
- ✅ Verificar eliminación replicada

**Uso:**
```bash
./3_replication_test.sh
```

**Output esperado:**
```
╔════════════════════════════════════════╗
║   TEST DE REPLICACIÓN MYSQL MASTER-SLAVE  ║
╚════════════════════════════════════════╝

[✓] Tests Pasados: 18
[✗] Tests Fallidos: 0

╔════════════════════════════════════════╗
║  ✓ REPLICACIÓN FUNCIONANDO CORRECTAMENTE ║
╚════════════════════════════════════════╝
```

**Configuración de contenedores:**
- Master: `mysql_master` (puerto 3306)
- Slave: `mysql_replica` (puerto 3306)
- Usuario de replicación: `replica_user`

---

### Pruebas de Carga / Flood Tests

#### `test_http_flood.sh` - Inundar con tráfico HTTP
```bash
./test_http_flood.sh
```

#### `test_syn_flood.sh` - Ataque SYN flood (pentesting)
```bash
./test_syn_flood.sh
```

#### `test_udp_flood.sh` - Inundar con tráfico UDP
```bash
./test_udp_flood.sh
```

---

## Cómo Ejecutar Todos los Tests

```bash
# Hacer todos los scripts ejecutables
chmod +x /opt/Proyecto-Clinica/tests/*.sh

# Ejecutar test de replicación (el más importante para validar DB)
./3_replication_test.sh

# Ejecutar test de lectura
./1_lead_test_read.sh

# Ejecutar test de failover
./2_failover_test.sh
```

---

## Interpretación de Resultados

### Test de Replicación - Estados Posibles

**✅ EXITOSO (18/18 tests pasados)**
```
✓ REPLICACIÓN FUNCIONANDO CORRECTAMENTE
```
- Master y Slave están sincronizados
- Datos se replican correctamente
- No hay errores

**⚠️ ADVERTENCIAS (Warnings)**
- `Master NO puede alcanzar Slave`: Normal si están en redes Docker diferentes
- `Usuario 'replica' no encontrado`: Verifica credenciales en la configuración
- Retraso > 5 segundos: Puede indicar carga de trabajo alta

**❌ ERRORES CRÍTICOS**
- `I/O thread NO está corriendo`: El Slave no puede conectar al Master
- `SQL thread NO está corriendo`: Error procesando eventos de replicación
- `Datos NO coinciden`: Los cambios no se están replicando correctamente
- `Slave conectado: NO`: Error de conectividad al Slave

---

## Troubleshooting

### El test de replicación falla

1. **Verificar que los contenedores están corriendo:**
   ```bash
   docker ps | grep -i mysql
   ```

2. **Ver logs del Master:**
   ```bash
   docker logs mysql_master | tail -30
   ```

3. **Ver logs del Slave:**
   ```bash
   docker logs mysql_replica | tail -30
   ```

4. **Verificar estado de replicación manual:**
   ```bash
   docker exec mysql_replica mysql -u root -proot -e "SHOW SLAVE STATUS\G"
   ```

5. **Verificar binary log del Master:**
   ```bash
   docker exec mysql_master mysql -u root -proot -e "SHOW MASTER STATUS\G"
   ```

---

## Notas Técnicas

- **Timeout para sincronización:** 5 segundos para BD, 3 segundos para datos
- **Formato de test:** Bash puro, no requiere dependencias adicionales
- **Limpieza:** El script elimina automáticamente datos de prueba
- **Seguridad:** Usa credenciales configuradas en el script (NO usar en producción sin encriptación)

---

## Próximas Mejoras

- [ ] Agregar validación de checksum de datos
- [ ] Agregar test de performance de replicación
- [ ] Agregar monitoreo de lag de replicación
- [ ] Generar reporte en JSON
- [ ] Integración con CI/CD (GitHub Actions)

---

**Última actualización:** 28 de noviembre de 2025  
**Versión:** 1.0
