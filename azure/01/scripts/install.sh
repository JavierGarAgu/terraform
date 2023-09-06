#!/bin/bash

# This script updates the package repository lists using 'apt update'.
# It then installs Nginx web server using 'apt-get install nginx -y'.
# Lastly, it installs 'jq', a command-line JSON processor, using 'apt install jq -y'.

apt update && apt-get install nginx -y && sudo apt install jq -y
