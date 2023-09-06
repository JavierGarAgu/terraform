#!/bin/bash

# Ejecutar los comandos en secuencia y guardar la salida en el archivo /tmp/nginx.json
sudo systemctl list-units nginx.service --type service --full --all --plain --no-legend --no-pager | sed 's/ \{1,\}/,/g' | jq --raw-input --slurp 'split("\n") | map(split(",")) | .[0:-1] | map( { "unit": .[0], "load": .[1], "active": .[2], "sub": .[3] } ) | .[0]' > /tmp/nginx.json

# Ejecutar el último comando y guardar la salida en el archivo /tmp/nginx.json
echo "Comando ejecutado y resultado guardado en /tmp/nginx.json"








