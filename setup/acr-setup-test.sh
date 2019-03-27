#!/bin/bash -e

# Test Input Values
appName="CbltApp"
location="eastus"
suffix="Cntso Dev"

bash ./acr-sp-init.sh -a $appName -l $location -s "${suffix}"

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

[[ "$resourceValues" != "$expectedRgValues" ]] && {
    echo "Error: Unexpected resource group values."
    echo "  Results returned '${resourceValues}'"
    echo "          expected '${expectedRgValues}'"
    exit 1;
}

# Test ACR
echo "Testing container registry..."
resourceValues=$(az acr show --name $acrName --query '[name,location]' --output JSON)
resourceValues=${resourceValues//[[:space:]]/}
resourceValues=${resourceValues//\"/}

[[ "$resourceValues" != "$expectedAcrValues" ]] && {
    echo "Error: Unexpected container registry values."
    echo "  Results returned '${resourceValues}'"
    echo "          expected '${expectedAcrValues}'"
    exit 1;
}

# Test service principals
echo "Testing service principals..."
for spName in ${!spAcrNameAndRole[@]}
do
    # Get the appId of the expected service principal
    spAppId=$(az ad sp show --id ${spName} --query appId)
    spAppId="${spAppId//\"}"

    # Get the ACR ID for the container registry the service principal role assignments should be scoped to.
    acrId=$(az acr show --name $acrName --query id)
    acrId="${acrId//\"}"

    # Get the role assignment scoped to the ACR for the service principal.
    roleAssignment=$(az role assignment list --assignee ${spName} --scope ${acrId} --role ${spAcrNameAndRole[$spName]} --query 'length(@)')
    [[ roleAssignment -eq 0 ]] && {
        echo "Error: Role assignmet to ACR '${acrName}' for service principal '$spName' is missing."
        exit 1;
    }
done

echo "Tests passed successfully"



