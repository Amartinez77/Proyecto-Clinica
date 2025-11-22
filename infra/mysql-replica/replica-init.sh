#!/bin/bash
set -e

echo "Waiting for Master to be ready..."
# Usar un bucle de espera es más robusto

# Esperar unos segundos para asegurar que el Master esté listo
sleep 20 

mysql -uroot -proot -h 127.0.0.1 <<EOF
  # Iniciar el proceso de replicación
  CHANGE REPLICATION SOURCE TO 
    SOURCE_HOST='mysql_master', 
    SOURCE_USER='replica_user', 
    SOURCE_PASSWORD='replica_password', 
    SOURCE_PORT=3306,
    # Decirle a la réplica que ignore el GTID que ya ha sido ejecutado por el master
    SOURCE_AUTO_POSITION=1; 

  # Iniciar la réplica
  START REPLICA;
EOF