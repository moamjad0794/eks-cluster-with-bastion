#!/bin/bash
echo "{\"ip\": \"$(curl -s https://checkip.amazonaws.com | tr -d '\n')/32\"}"
