#!/bin/bash
h=$1
[ -z "$h" ] && h="192.0.2.10"   # IP ficticia
total=200

echo "============================================"
echo "Simulación de ataque: SYN Flood"
echo "Objetivo simulado: $h:80"
echo "Cantidad de paquetes: $total"
echo "============================================"
sleep 1

for i in $(seq 1 $total); do
  echo "[SYN] Paquete $i enviado a $h:80 (simulado)"
  sleep 0.05
done

echo "--------------------------------------------"
echo "RESUMEN:"
echo "→ Tipo de ataque simulado: SYN Flood"
echo "→ IP objetivo: $h"
echo "→ Total de paquetes simulados: $total"
echo "→ No se envió tráfico real, solo simulación"
echo "============================================"
