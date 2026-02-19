#!/bin/bash

ip=$(curl -s https://api.ipify.org)
terraform apply -auto-approve -var my_ip="$ip/32"
