#!/bin/bash -e

while getopts "a:l:s:" opt; do
    case $opt in
        a)
            # Application name 
            appname=$OPTARG
        ;;
        l)
            # Location/region where resource group will deploy to
            location=$OPTARG 
        ;;
        s)
            # Suffix
            suffix=$OPTARG 
        ;;
    esac
done

# If user did not provide required parameters then show usage.
[[ $# -eq 0 || -z $appname || -z $location || -z $suffix ]] && 
{ 
    echo "Usage:";
    echo "  $0 -a <app name> -l <location/region> -s <suffix>";
    echo "  Use \"az account list-locations --query '[].name'\" to list supported regions for a subscription.'"
    echo "";
    echo "Example:";
    echo "  $0 -a cblt -l eastus -s prod";
    exit 1; 
}

# Convert to lowercase, remove whitespace, and trim lenght if needed.
appname=${appname// /}
appname=${appname,,}
appname=${appname:0:4}

location=${location// /}
location=${location,,}

suffix=${suffix// /}
suffix=${suffix,,}
suffix=${suffix:0:8}

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

# Create the resource group.
rgName="${appname}-${locationCode}-rg-${suffix}"
az group create --name $rgName --location $location

# Create the container registry.
acrName="${appname}${locationCode}acr${suffix}"
acrId=$(az acr create --resource-group $rgName --name $acrName --sku Standard --query id)
acrId="${acrId//\"}"
# ToDo: Should parameterize 'sku' in the future 

# Used to find/create service principals and role assignments to ACR.
declare -A spAcrNameAndRole=(
    ["http://${appname}-${locationCode}-sp-${suffix}-pull"]="AcrPull"
    ["http://${appname}-${locationCode}-sp-${suffix}-push"]="AcrPush"
)

for spName in ${!spAcrNameAndRole[@]}
do
    # Get the appId of the service principal if it already exists.
    spAppId=""
    spAppId=$(az ad sp show --id ${spName} --query appId || true)
    spAppId="${spAppId//\"}"

    # Create a new service principal if it doesn't already exist.
    [[ -z ${spAppId} ]] && {
        echo "Creating service principal '${spName}'."
        az ad sp create-for-rbac --name $spName --skip-assignment 
    }

    # Get the role assignment scoped to the ACR for the service principal if it already exists.
    roleAssignment=""
    roleAssignment=$(az role assignment list --assignee ${spName} --scope ${acrId} --role ${spAcrNameAndRole[$spName]} --query 'length(@)')

    # Create a new role assignment if it doesn't already exist.
    [[ $roleAssignment -eq 0 ]]  && {
        echo "Creating role assignment for service principal '${spName}'."
        roleAssignmentId=""
        retryCount=0
        maxRetries=10
        while [[ -z $roleAssignmentId && $retryCount -lt $maxRetries ]]
        do
            sleep 2s
            ((retryCount++))
            roleAssignmentId=$(az role assignment create --assignee $spName --scope $acrId --role ${spAcrNameAndRole[$spName]} --query 'id')
        done

        # Abort if role assignment could not be created.
        [[ -z $roleAssignmentId ]] && {
            echo "Error creating role assignment '${spAcrNameAndRole[$spName]}' for service principal '${spName}'.";
            exit 1;
        }

        echo "Role assignment created for service principal '${spName}'."
    }
done

echo "Successfully completed"
