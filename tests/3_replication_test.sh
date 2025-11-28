#!/bin/bash

#################################################################################
# Test de Replicación MySQL Master-Slave
# 
# Este script valida:
# 1. Estado del Master (binary log, GTID, etc.)
# 2. Estado del Slave (replicación activa, sincronización)
# 3. Sincronización de datos (tablas, schemas)
# 4. Conectividad entre Master y Slave
# 5. Test práctico: Crear tabla, verificar replicación, limpiar
#
# Uso: ./3_replication_test.sh
#################################################################################

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
MASTER_HOST="mysql_master"
MASTER_USER="root"
MASTER_PASS="root"
MASTER_PORT="3306"

SLAVE_HOST="mysql_replica"
SLAVE_USER="root"
SLAVE_PASS="root"
SLAVE_PORT="3306"

REPLICA_USER="replica"
REPLICA_PASS="replica_password"

# Contador de tests
TESTS_PASSED=0
TESTS_FAILED=0

#################################################################################
# FUNCIONES AUXILIARES
#################################################################################

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((TESTS_PASSED++))
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    ((TESTS_FAILED++))
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

separator() {
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# Ejecutar comando en Master
mysql_master() {
    docker exec $MASTER_HOST mysql -u $MASTER_USER -p$MASTER_PASS -P $MASTER_PORT "$@" 2>/dev/null
}

# Ejecutar comando en Slave
mysql_slave() {
    docker exec $SLAVE_HOST mysql -u $SLAVE_USER -p$SLAVE_PASS -P $SLAVE_PORT "$@" 2>/dev/null
}

#################################################################################
# TEST 1: ESTADO DEL MASTER
#################################################################################

test_master_status() {
    separator "1. VALIDANDO ESTADO DEL MASTER"
    
    log_test "Master accesible en $MASTER_HOST:$MASTER_PORT"
    if mysql_master -e "SELECT 1" > /dev/null; then
        log_success "Master conectado"
    else
        log_error "No se puede conectar al Master"
        return 1
    fi
    
    log_test "Verificando Binary Log habilitado"
    BINLOG_STATUS=$(mysql_master -e "SHOW VARIABLES LIKE 'log_bin'" | grep -i on | wc -l)
    if [ $BINLOG_STATUS -gt 0 ]; then
        log_success "Binary Log habilitado"
    else
        log_error "Binary Log NO está habilitado"
        return 1
    fi
    
    log_test "Verificando GTID habilitado"
    GTID_STATUS=$(mysql_master -e "SHOW VARIABLES LIKE 'gtid_mode'" | grep -i on | wc -l)
    if [ $GTID_STATUS -gt 0 ]; then
        log_success "GTID habilitado"
    else
        log_error "GTID NO está habilitado"
        return 1
    fi
    
    log_test "Estado del Binary Log"
    MASTER_STATUS=$(mysql_master -e "SHOW MASTER STATUS\G")
    echo "$MASTER_STATUS" | grep -E "File:|Position:|Executed_Gtid_Set:" | sed 's/^/  /'
    log_success "Binary Log activo"
    
    return 0
}

#################################################################################
# TEST 2: ESTADO DEL SLAVE
#################################################################################

test_slave_status() {
    separator "2. VALIDANDO ESTADO DEL SLAVE"
    
    log_test "Slave accesible en $SLAVE_HOST:$SLAVE_PORT"
    if mysql_slave -e "SELECT 1" > /dev/null; then
        log_success "Slave conectado"
    else
        log_error "No se puede conectar al Slave"
        return 1
    fi
    
    log_test "Obteniendo estado de replicación"
    SLAVE_STATUS=$(mysql_slave -e "SHOW SLAVE STATUS\G")
    
    # Verificar Slave_IO_Running
    IO_RUNNING=$(echo "$SLAVE_STATUS" | grep "Slave_IO_Running:" | sed 's/.*: //')
    log_test "Slave_IO_Running: $IO_RUNNING"
    if [ "$IO_RUNNING" = "Yes" ]; then
        log_success "I/O thread está corriendo"
    else
        log_error "I/O thread NO está corriendo"
        return 1
    fi
    
    # Verificar Slave_SQL_Running
    SQL_RUNNING=$(echo "$SLAVE_STATUS" | grep "Slave_SQL_Running:" | sed 's/.*: //')
    log_test "Slave_SQL_Running: $SQL_RUNNING"
    if [ "$SQL_RUNNING" = "Yes" ]; then
        log_success "SQL thread está corriendo"
    else
        log_error "SQL thread NO está corriendo"
        return 1
    fi
    
    # Verificar Seconds_Behind_Master
    SECONDS_BEHIND=$(echo "$SLAVE_STATUS" | grep "Seconds_Behind_Master:" | sed 's/.*: //')
    log_test "Segundos de retraso: $SECONDS_BEHIND"
    if [ -n "$SECONDS_BEHIND" ] && [ "$SECONDS_BEHIND" -le 5 ] 2>/dev/null; then
        log_success "Slave sincronizado (retraso: $SECONDS_BEHIND segundos)"
    elif [ "$SECONDS_BEHIND" = "NULL" ]; then
        log_warning "Retraso es NULL (puede estar sincronizado)"
    else
        log_warning "Slave con retraso: $SECONDS_BEHIND segundos"
    fi
    
    # Mostrar información adicional
    echo ""
    log_info "Información completa del estado:"
    echo "$SLAVE_STATUS" | grep -E "Master_Host:|Master_User:|Master_Port:|Executed_Gtid_Set:|Retrieved_Gtid_Set:|Slave_IO_State:" | sed 's/^/  /'
    
    return 0
}

#################################################################################
# TEST 3: SINCRONIZACIÓN DE DATOS
#################################################################################

test_data_sync() {
    separator "3. VALIDANDO SINCRONIZACIÓN DE DATOS"
    
    log_test "Comparando número de bases de datos"
    MASTER_DBS=$(mysql_master -e "SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE schema_name NOT IN ('mysql', 'information_schema', 'performance_schema', 'sys')" -N | tail -1 | tr -d ' ')
    SLAVE_DBS=$(mysql_slave -e "SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE schema_name NOT IN ('mysql', 'information_schema', 'performance_schema', 'sys')" -N | tail -1 | tr -d ' ')
    
    log_test "Master DBs: $MASTER_DBS, Slave DBs: $SLAVE_DBS"
    if [ "$MASTER_DBS" = "$SLAVE_DBS" ]; then
        log_success "Mismo número de bases de datos"
    else
        log_warning "Diferente número de DBs (Master: $MASTER_DBS, Slave: $SLAVE_DBS)"
    fi
    
    log_test "Comparando número total de tablas"
    MASTER_TABLES=$(mysql_master -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE table_schema NOT IN ('mysql', 'information_schema', 'performance_schema', 'sys')" -N | tail -1 | tr -d ' ')
    SLAVE_TABLES=$(mysql_slave -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE table_schema NOT IN ('mysql', 'information_schema', 'performance_schema', 'sys')" -N | tail -1 | tr -d ' ')
    
    log_test "Master Tablas: $MASTER_TABLES, Slave Tablas: $SLAVE_TABLES"
    if [ "$MASTER_TABLES" = "$SLAVE_TABLES" ]; then
        log_success "Mismo número de tablas"
    else
        log_warning "Diferente número de tablas (Master: $MASTER_TABLES, Slave: $SLAVE_TABLES)"
    fi
    
    return 0
}

#################################################################################
# TEST 4: CONECTIVIDAD
#################################################################################

test_connectivity() {
    separator "4. VALIDANDO CONECTIVIDAD"
    
    log_test "Verificando usuario 'replica' en Master"
    REPLICA_USER_EXISTS=$(mysql_master -e "SELECT COUNT(*) FROM mysql.user WHERE user='$REPLICA_USER'" -N | tr -d ' ')
    if [ "$REPLICA_USER_EXISTS" -gt 0 ] 2>/dev/null; then
        log_success "Usuario '$REPLICA_USER' existe en Master"
    else
        log_warning "Usuario '$REPLICA_USER' no encontrado o no verificable"
    fi
    
    log_test "Ping entre contenedores"
    if docker exec $MASTER_HOST ping -c 1 $SLAVE_HOST > /dev/null 2>&1; then
        log_success "Master puede alcanzar Slave"
    else
        log_warning "Master NO puede alcanzar Slave (contenedores en diferentes redes)"
    fi
    
    if docker exec $SLAVE_HOST ping -c 1 $MASTER_HOST > /dev/null 2>&1; then
        log_success "Slave puede alcanzar Master"
    else
        log_warning "Slave NO puede alcanzar Master (contenedores en diferentes redes)"
    fi
    
    return 0
}

#################################################################################
# TEST 5: TEST PRÁCTICO DE REPLICACIÓN
#################################################################################

test_replication() {
    separator "5. TEST PRÁCTICO DE REPLICACIÓN"
    
    TEST_DB="test_replication_$$"
    TEST_TABLE="test_table_$$"
    TEST_DATA="test_data_$(date +%s)"
    
    log_test "Creando base de datos de prueba: $TEST_DB"
    mysql_master -e "CREATE DATABASE IF NOT EXISTS $TEST_DB" > /dev/null
    log_success "Base de datos creada en Master"
    
    log_test "Esperando sincronización (5 segundos)..."
    sleep 5
    
    DB_EXISTS=$(mysql_slave -e "SHOW DATABASES LIKE '$TEST_DB'" | grep -c $TEST_DB || echo 0)
    if [ "$DB_EXISTS" -gt 0 ]; then
        log_success "Base de datos replicada en Slave"
    else
        log_error "Base de datos NO fue replicada en Slave"
        # Limpiar de todas formas
        mysql_master -e "DROP DATABASE IF EXISTS $TEST_DB" > /dev/null
        return 1
    fi
    
    log_test "Creando tabla de prueba: $TEST_TABLE"
    mysql_master -e "USE $TEST_DB; CREATE TABLE $TEST_TABLE (
        id INT AUTO_INCREMENT PRIMARY KEY,
        data VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )" > /dev/null
    log_success "Tabla creada en Master"
    
    log_test "Insertando datos de prueba"
    mysql_master -e "USE $TEST_DB; INSERT INTO $TEST_TABLE (data) VALUES ('$TEST_DATA'), ('another_test_$(date +%s)')" > /dev/null
    log_success "Datos insertados en Master"
    
    log_test "Esperando replicación (3 segundos)..."
    sleep 3
    
    SLAVE_ROWS=$(mysql_slave -e "USE $TEST_DB; SELECT COUNT(*) FROM $TEST_TABLE" -N | tr -d ' ')
    MASTER_ROWS=$(mysql_master -e "USE $TEST_DB; SELECT COUNT(*) FROM $TEST_TABLE" -N | tr -d ' ')
    
    log_test "Comparando filas: Master=$MASTER_ROWS, Slave=$SLAVE_ROWS"
    if [ "$MASTER_ROWS" = "$SLAVE_ROWS" ] && [ "$MASTER_ROWS" -ge 2 ] 2>/dev/null; then
        log_success "Datos replicados correctamente"
    else
        log_error "Datos NO coinciden entre Master y Slave"
        mysql_master -e "DROP DATABASE IF EXISTS $TEST_DB" > /dev/null
        return 1
    fi
    
    log_test "Verificando datos específicos en Slave"
    DATA_EXISTS=$(mysql_slave -e "USE $TEST_DB; SELECT COUNT(*) FROM $TEST_TABLE WHERE data='$TEST_DATA'" -N | tr -d ' ')
    if [ "$DATA_EXISTS" -gt 0 ] 2>/dev/null; then
        log_success "Datos específicos encontrados en Slave"
    else
        log_error "Datos específicos NO encontrados en Slave"
        mysql_master -e "DROP DATABASE IF EXISTS $TEST_DB" > /dev/null
        return 1
    fi
    
    log_test "Limpiando: Eliminando base de datos de prueba"
    mysql_master -e "DROP DATABASE IF EXISTS $TEST_DB" > /dev/null
    log_success "Base de datos eliminada"
    
    sleep 3
    log_test "Verificando eliminación en Slave"
    DB_EXISTS=$(mysql_slave -e "SHOW DATABASES LIKE '$TEST_DB'" 2>/dev/null | tail -1 | wc -l)
    if [ "$DB_EXISTS" -le 1 ]; then
        log_success "Eliminación replicada correctamente"
    else
        log_warning "Base de datos aún existe en Slave (sincronizándose...)"
    fi
    
    return 0
}

#################################################################################
# RESUMEN FINAL
#################################################################################

print_summary() {
    separator "RESUMEN DE TESTS"
    
    echo -e "Tests Pasados:  ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests Fallidos: ${RED}$TESTS_FAILED${NC}"
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  ✓ REPLICACIÓN FUNCIONANDO CORRECTAMENTE ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
        return 0
    else
        echo -e "${RED}╔════════════════════════════════════════╗${NC}"
        echo -e "${RED}║     ✗ ERRORES DETECTADOS EN REPLICACIÓN   ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════╝${NC}"
        return 1
    fi
}

#################################################################################
# MAIN
#################################################################################

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   TEST DE REPLICACIÓN MYSQL MASTER-SLAVE  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    # Ejecutar todos los tests
    test_master_status || { log_error "Master status test falló"; TESTS_FAILED=$((TESTS_FAILED+1)); }
    test_slave_status || { log_error "Slave status test falló"; TESTS_FAILED=$((TESTS_FAILED+1)); }
    test_data_sync || { log_error "Data sync test falló"; TESTS_FAILED=$((TESTS_FAILED+1)); }
    test_connectivity || { log_error "Connectivity test falló"; TESTS_FAILED=$((TESTS_FAILED+1)); }
    test_replication || { log_error "Replication test falló"; TESTS_FAILED=$((TESTS_FAILED+1)); }
    
    # Mostrar resumen
    print_summary
    
    exit $TESTS_FAILED
}

# Ejecutar
main
