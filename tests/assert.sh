#!/bin/bash

if [ $1 == "continue_on_error" ]
then
    set +e 
else  # stop on error
    set -e
fi

function printResult {
    if [ $1 -eq 1 ]
        then printf "\e[0;31mFailed...\n"
        else printf "\e[0;32mSuccess...\n"
    fi
}

# Search a resource group inside Azure"
function assertRG {
    export name=$1 
    printf "\e[1;37mTesting Resourgroup $name - "

    if [ ${2:-"yes"}  == "not" ] # Set the assert type.  If assert_type is empty check for exist, else validate for not exist
    then
    echo "not exist"
        az group list | jq  -e 'if contains( [{ name: env.name }] ) then false else true end' > /dev/null
    else
    echo "exist"
        az group list | jq  -e 'contains( [{ name: env.name }] )' > /dev/null
    fi

    printResult $? 
}

# Search a resource inside Azure RG"
function assertResource {
    export rg=$1
    export resource_type=$2  # i.e. Microsoft.KeyVault/vaults
    export resource_name=$3   

    printf "\e[1;37mTesting Resource Group: $rg, Type: $resource_type, Name: $resource_name - "

    if [ ${4:-"yes"}  == "not" ] # Set the assert type.  If assert_type is empty check for exist, else validate for not exist
    then
    echo "not exist"
    az resource list -g $rg --resource-type $resource_type | jq  -e 'if contains( [{ name: env.resource_name }] ) then false else true end' > /dev/null
    else
    echo "exist"
    az resource list -g $rg --resource-type $resource_type | jq  -e 'contains( [{ name: env.resource_name }] )' > /dev/null
    fi

    printResult $? 
}