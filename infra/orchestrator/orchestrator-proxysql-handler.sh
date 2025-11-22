#!/bin/bash
# Script para que Orchestrator notifique a ProxySQL del nuevo Master.
set -e

# Parámetros pasados por Orchestrator
NEW_MASTER=$1
NEW_MASTER_PORT=$2

PROXYSQL_HOST="proxysql"
PROXYSQL_PORT=6032
PROXYSQL_USER="admin"
PROXYSQL_PASS="admin"

echo "INFO: Orchestrator detectó un Failover. Nuevo Master: ${NEW_MASTER}:${NEW_MASTER_PORT}"

# Conexión al puerto de administración de ProxySQL (6032)
mysql -u${PROXYSQL_USER} -p${PROXYSQL_PASS} -h${PROXYSQL_HOST} -P${PROXYSQL_PORT} <<EOF

-- 1. Mover todos los servidores al estado OFFLINE_SOFT temporalmente.
UPDATE mysql_servers SET status='OFFLINE_SOFT' WHERE hostgroup_id IN (10, 20);

-- 2. Mover el NUEVO Master (el servidor promovido) al grupo 10 (Escritura)
UPDATE mysql_servers SET hostgroup_id=10, status='ONLINE', weight=100 
WHERE hostname='${NEW_MASTER}' AND port=${NEW_MASTER_PORT};

-- 3. Mover el resto de servidores (las réplicas) al grupo 20 (Lectura)
-- Aquí movemos todos los nodos que no son el nuevo master a replicas (grupo 20).
-- Esto funciona si solo tienes un master y un set de replicas.
UPDATE mysql_servers SET hostgroup_id=20, status='ONLINE', weight=10 
WHERE hostname!='${NEW_MASTER}';

-- 4. Aplicar cambios
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;
EOF

echo "INFO: ProxySQL actualizado. El nuevo Master es ${NEW_MASTER} en el grupo 10."