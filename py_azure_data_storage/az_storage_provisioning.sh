#!/bin/bash

# Exit script if any command fails
set -e

# Load environment variables from .env file
set -a ; . ./.env ; set +a


# Start the Docker container with Azure CLI preinstalled
echo "Starting Docker container..."
docker run -i mcr.microsoft.com/azure-cli:cbl-mariner2.0 /bin/bash <<EOF


# Sign in to Azure CLI
echo "Signing in to Azure CLI..."
az login

# Create a new resource group
echo "Creating resource group '$RESOURCE_GROUP_NAME'..."
az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"

# Verify that the resource group was created
echo "Verifying resource group creation..."
az group show --name "$RESOURCE_GROUP_NAME"

# Create Azure Storage account
echo "Creating storage account '$STORAGE_ACCOUNT_NAME'..."
az storage account create --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP_NAME" --location "$LOCATION" --sku "$STORAGE_REPLICATION" --kind StorageV2 --hns true


# Verify that the storage account was created
echo "Verifying storage account creation..."
az storage account show --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP_NAME"


# # Get the shared access signatures
# echo "Generating shared access signatures..."
# SAS_TOKEN=$(end=`date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ' sas=`az storage container generate-sas --name "$CONTAINER_NAME" --https-only --permissions dlrw --expiry $end -o tsv az storage blob upload -n MyBlob -c "$CONTAINER_NAME" -f file.txt --sas-token $sas)

# # Create a container within the storage account
# echo "Creating container '$CONTAINER_NAME'..."
# az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT_NAME" --sas-token "$SAS_TOKEN"

# # Verify that the container was created
# echo "Verifying container creation..."
# az storage container show --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT_NAME" --sas-token "$SAS_TOKEN"

# # Create a "virtual directory" by uploading a dummy file
# echo "Uploading a dummy file to create directory '$DIRECTORY_NAME'..."
# az storage blob upload --container-name "$CONTAINER_NAME" --file /dev/null --name "$DIRECTORY_NAME/empty.txt" --account-name "$STORAGE_ACCOUNT_NAME" --sas-token "$SAS_TOKEN"

# # Verify the upload
# echo "Verifying the directory creation..."
# az storage blob list --container-name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT_NAME" --prefix "$DIRECTORY_NAME/" 


# Exit the Docker container

exit

EOF

echo "Provisioning script completed successfully."
