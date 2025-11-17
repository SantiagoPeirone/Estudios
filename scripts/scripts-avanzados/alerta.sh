#!/bin/bash

WEBHOOK_URL="https://discord.com/api/webhooks/1440026494650024179/0fVgA6uo0pFr4hkvihwTl97yeGq-JBtIgujHIDdo0KAIy0ExYoukt-LfkLhzO2XZ-tuZ"

function enviar_alerta_embed() {
    local TITULO="$1"
    local DESCRIPCION="$2"
    local COLOR="$3"

    /usr/bin/curl -H "Content-Type: application/json" \
         -X POST \
         -d "{
                \"embeds\": [{
                    \"title\": \"${TITULO}\",
                    \"description\": \"${DESCRIPCION}\",
                    \"color\": ${COLOR}
                }]
             }" \
         "$WEBHOOK_URL" >/dev/null 2>&1
}