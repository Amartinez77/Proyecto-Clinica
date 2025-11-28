#!/bin/bash

TARGET="$1"
[ -z "$TARGET" ] && TARGET="http://100.65.42.112"   # Tu red/servidor Tailscale
TOTAL=200

echo "====================================================="
echo "        SIMULACIÓN DE ATAQUE HTTP FLOOD (FICTICIO)   "
echo "====================================================="
echo "Servidor objetivo simulado: $TARGET"
echo "Cantidad de solicitudes simuladas: $TOTAL"
echo "====================================================="
sleep 1

echo
echo "[1] Iniciando generación ficticia de tráfico HTTP..."
sleep 1

for i in $(seq 1 $TOTAL); do
  echo "[HTTP] Solicitud simulada $i → $TARGET"
  sleep 0.03
done

echo
echo "-----------------------------------------------------"
echo "                     RESUMEN                        "
echo "-----------------------------------------------------"
echo "→ Tipo de ataque: HTTP Flood (simulación)"
echo "→ Objetivo: $TARGET"
echo "→ Solicitudes ficticias generadas: $TOTAL"
echo "→ No se envió ningún paquete real a la red"
echo "→ Seguridad del servidor: 100% intacta"
echo "====================================================="
echo "              FIN DE LA SIMULACIÓN                  "
echo "====================================================="
