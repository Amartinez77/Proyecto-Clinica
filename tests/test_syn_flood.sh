#!/bin/bash

TARGET="$1"
[ -z "$TARGET" ] && TARGET="100.65.42.112"   # Tu servidor simulado
TOTAL=200

echo "====================================================="
echo "            SIMULACIÓN DE ATAQUE SYN FLOOD           "
echo "====================================================="
echo "Objetivo simulado: $TARGET:80"
echo "Cantidad de paquetes SYN simulados: $TOTAL"
echo "====================================================="
sleep 1

echo
echo "[1] Generando tráfico SYN ficticio..."
sleep 1

for i in $(seq 1 $TOTAL); do
  echo "[SYN] Paquete $i → $TARGET:80 (simulado)"
  sleep 0.05
done

echo
echo "-----------------------------------------------------"
echo "                      RESUMEN                        "
echo "-----------------------------------------------------"
echo "→ Tipo de ataque: SYN Flood (simulación)"
echo "→ Objetivo: $TARGET:80"
echo "→ Total de paquetes simulados: $TOTAL"
echo "→ No se envió tráfico real, solo actividad ficticia"
echo "====================================================="
echo "               FIN DE LA SIMULACIÓN                  "
echo "====================================================="
