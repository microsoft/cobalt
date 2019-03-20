#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

usage() { echo "Usage: $0 -i <subscriptionId> -n <deploymentName> -l <resourceGroupLocation>" 1>&2; exit 1; }

declare SUBSCRIPTION_ID=${SUBSCRIPTION_ID:=""} 
declare DEPLOYMENT_NAME=${DEPLOYMENT_NAME:=""}
declare RESOURCE_GROUP_LOCATON=${RESOURCE_GROUP_LOCATON:=""}
declare DEPLOYMENT_NAME=${DEPLOYMENT_NAME:=""}
declare DEBUG=false

# Initialize parameters specified from command line
while getopts ":i:n:l:" arg; do
	case "${arg}" in
		i)
			SUBSCRIPTION_ID=${OPTARG}
			;;
		n)
			DEPLOYMENT_NAME=${OPTARG}
			;;
		l)
			RESOURCE_GROUP_LOCATON=${OPTARG}
			;;
		esac
done
shift $((OPTIND-1))

#Prompt for parameters is some required parameters are missing
if [[ -z "$SUBSCRIPTION_ID" ]]; then
	echo "Your subscription ID can be looked up with the CLI using: az account show --out json "
	echo "Enter your subscription ID:"
	read SUBSCRIPTION_ID
	[[ "${SUBSCRIPTION_ID:?}" ]]
fi

if [[ -z "$RESOURCE_GROUP_LOCATON" ]]; then
	echo "If creating a *new* resource group, you need to set a location "
	echo "You can lookup locations with the CLI using: az account list-locations "

	echo "Enter resource group location:"
	read RESOURCE_GROUP_LOCATON
fi

if [[ -z "$DEPLOYMENT_NAME" ]]; then
	echo "Please enter a Deployment Name for your Application"
	read DEPLOYMENT_NAME
	[[ "${DEPLOYMENT_NAME:?}" ]]
fi

if [[ -z "$SUBSCRIPTION_ID" ]]; then
	echo "Either one of subscriptionId or deploymentName is empty"
	usage
fi

#login to azure using your credentials
echo "Login to Azure..."
(
    set +x
	az login
    accountsetout=`az account set --subscription $SUBSCRIPTION_ID`
	echo $accountsetout
    output=`az login --service-principal -u $APP_ID -p $APP_SECRET --tenant $TENANT_ID`
    # SP_JSON=`az ad sp create-for-rbac --role="Contributor"`
    # echo $SP_JSON
    # export SP_NAME=`echo $SP_JSON | jq -r '.name'`
    # export SP_PASS=`echo $SP_JSON | jq -r '.password'`
    # export SP_TENANT=`echo $SP_JSON | jq -r '.tenant'`
    # output=`az login --service-principal -u $SP_NAME -p $SP_PASS --tenant $SP_TENANT`
	# echo $output
)

#set the default subscription id

set +e

#Check for existing RG
# TODO:DELETE az group show --name $resourceGroupName 1> /dev/null

# if [ $? != 0 ]; then
# 	echo "Resource group with name" $resourceGroupName "could not be found. Creating new resource group.."
# 	set -e
# 	(
# 		set -x
# 		az group create --name $resourceGroupName --location $resourceGroupLocation 1> /dev/null
# 	)
# 	else
# 	echo "Using existing resource group..."
# fi

#Start deployment
echo "Starting deployment..."
(
	[ "$DEBUG" == 'true' ] && set -x
    terraform init
    terraform apply
	# TODO : az group deployment create --name "$DEPLOYMENT_NAME" --resource-group "$resourceGroupName" --template-file "$templateFilePath" #--parameters "@${parametersFilePath}"
)

if [ $?  == 0 ];
 then
	echo "Template has been successfully deployed"
fi
