#!/bin/bash
h=$1
[ -z "$h" ] && h="198.51.100.23"   # IP ficticia
total=200

echo "============================================"
echo "Simulación de ataque: UDP Flood"
echo "Objetivo simulado: $h:53"
echo "Cantidad de paquetes: $total"
echo "============================================"
sleep 1

for i in $(seq 1 $total); do
  echo "[UDP] Paquete $i enviado a $h:53 (simulado a 50 pps)"
  sleep 0.02
done

echo "--------------------------------------------"
echo "RESUMEN:"
echo "→ Tipo de ataque simulado: UDP Flood"
echo "→ IP objetivo: $h"
echo "→ Total de paquetes simulados: $total"
echo "→ No se envió tráfico real, solo simulación"
echo "============================================"
