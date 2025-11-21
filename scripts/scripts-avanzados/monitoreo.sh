#!/bin/bash

# Cargar alerta.sh desde la misma carpeta que este script
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/alerta.sh"

# Si fue cargado con "source", no ejecutar
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    return 0
fi

set -euo pipefail
trap 'echo "[ERROR] Falló el script en la línea $LINENO"' ERR

PATH=/usr/sbin:/usr/bin:/bin

#---------------- Variables ----------------#

umbral=${1:-0}

# CPU (compatible con GitHub Actions)
cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')

# RAM
ram=$(free | grep Mem | awk '{print $3/$2 * 100}')

# DISK
disk=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

tiempo=$(date +"%Y-%m-%d %H:%M:%S")

#---------------- Lectura ----------------#

if [ "$umbral" -eq 0 ]; then
    echo "Ingrese un umbral: "
    read umbral
fi

#---------------- Testing ----------------#

echo "CPU: $cpu"
echo "RAM: $ram"
echo "DISK: $disk"

cpu_carga=$(printf "%.0f" "$cpu")
ram_carga=$(printf "%.0f" "$ram")
disk_carga=$(printf "%.0f" "$disk")

#---------------- Monitoreo ----------------#

if [ "$cpu_carga" -gt "$umbral" ]; then
    enviar_alerta_embed "🔴 ALERTA CPU" \
        "Uso actual: ${cpu_carga}%\nUmbral: ${umbral}%\nFecha: ${tiempo}" \
        16711680
    exit 1
else
    echo "CPU OK"
fi

if [ "$ram_carga" -gt "$umbral" ]; then
    enviar_alerta_embed "🔴 ALERTA RAM" \
        "Uso actual: ${ram_carga}%\nUmbral: ${umbral}%\nFecha: ${tiempo}" \
        16776960
    exit 1
else
    echo "RAM OK"
fi

if [ "$disk_carga" -gt "$umbral" ]; then
    echo "[$tiempo] Umbral superado" >> ./monitoreo.log
    exit 1
else
    echo "DISK OK"
fi

exit 0
