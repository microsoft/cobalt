#!/bin/bash -e

# Test Input Values
appName="CbltApp"
location="eastus"
suffix="Cntso Dev"

bash ../setup/acr-sp-init.sh -a $appName -l $location -s "${suffix}"

cleanup=true
while getopts "n" opt; do
    case $opt in
        n)
            # Don't cleanup test resources.
            cleanup=false
            ;;
    esac
done

# Expected resource group properties
rgName="cblt-usea-rg-cntsodev"
rgLocation="eastus"
expectedRgValues='['\"${rgName}\"','\"${rgLocation}\"']'

# Expected ACR properties
acrName="cbltuseaacrcntsodev"
acrLocation="eastus"
expectedAcrValues='['\"${acrName}\"','\"${acrLocation}\"']'

# Expected service principal properties
declare -A spAcrNameAndRole=(
    ["http://cblt-usea-sp-cntsodev-pull"]="AcrPull"
    ["http://cblt-usea-sp-cntsodev-push"]="AcrPush"
)

function assertEqual() {
   if [[ $# != 3 ]]; then
       echo "Unexpected number of parameters passed to '$0'."
       echo "  Parameter 1 - expected value"
       echo "  Parameter 2 - actual value"
       echo "  Parameter 3 - description of resource"
       exit 1;
   fi
   
   if [[ "$1" != "$2" ]]; then
       echo "Error: Unexpected '$3' values."
       echo "  Actual value:   '$1'"
       echo "  Expected value: '$2'"
       exit 1;
   fi
}

# Assertions

# Test resource group
echo "Testing resource group..."
resourceValues=$(az group show --name $rgName --query '[name,location]' --output JSON)
resourceValues=${resourceValues//[[:space:]]/}
assertEqual $resourceValues $expectedRgValues "resource group"

# Test ACR
echo "Testing container registry..."
resourceValues=$(az acr show --name $acrName --query '[name,location]' --output JSON)
resourceValues=${resourceValues//[[:space:]]/}
assertEqual $resourceValues $expectedAcrValues "container registry"

# Test service principals
echo "Testing service principals..."

# Get the ACR ID for the container registry the service principal role assignments should be scoped to.
acrId=$(az acr show --name $acrName --query id)
acrId="${acrId//\"}"

for spName in ${!spAcrNameAndRole[@]}
do
    # Get the appId of the expected service principal
    spAppId=$(az ad sp show --id ${spName} --query appId)
    spAppId="${spAppId//\"}"

    # Get the role assignment scoped to the ACR for the service principal.
    roleAssignment=$(az role assignment list --assignee ${spName} --scope ${acrId} --role ${spAcrNameAndRole[$spName]} --query 'length(@)')
    if [[ roleAssignment -eq 0 ]]; then
        echo "Error: Role assignmet to ACR '${acrName}' for service principal '$spName' is missing."
        exit 1;
    fi
done

echo "Tests passed successfully"

# Clean up tests resources
if [[ "$cleanup" == true ]]; then
    echo "Cleaning up test resources"

    echo "  Cleaning up service principals and role assignments..."
    for spName in ${!spAcrNameAndRole[@]}
    do
        # Clean up service principals and role assignments
        spAppId=$(az ad sp show --id ${spName} --query appId)
        spAppId="${spAppId//\"}"
        az ad sp delete --id ${spAppId}
    done

    # Clean up container registry
    echo "  Cleaning up container registry..."
    az acr delete --name ${acrName}

    # Clean up resource group
    echo "  Cleaning up resource group..."
    az group delete --name ${rgName} --yes
fi