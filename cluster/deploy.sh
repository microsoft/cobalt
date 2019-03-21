#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

usage() { echo "Usage: $0 -i <APP_ID> -n <APP_SECRET> -l <TENANT_ID>" 1>&2; exit 1; }

declare APP_ID=${APP_ID:=""} 
declare APP_SECRET=${APP_SECRET:=""}
declare TENANT_ID=${TENANT_ID:=""}

# Initialize parameters specified from command line
while getopts ":i:n:l:" arg; do
	case "${arg}" in
		i)
			APP_ID=${OPTARG}
			;;
		n)
			APP_SECRET=${OPTARG}
			;;
		l)
			TENANT_ID=${OPTARG}
			;;
		esac
done
shift $((OPTIND-1))

#Prompt for parameters is some required parameters are missing
if [[ -z "$APP_ID" ]]; then
	echo "Enter your Application ID:"
	read APP_ID
	[[ "${APP_ID:?}" ]]
fi

if [[ -z "$APP_SECRET" ]]; then
	echo "Enter Application secret:"
	read APP_SECRET
fi

if [[ -z "$TENANT_ID" ]]; then
	echo "Please enter your Tenant ID"
	read TENANT_ID
	[[ "${TENANT_ID:?}" ]]
fi

if [[ (-z "$APP_ID") && (-z "$APP_SECRET") && (-z "$TENANT_ID") ]]; then
	echo "Either one of Application ID or Application secret or Tenant ID is empty"
	usage
fi

#Login to azure using your credentials
echo "Login to Azure..."
az login --service-principal -u $APP_ID -p $APP_SECRET --tenant $TENANT_ID
set +e

#Start deployment
echo "Starting deployment..."
(
	[ "$DEBUG" == 'true' ] && set -x
    terraform init
    terraform apply -auto-approve
)

#Start keyvault deployment
cd azure/keyvault
echo "Starting KeyVault deployment..."
(
	[ "$DEBUG" == 'true' ] && set -x
    terraform init
    terraform apply -auto-approve
)

if [ $?  == 0 ];
 then
	echo "Terraform Template has been successfully deployed"
fi
