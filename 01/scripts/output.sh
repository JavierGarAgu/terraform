#!/bin/bash

# This script retrieves information about the Nginx service using systemctl and saves it to a JSON file.

# Use systemctl to list all Nginx services with detailed information.
# The output is formatted as comma-separated values and then piped to 'sed' to replace multiple spaces with commas.
# The result is then processed by 'jq' to convert it into a JSON object.
# The generated JSON object includes details such as the unit name, load status, active status, and sub status of the Nginx service.
# Finally, the JSON object is saved to the file /tmp/nginx.json.

systemctl list-units nginx.service --type service --full --all --plain --no-legend --no-pager | sed 's/ \{1,\}/,/g' | jq --raw-input --slurp 'split("\n") | map(split(",")) | .[0:-1] | map( { "unit": .[0], "load": .[1], "active": .[2], "sub": .[3] } ) | .[0]' > /tmp/nginx.json

