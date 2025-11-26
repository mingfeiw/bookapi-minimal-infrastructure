# BookAPI Minimal Infrastructure

Infra and automation for BookAPI on Azure with Azure Key Vault integration and workload identity.

## Terraform
To deploy infrastructure:
```powershell
terraform init
terraform plan
terraform apply
```

---

## Helm
`bookapi-chart` contains:
- `Chart.yaml`: Chart metadata
- `values.yaml`: Configuration (image, resources, workload identity)
- `templates/deployment.yaml`: Deployment with service account
- `templates/service.yaml`: LoadBalancer service
- `templates/ingress.yaml`: NGINX ingress
- `templates/serviceaccount.yaml`: Workload identity service account
- `templates/_helpers.tpl`: Template helpers

To deploy with Helm:
```powershell
# Get workload identity client ID
CLIENT_ID=$(terraform output -raw workload_identity_client_id)

# Deploy with workload identity
helm upgrade --install bookapi bookapi-chart --namespace bookapi --create-namespace --set workloadIdentity.clientId=$CLIENT_ID
```

---

## Workflow
1. **Infrastructure**: Terraform provisions Azure resources including Key Vault with workload identity
2. **Secrets**: Database connection string automatically stored in Key Vault
3. **Build**: Docker image built and pushed to Azure Container Registry (ACR)
4. **Authentication**: Azure CLI authenticates and fetches AKS credentials
5. **Deploy**: Helm deploys BookAPI to AKS with workload identity configuration
6. **Runtime**: Application securely accesses Key Vault using workload identity
7. **Monitoring**: kubectl for troubleshooting and pod inspection
8. **Automation**: Complete CI/CD pipeline via GitHub Actions with OIDC authentication

---

## Security and Traffic Flow
1. Request hits Application Gateway (`appgw-subnet`, public IP, see `gateway.tf`).
2. NSG (`nsg.tf`) allows inbound traffic on port 80 to the gateway.
3. Application Gateway (with TLS/WAF, Key Vault certs) forwards traffic to AKS (`aks-subnet`).
4. NSG allows traffic to AKS on port 80.
5. Ingress (`bookapi-chart/templates/ingress.yaml`, `values.yaml`) in AKS routes request to BookAPI pods.
6. Internal traffic uses private IPs (`vnet.tf` for address space and subnet definitions); DNS (`dns.tf`) resolves services; RBAC (`role_assign.tf`) controls access.

---

## Identity & Access
- **GitHub Actions OIDC**: Federated credentials for CI/CD (`aad_oidc.tf`, `role_assign.tf`)
- **Service Principal**: Azure AD app registration (`aad_oidc.tf`)
- **AKS Workload Identity**: Pod-to-Azure authentication (`main.tf`, `role_assign.tf`)
  - User-assigned managed identity: `bookapi-workload-identity`
  - Federated identity credential for Kubernetes service account
  - Service account: `bookapi-service-account` with workload identity annotation

---

## Observability
- Logs/metrics: Log Analytics & App Insights (`data.tf`)
- Key Vault diagnostics (`keyvault.tf`)

---

## Azure Key Vault Integration
The application securely accesses database credentials from Azure Key Vault using workload identity:

### Key Vault Setup (`keyvault.tf`, `sql.tf`):
- **Key Vault**: `kv-bookapi` with network access enabled
- **Secrets Stored**:
  - `sql-admin-password`: Auto-generated SQL admin password
  - `DbConnectionString`: Complete database connection string
- **Access Policies**: 
  - GitHub Actions service principal (full access)
  - Current user (full access)
  - Workload identity (Get secrets only)

### How It Works:
1. Pod runs with `bookapi-service-account` service account
2. Service account has workload identity annotation with client ID
3. Workload identity links to Azure managed identity
4. `DefaultAzureCredential()` automatically uses workload identity to authenticate
5. Application successfully retrieves secrets from Key Vault

---

## Cost Optimization
- **Log Analytics**: `PerGB2018` SKU, 30-day retention (`data.tf`)
- **Storage**: GRS replication (`storage.tf`)
- **AKS**: Single replica by default (`bookapi-chart/values.yaml`)
- **Application Gateway**: `Standard_v2` SKU (`gateway.tf`)
- **Key Vault**: `standard` SKU with minimal access policies (`keyvault.tf`)
- **Workload Identity**: No additional cost - uses Azure AD managed identities
- **Container Registry**: Basic SKU (`main.tf`)
- Basic/standard SKUs used where possible to minimize costs

## Outputs
Key Terraform outputs for integration:
- `workload_identity_client_id`: Client ID for Helm deployment
- `app_gateway_public_ip`: Public endpoint for application access
- `tenant_id` & `subscription_id`: Azure environment details

