#!/bin/bash -e

while getopts "c:l:" opt; do
    case $opt in
        c)
            # Company name 
            company=$OPTARG
        ;;
        l)
            # Location/region where resource group will deploy to
            location=$OPTARG 
        ;;
    esac
done

# If user did not provide required parameters then show usage.
[[ $# -eq 0 || -z $company || -z $location ]] && 
{ 
    echo "Usage:";
    echo "  $0 -c <company name> -l <location/region>";
    echo "  Use \"az account list-locations --query '[].name'\" to list supported regions for a subscription.'"
    echo "";
    echo "Example:";
    echo "  $0 -c contoso -l eastus";
    exit 1; 
}

# Convert to lowercase, remove whitespace, and trim lenght if needed.
location=${location// /}
location=${location,,}

company=${company// /}
company=${company,,}
company=${company:0:8}

# Translate location to an abbreviated location code.
locationCode=""
declare -A locationCodes=(
    # Asia
    ["eastasia"]="asea"
    ["southeastasia"]="assw"

    # Australia
    ["australiaeast"]="auea"
    ["australiasoutheast"]="ause"

    # Brazil
    ["brazilsouth"]="brso"

    # Canada
    ["canadacentral"]="cace"
    ["canadaeast"]="caea"
    ["uksouth"]="ukso"
    ["ukwest"]="ukwe"
    ["koreacentral"]="koce"
    ["koreasouth"]="koso"
    ["francecentral"]="frce"
    ["francesouth"]="frso"
    ["australiacentral"]="auce"
    ["australiacentral2"]="auc2"
    ["southafricanorth"]="sano"
    ["southafricawest"]="sawe"

    # Europe
    ["northeurope"]="euno"
    ["westeurope"]="euwe"

    # India
    ["southindia"]="inso"
    ["centralindia"]="ince"
    ["westindia"]="inwe"

    # Japan
    ["japanwest"]="jawe"
    ["japaneast"]="jaea"

    # US
    ["centralus"]="usce"
    ["eastus"]="usea"
    ["eastus2"]="use2"
    ["westus"]="uswe"
    ["westus2"]="usw2"
    ["northcentralus"]="usnc"
    ["southcentralus"]="ussc"
    ["westcentralus"]="uswc"
)

locationCode=${locationCodes[$location]}

[[ -z ${locationCode} ]] && {
    echo "Invalid value '${location}' for location parameter.";
    exit 1;
}

# Authenticate user.
az login

# Create the resource group.
rgName="acr-${locationCode}-${company}"
az group create --name $rgName --location $location

# Create the container registry.
acrName=${rgName//-/}
acrId=$(az acr create --resource-group $rgName --name $acrName --sku Standard --query id)
acrId="${acrId//\"}"
# ToDo: Should parameterize 'sku' in the future 

# Create service principals and role assignments to ACR.
declare -A spAcrNameAndRole=(
    ["http://acr-${company}-pull"]="AcrPull"
    ["http://acr-${company}-push"]="AcrPush"
)

for spName in ${!spAcrNameAndRole[@]}
do
    echo "Creating service principal '${spName}'."
    az ad sp create-for-rbac --name $spName --skip-assignment 
    
    echo "Waiting for service principal '${spName}' to propagate in Azure AD."
    sleep 15s

    echo "Creating role assignment for service principal '${spName}'."
    az role assignment create --assignee $spName --scope $acrId --role AcrPull
done
