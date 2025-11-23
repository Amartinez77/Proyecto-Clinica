#!/bin/bash

# Capturar Ctrl+C para salir limpio
trap "echo; echo '🛑 Prueba cancelada.'; exit" SIGINT SIGTERM

echo "=================================================="
echo "   PRUEBA DE HA: FAILOVER DEL MASTER (Simulacro)"
echo "=================================================="
echo "⚠️  ADVERTENCIA: Esto simulará una caída total del Master."
echo "    Abre Orchestrator en tu navegador: http://localhost:3002"
echo ""
read -p "Presiona [ENTER] para ASESINAR al Master..."

echo "💀 Deteniendo mysql_master..."
docker stop mysql_master

echo "✅ Master detenido."
echo "⏳ Esperando 15 segundos para que Orchestrator reaccione..."
echo "   (Mira cómo la topología cambia en el navegador...)"

# Cuenta regresiva visual para la audiencia
for i in {15..1}; do
    echo -ne "   Tiempo restante: $i \r"
    sleep 1
done
echo "   Tiempo cumplido. El Failover debería haber ocurrido."
echo ""
echo "👉 PRUEBA AHORA: Intenta escribir o leer en tu App."
echo "   (Debería seguir funcionando porque la Réplica ahora es el Jefe)"
echo ""

read -p "Presiona [ENTER] para REVIVIR al viejo Master..."

echo "🚑 Iniciando mysql_master..."
docker start mysql_master
echo "✅ Viejo Master iniciado."
echo "ℹ️  NOTA: Orchestrator lo agregará como ESCLAVO del nuevo Master."
echo "=================================================="
echo "   PRUEBA FINALIZADA"
echo "=================================================="