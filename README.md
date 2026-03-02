# Azure DataOps Mini-Project: Automated Data Lake Deployment

This project demonstrates a production-ready **DataOps** workflow for deploying a foundational data architecture on Microsoft Azure. It leverages **Infrastructure as Code (IaC)** with Terraform and **CI/CD** with GitHub Actions, including a post-deployment **Data Quality Health Check**.

---

## Architecture Overview

The pipeline provisions a "Data-Ready" environment in a single automated flow:

* **Resource Group**: Logical container for all project resources.
* **Azure Data Lake Storage Gen2 (ADLS Gen2)**: 
    * Configured with **Hierarchical Namespace (HNS)** enabled for high-performance big data analytics.
    * Using **LRS (Locally Redundant Storage)** for cost optimization (Free Tier compatible).
    * Includes a `raw-data` container for initial data landing.
* **Azure Data Factory (ADF) v2**: The orchestration engine for future ETL/ELT pipelines.
* **Post-Deployment Health Check**: A Python-based validation step to ensure connectivity and container availability.

---

## Tech Stack

* **Cloud**: Microsoft Azure
* **IaC**: Terraform (v4.x)
* **CI/CD**: GitHub Actions
* **Language**: Python 3.10 (for Data Quality validation)
* **Security**: Azure Service Principal (RBAC) & GitHub Secrets

---

## Setup & Prerequisites

### 1. Azure Service Principal
To allow GitHub to deploy resources, create a Service Principal with **Contributor** access:

```bash
az ad sp create-for-rbac --name "GitHub-DataOps-Deployer" \
  --role contributor \
  --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID> \
  --sdk-auth
```

### 2. GitHub Secrets
Store the resulting JSON in a GitHub Secret named `AZURE_CREDENTIALS`. 
The pipeline also expects the following mapping from that JSON to satisfy both Terraform and the Python SDK:
* `ARM_CLIENT_ID` / `AZURE_CLIENT_ID`
* `ARM_CLIENT_SECRET` / `AZURE_CLIENT_SECRET`
* `ARM_SUBSCRIPTION_ID` / `AZURE_SUBSCRIPTION_ID`
* `ARM_TENANT_ID` / `AZURE_TENANT_ID`

---

## How it Works (CI/CD Flow)

1.  **Code Push**: Any push to the `main` branch triggers the deployment.
2.  **Infrastructure Provisioning**:
    * `terraform init`: Initializes providers and backend.
    * `terraform apply`: Provisions the Resource Group, ADLS Gen2, and ADF.
3.  **Data Quality Gate (Python)**:
    * The pipeline captures the generated Storage Account name via Terraform Outputs.
    * A Python script authenticates via the Service Principal.
    * It validates that the `raw-data` container exists and is reachable.

---

##  Data Quality Health Check

The project includes a custom Python validator (`scripts/check_data_lake.py`). This script ensures that the infrastructure isn't just "running," but actually "functional" for data workloads.

```python
# Validation Logic example
credential = DefaultAzureCredential()
service_client = BlobServiceClient(account_url, credential=credential)
container_client = service_client.get_container_client("raw-data")
# Result: SUCCESS or FAILURE (Stops the pipeline)
```

---

## Cleanup & FinOps

To avoid unnecessary costs, a **manual cleanup workflow** is included.
1. Go to the **Actions** tab in GitHub.
2. Select **Azure DataOps Cleanup**.
3. Click **Run workflow**.

This executes `terraform destroy`, removing all provisioned resources in one click.

---

## Key Learnings

* **RBAC Management**: Implementing the principle of least privilege using Service Principals.
* **State Management**: Understanding the importance of Terraform State in CI/CD environments.
* **Resource Provider Registration**: Managing Azure service activation (`Microsoft.Storage`, `Microsoft.DataFactory`).
* **Identity Alignment**: Syncing authentication between Terraform (ARM variables) and Python SDKs (AZURE variables).

---

### Author
**Badis Merakchi** - *Cloud & Infrastructure Engineer.*
