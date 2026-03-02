# scripts/check_data_lake.py
import os
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient

def verify_infrastructure():
    # In a real pipeline, the account name is passed as an environment variable
    account_name = os.environ.get("STORAGE_ACCOUNT_NAME")
    account_url = f"https://{account_name}.blob.core.windows.net"
    container_name = "raw-data"

    print(f"--- DataOps Quality Check ---")
    print(f"Checking Container: {container_name} in {account_name}...")

    try:
        # Use the same credentials as GitHub Actions
        credential = DefaultAzureCredential()
        service_client = BlobServiceClient(account_url, credential=credential)
        container_client = service_client.get_container_client(container_name)

        if container_client.exists():
            print(f"✅ SUCCESS: Data Lake container '{container_name}' is UP and reachable.")
        else:
            print(f"❌ ERROR: Container '{container_name}' not found.")
            exit(1)
    except Exception as e:
        print(f"❌ ERROR: Connectivity test failed: {str(e)}")
        exit(1)

if __name__ == "__main__":
    verify_infrastructure()