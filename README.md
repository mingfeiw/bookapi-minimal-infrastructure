# BookAPI Minimal Infrastructure

Complete Azure infrastructure and CI/CD automation for BookAPI using Terraform, AKS, and workload identity for secure Key Vault integration.

## Quick Start

### Prerequisites
- Azure CLI authenticated
- Terraform installed
- kubectl and helm installed
- Configure `terraform.tfvars` with your values

### Bootstrap (First Time Only)
```powershell
# Create backend storage for Terraform state
cd bootstrap
terraform init
terraform apply -auto-approve
cd ..
```

### Deploy Infrastructure
```powershell
terraform init
terraform plan
terraform apply
```

### Deploy Application
```powershell
# Get workload identity client ID and deploy
CLIENT_ID=$(terraform output -raw workload_identity_client_id)
helm upgrade --install bookapi bookapi-chart --namespace bookapi --create-namespace --set workloadIdentity.clientId=$CLIENT_ID
```

---

## Architecture Overview

### Infrastructure Components
- **AKS Cluster**: Single-node cluster with workload identity enabled
- **Application Gateway**: Public-facing load balancer with TLS termination
- **Azure Container Registry**: Private Docker image repository
- **Virtual Network**: Segmented subnets for gateway, AKS, and SQL
- **Key Vault**: Secure secrets storage with workload identity access
- **SQL Database**: Managed database with connection string in Key Vault
- **Log Analytics**: Centralized logging and monitoring

### Network Flow
1. **Internet → Application Gateway** (Public IP, port 80/443)
2. **Application Gateway → AKS** (Internal load balancer)
3. **AKS Ingress → BookAPI Pods** (NGINX ingress controller)
4. **Pods → Key Vault** (Workload identity for secrets)
5. **Pods → SQL Database** (Private connection)

---

## CI/CD Pipeline

### GitHub Actions Workflow (`.github/workflows/deploy.yml`)
The workflow is triggered on pushes to `main` and performs:

1. **Checkout**: Both infrastructure and source repositories
2. **Lint**: Dockerfile validation with hadolint
3. **Azure Login**: OIDC authentication (no secrets stored)
4. **Bootstrap**: Create Terraform backend (if needed)
5. **Infrastructure**: Terraform plan and apply
6. **Build**: Docker image from source repository
7. **Push**: Image to Azure Container Registry
8. **Deploy**: Helm chart with workload identity configuration
9. **Validate**: Pod description for troubleshooting

### Required GitHub Secrets
- `AZURE_CLIENT_ID`: Service principal client ID
- `AZURE_TENANT_ID`: Azure AD tenant ID
- `AZURE_SUBSCRIPTION_ID`: Target subscription ID

---

## Cost Optimization Features
- **Single AKS Node**: Minimal compute resources for development
- **Basic SKUs**: Container Registry, Key Vault use basic tiers
- **30-day Log Retention**: Reduced Log Analytics costs
- **Standard_v2 Gateway**: Right-sized for expected traffic
- **GRS Storage**: Balance between cost and redundancy

---

## File Structure
```
.
├── *.tf                    # Terraform infrastructure modules
├── terraform.tfvars       # Configuration variables
├── backend.tf             # Remote state configuration  
├── bootstrap/             # Backend storage bootstrap
│   └── bootstrap.tf
├── bookapi-chart/         # Helm chart for application
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
└── .github/workflows/     # CI/CD automation
    └── deploy.yml
```
