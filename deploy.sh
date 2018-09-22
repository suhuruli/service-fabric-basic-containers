#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

usage() { echo "Usage: $0 -i <subscriptionId> -g <resourceGroupName> -p <password> -l <resourceGroupLocation>" 1>&2; exit 1; }

declare subscriptionId=""
declare password=""

declare resourceGroupLocation="westus"
declare resourceGroupName="demolinuxsecure"
declare vaultName="demolinuxsecure"
declare keyvaultSubjectName="demolinuxsecure.westus.cloudapp.azure.com"

# Initialize parameters specified from command line
while getopts ":i:g:l:" arg; do
	case "${arg}" in
		i)
			subscriptionId=${OPTARG}
			;;
		g)
			resourceGroupName=${OPTARG}
			;;
		p)
			password=${OPTARG}
			;;
		l)
			resourceGroupLocation=${OPTARG}
			;;
		esac
done
shift $((OPTIND-1))

#Prompt for parameters is some required parameters are missing
if [[ -z "$subscriptionId" ]]; then
	read -p "Subscription Id: " subscriptionId
	[[ "${subscriptionId:?}" ]]
fi

if [[ -z "$resourceGroupName" ]]; then
	read -p "ResourceGroupName (Enter to use default of 'demolinuxsecure'): " resourceGroupName
	[[ "${resourceGroupName:?}" ]]
fi

if [[ -z "$password" ]]; then
	read -p "Password (used for KeyVault cert): " password
fi

if [[ -z "$resourceGroupLocation" ]]; then
	read -p "ResourceGroupLocation (Enter to use default of 'westus'): " resourceGroupLocation
fi

#templateFile Path - template file to be used
templateFilePath="template.json"

if [ ! -f "$templateFilePath" ]; then
	echo "$templateFilePath not found"
	exit 1
fi

#parameter file path
parametersFilePath="parameters.json"

if [ ! -f "$parametersFilePath" ]; then
	echo "$parametersFilePath not found"
	exit 1
fi

if [ -z "$subscriptionId" ] || [ -z "$resourceGroupName" ] || [ -z "$password" ]; then
	echo "Either one of subscriptionId, resourceGroupName, password is empty"
	usage
fi

#login to azure using your credentials
az account show 1> /dev/null

if [ $? != 0 ];
then
	az login
fi

#set the default subscription id
az account set --subscription $subscriptionId

set +e

#Check for existing RG
az group show --name $resourceGroupName 1> /dev/null

if [ $? != 0 ]; then
	echo "Resource group with name" $resourceGroupName "could not be found. Creating new resource group.."
	set -e
	(
		set -x
		az group create --name $resourceGroupName --location $resourceGroupLocation 1> /dev/null
	)
	else
	echo "Using existing resource group..."
fi

#Start deployment
echo "Starting deployment..."
(
	set -x
	
	az sf cluster create --resource-group $resourceGroupName --location $resourceGroupLocation  \
		--certificate-output-folder . --certificate-password $password --certificate-subject-name $keyvaultSubjectName  \
    	--vault-name $vaultName --vault-resource-group $resourceGroupName  \
    	--template-file $templateFilePath --parameter-file $parametersFilePath --vm-password $password
)

if [ $?  == 0 ];
 then
	echo "Template has been successfully deployed"
fi
