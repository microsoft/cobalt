#!/bin/bash +e

# Test Input Values
appName="CbltApp"
location="eastus"
suffix="Cntso Dev"

bash ./acr-sp-init.sh -a $appName -l $location -s $suffix

# Assertions
# ToDo...
