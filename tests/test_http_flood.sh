#!/bin/bash
h=$1
[ -z "$h" ] && h="http://203.0.113.44"   # IP ficticia
total=200

echo "============================================"
echo "Simulación de ataque: HTTP Flood"
echo "URL objetivo simulada: $h"
echo "Cantidad de solicitudes: $total"
echo "============================================"
sleep 1

for i in $(seq 1 $total); do
  echo "[HTTP] Solicitud $i enviada a $h (simulada)"
  sleep 0.03
done

echo "--------------------------------------------"
echo "RESUMEN:"
echo "→ Tipo de ataque simulado: HTTP Flood"
echo "→ Objetivo: $h"
echo "→ Total de solicitudes simuladas: $total"
echo "→ No se envió tráfico real, solo simulación"
echo "============================================"
