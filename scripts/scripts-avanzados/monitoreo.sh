#!/bin/bash

source /home/ec2-user/alerta.sh

# Si fue cargado con "source", no ejecutar el script, solo exportar funciones
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    return 0
fi

#------------------------- Alertas -------------------------------------#

WEBHOOK_URL="https://discord.com/api/webhooks/1440026494650024179/0fVgA6uo0pFr4hkvihwTl97yeGq-JBtIgujHIDdo0KAIy0ExYoukt-LfkLhzO2XZ-tuZ"

#------------------------ Errores & Depuración ------------------------#

set -euo pipefail
trap 'echo "[ERROR] Falló el script en la línea $LINENO"' ERR
trap 'echo "Script terminado"; rm -f /tmp/monitor.lock' EXIT

PATH=/usr/sbin:/usr/bin:/bin

#--------------------- Variables ----------------------------------#

umbral=${1:-0}
cpu=$(/usr/bin/top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d',' -f1)
ram=$(/usr/bin/free | grep Mem | awk '{print $3/$2 * 100}')
disk=$(/usr/bin/df / | grep / | awk '{print $5}' | tr -d '%')
tiempo=$(date +"%Y-%m-%d %H:%M:%S")
estado=0

#-------------------------- Lectura ----------------------------------#

if [ "$umbral" -eq 0 ]; then
    echo "Ingrese un umbral: "
    read umbral
fi

#--------------------- Testing ----------------------------------#

echo "Carga del CPU: $cpu"
echo "Carga de la RAM: $ram"
echo "Carga del Disco: $disk"

#------------------------ Monitoreo ------------------------------------#

cpu_carga=$(printf "%.0f" "$cpu")
ram_carga=$(printf "%.0f" "$ram")
disk_carga=$(printf "%.0f" "$disk")

if [ "$cpu_carga" -gt "$umbral" ]; then
        enviar_alerta_embed \
        "🔴 ALERTA CPU" \
        "Uso actual: ${cpu_carga}%\nUmbral: ${umbral}%\nFecha: ${tiempo}" \
        16711680
        exit 1
else
        echo "Su procesador está bien"
fi

if [ "$ram_carga" -gt "$umbral" ]; then
        enviar_alerta_embed \
        "🔴 ALERTA RAM" \
        "RAM usada: ${ram_carga}%\nUmbral: ${umbral}%\nFecha: ${tiempo}" \
        16776960
        exit 1
else
        echo "Su RAM está bien"
fi

if [ "$disk_carga" -gt "$umbral" ]; then
        echo "Registro de superación del umbral del disco: [$tiempo]" >> /var/log/monitoreo.log
        exit 1
else
        echo "Su disco está bien"
fi

exit 0
