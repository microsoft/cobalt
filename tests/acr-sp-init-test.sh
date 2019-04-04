#!/bin/bash -e

# Test Input Values
appName="CbltApp"
location="eastus"
suffix="Cntso Dev"

bash ../setup/acr-sp-init.sh -a $appName -l $location -s "${suffix}"

# Expected resource group properties
rgName="cblt-usea-rg-cntsodev"
rgLocation="eastus"
expectedRgValues='['${rgName}','${rgLocation}']'

# Expected ACR properties
acrName="cbltuseaacrcntsodev"
acrLocation="eastus"
expectedAcrValues='['${acrName}','${acrLocation}']'

# Expected service principal properties
declare -A spAcrNameAndRole=(
    ["http://cblt-usea-sp-cntsodev-pull"]="AcrPull"
    ["http://cblt-usea-sp-cntsodev-push"]="AcrPush"
)

# Assertions
# Test resource group
echo "Testing resource group..."
resourceValues=$(az group show --name $rgName --query '[name,location]' --output JSON)
resourceValues=${resourceValues//[[:space:]]/}
resourceValues=${resourceValues//\"/}

if [[ "$resourceValues" != "$expectedRgValues" ]]; then
    echo "Error: Unexpected resource group values."
    echo "  Results returned '${resourceValues}'"
    echo "          expected '${expectedRgValues}'"
    exit 1;
fi

# Test ACR
echo "Testing container registry..."
resourceValues=$(az acr show --name $acrName --query '[name,location]' --output JSON)
resourceValues=${resourceValues//[[:space:]]/}
resourceValues=${resourceValues//\"/}

if [[ "$resourceValues" != "$expectedAcrValues" ]]; then
    echo "Error: Unexpected container registry values."
    echo "  Results returned '${resourceValues}'"
    echo "          expected '${expectedAcrValues}'"
    exit 1;
fi

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

# Clean up tests results
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




