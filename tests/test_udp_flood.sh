#!/bin/bash

TARGET="$1"
[ -z "$TARGET" ] && TARGET="100.65.42.112"   # Tu servidor simulado
TOTAL=200

echo "====================================================="
echo "              SIMULACIÓN DE ATAQUE UDP FLOOD         "
echo "====================================================="
echo "Objetivo simulado: $TARGET:53"
echo "Cantidad de paquetes UDP simulados: $TOTAL"
echo "====================================================="
sleep 1

echo
echo "[1] Generando tráfico UDP ficticio..."
sleep 1

for i in $(seq 1 $TOTAL); do
  echo "[UDP] Paquete $i → $TARGET:53 (simulado a 50 pps)"
  sleep 0.02
done

echo
echo "-----------------------------------------------------"
echo "                      RESUMEN                        "
echo "-----------------------------------------------------"
echo "→ Tipo de ataque: UDP Flood (simulación)"
echo "→ Objetivo: $TARGET:53"
echo "→ Total de paquetes simulados: $TOTAL"
echo "→ No se generó tráfico real, solo simulación visual"
echo "====================================================="
echo "               FIN DE LA SIMULACIÓN                  "
echo "====================================================="
