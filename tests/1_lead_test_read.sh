#!/bin/bash

# --- ESTO ES LO NUEVO: Capturar Ctrl+C ---
trap "echo; echo '🛑 Prueba detenida por el usuario.'; exit" SIGINT SIGTERM

echo "=================================================="
echo "   PRUEBA DE CARGA: LECTURA SQL (BALANCEO PROXYSQL)"
echo "=================================================="
echo "Generando tráfico SELECT directo hacia ProxySQL..."
echo "Mira tu Dashboard en Grafana: La línea del Hostgroup 20 DEBE subir."
echo "Presiona [CTRL+C] para detener."
echo ""

# Contador
count=0

# Bucle infinito
while true; do
    docker exec mysql_master mysql -u app_user -puserpassword -h proxysql -P 6033 -e "SELECT 1;" > /dev/null 2>&1
    
    ((count++))
    echo -ne "Consultas SQL enviadas: $count\r"
    
    # No hace falta sleep si usamos el 'trap' de arriba, 
    # el script ahora sabrá cuándo parar.
done