import os
from azure.storage.blob import BlobServiceClient

def check_storage_ready():
    # These are usually provided by the environment in a real pipeline
    connection_string = os.getenv('AZURE_STORAGE_CONNECTION_STRING')
    container_name = "raw-data"
    
    try:
        blob_service_client = BlobServiceClient.from_connection_string(connection_string)
        container_client = blob_service_client.get_container_client(container_name)
        
        if container_client.exists():
            print(f"✅ DataOps Success: Container '{container_name}' is ready.")
        else:
            print(f"❌ DataOps Error: Container '{container_name}' not found.")
            exit(1)
            
    except Exception as e:
        print(f"❌ Connection failed: {str(e)}")
        exit(1)

if __name__ == "__main__":
    check_storage_ready()