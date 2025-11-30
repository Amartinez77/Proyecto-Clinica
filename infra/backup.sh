#!/bin/bash
# Script de backup automático de la base de datos Clínica
# Ejecutado diariamente por crontab

BACKUP_DIR="/opt/Proyecto-Clinica/infra/backups"
DOCKER_COMPOSE_FILE="/opt/Proyecto-Clinica/infra/docker-compose.mysql-cluster.yml"
BACKUP_DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/clinica_backup_$BACKUP_DATE.sql"

# Crear directorio si no existe
mkdir -p "$BACKUP_DIR"

# Realizar backup
cd /opt/Proyecto-Clinica/infra
docker compose -f "$DOCKER_COMPOSE_FILE" exec -T mysql_master mysqldump \
  -u root \
  -proot \
  --all-databases \
  --single-transaction \
  --quick \
  --lock-tables=false \
  > "$BACKUP_FILE" 2>&1

# Verificar si el backup fue exitoso
if [ $? -eq 0 ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ Backup exitoso: $BACKUP_FILE ($(du -h "$BACKUP_FILE" | cut -f1))" >> "$BACKUP_DIR/backup.log"
  
  # Mantener solo los últimos 7 backups (borrar backups más antiguos)
  find "$BACKUP_DIR" -name "clinica_backup_*.sql" -type f -mtime +7 -delete
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ Error en el backup" >> "$BACKUP_DIR/backup.log"
  exit 1
fi
