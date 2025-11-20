# BookAPI Minimal Infrastructure

Infra and automation for BookAPI on Azure.

## Overview
- Terraform: Azure infra
- Helm: AKS deploy
- Docker: Build/push image
- Azure CLI: Auth, AKS creds
- kubectl: K8s ops
- GitHub Actions: CI/CD

---

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
- `Chart.yaml`: Chart info
- `values.yaml`: Config (image, resources, env, service)
- `templates/deployment.yaml`: Deployment (replicas, probes)
- `templates/service.yaml`: Service
- `templates/ingress.yaml`: Ingress (host, TLS)
- `templates/_helpers.tpl`: Helpers

To deploy with Helm:
```powershell
helm install bookapi bookapi-chart --namespace bookapi
# or
helm upgrade bookapi bookapi-chart --namespace bookapi
```

---

## Workflow
1. Use Terraform to provision Azure infrastructure.
2. Build and push the BookAPI Docker image to Azure Container Registry (ACR).
3. Use Azure CLI to authenticate and fetch AKS credentials.
4. Use Helm to deploy BookAPI to AKS.
5. Use kubectl for troubleshooting and inspecting pods.
6. All steps are automated via GitHub Actions for CI/CD, including linting, building, provisioning, and deployment.

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
- OIDC & federated creds for GitHub Actions: `aad_oidc.tf`, `role_assign.tf`
- Service principal: `aad_oidc.tf`, `role_assign.tf`

---

## Observability
- Logs/metrics: Log Analytics & App Insights (`data.tf`)
- Key Vault diagnostics (`keyvault.tf`)

## Cost Optimization
- Log Analytics: `PerGB2018` SKU, 30-day retention (`data.tf`).
- Storage: GRS replication (`storage.tf`).
- AKS: Single replica by default (`bookapi-chart/values.yaml`).
- App Gateway: `Standard_v2` SKU (`gateway.tf`).
- Key Vault: `standard` SKU (`keyvault.tf`).
- Basic/standard SKUs used where possible.

