#!/bin/bash

if [ $1 == "continue_on_error" ] # determine action if test fails
then
    exit_on_error=0
else  # stop on error
    exit_on_error=1
fi

# Print the results to the user
function printResult {
    items=$1
    state=${2:-"do"}

    if [[ $state == "do" ]]
    then
        if [ $items == 0 ]
            then
                printf "\e[0;31mFailed...\n"
                if [ $exit_on_error -eq 1 ]; then exit 1; fi
            else 
                printf "\e[0;32mSuccess...\n"
        fi
    else
        if [ $items == 0 ]
            then 
                printf "\e[0;32mSuccess...\n"
            else
                printf "\e[0;31mFailed...\n" 
                if [ $exit_on_error -eq 1 ]; then exit 1; fi
        fi
    fi
}

# Search a resource group inside Azure"
function assertRG {
    resource_name=$1
    state=${2:-"do"}

    printf "\e[1;37mTesting Resource Group $resource_name -"\ $state\ "exist\n"
    query="az group list --query '[?name==\`${resource_name}\`] | length(@)'"
    items=`eval $query`

    printResult $items $state
}

# Search a resource inside Azure RG"
function assertResource {
    rg=$1
    resource_type=$2  # i.e. Microsoft.KeyVault/vaults
    resource_name=$3   
    state=${4:-"do"}

    printf "\e[1;37mTesting Resource Group: $rg, Type: $resource_type, Name: $resource_name -"\ $state\ "exist\n"
    query="az resource list -g $rg --resource-type $resource_type --query '[?name==\`${resource_name}\`] | length(@)'"
    items=`eval $query`

    printResult $items $state
}

# Search subnet inside an Azure VNET"
function assertSubnet {
    rg=$1
    vnet_name=$2
    resource_name=$3   
    state=${4:-"do"}

    printf "\e[1;37mTesting Resource Group: $rg, VNET: $vnet_name, Name: $resource_name -"\ $state\ "exist\n"
    query="az network vnet subnet list -g $rg --vnet-name $vnet_name --query '[?name==\`${resource_name}\`] | length(@)'"
    items=`eval $query`

    printResult $items $state
}