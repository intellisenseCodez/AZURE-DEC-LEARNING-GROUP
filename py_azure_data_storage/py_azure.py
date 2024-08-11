#Upload CSV file to Azure Data Lake Gen2
from azure.identity import ClientSecretCredential
from azure.storage.filedatalake import DataLakeServiceClient, FileSystemClient, DataLakeDirectoryClient
import os
from dotenv import load_dotenv

local_path = os.getcwd()


# take environment variables from .env.
load_dotenv() 


# Azure Data Lake Details
account_name = os.getenv("ACCOUNT_NAME")
container_name = os.getenv("CONTAINER_NAME")
directory_name = os.getenv("DIRECTORY_NAME")  
csv_file_name = './annual-enterprise-survey-2023-financial-year-provisional.csv'
sas_token = os.getenv('SAS_TOKEN')


def get_service_client_sas(account_name: str, sas_token: str) -> DataLakeServiceClient:
    account_url = f"https://{account_name}.dfs.core.windows.net"

    # The SAS token string can be passed in as credential param or appended to the account URL
    service_client = DataLakeServiceClient(account_url, credential=sas_token)

    return service_client

def get_file_system(service_client: DataLakeServiceClient, file_system_name: str) -> FileSystemClient:
    
    file_system_client = service_client.get_file_system_client(file_system = file_system_name)

    return file_system_client


def upload_file_to_directory(directory_client: DataLakeDirectoryClient, local_path: str, file_name: str):
    # Get the file client
    file_client = directory_client.get_file_client(file_name)

    # Upload the CSV file content
    with open(file=os.path.join(local_path, csv_file_name), mode="rb") as data:
            file_client.upload_data(data, overwrite=True)
    
    print(f"File {csv_file_name} uploaded to Azure Data Lake Gen 2 successfully.")



if "__main__" == __name__:
    try:
        #Connect to Azure Storage Account
        service_client = get_service_client_sas(account_name,sas_token)
        # Get the file system client (container)
        file_system_client = get_file_system(service_client,container_name)
        print("Connected to Storage Account")
    except:
        print("error connecting to the storage account")
        
    # Get the directory client
    if directory_name:
        directory_client = file_system_client.get_directory_client(directory_name)
        print("Directory Found !")
    else:
        directory_client = file_system_client.get_root_directory_client()
    
    # Upload the CSV file content
    upload_file_to_directory(directory_client=directory_client, local_path=local_path, file_name=csv_file_name)
        