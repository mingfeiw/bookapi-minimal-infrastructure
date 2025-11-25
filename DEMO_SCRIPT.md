# BookAPI Azure Infrastructure Demo Script

## Introduction (2-3 minutes)
**"Hello everyone, today I'll be demonstrating a production-ready cloud infrastructure solution I've built for deploying a BookAPI application on Microsoft Azure. This showcases modern DevOps practices, cloud-native architecture, and enterprise-grade security."**

### What We'll Cover:
- **Infrastructure as Code** using Terraform
- **Containerized deployment** with Docker and Kubernetes
- **Enterprise security** with Application Gateway and NSGs
- **GitOps CI/CD** automation
- **Cost optimization** strategies

---

## Demo Architecture Overview (3-4 minutes)

### "Let me show you the architecture we've built..."

**[Show architecture diagram or navigate through files]**

```
Internet → Application Gateway (Public IP) → AKS Cluster → BookAPI Pods
    ↓              ↓                    ↓           ↓
   TLS/WAF    Key Vault Certs    Private Network   ACR Images
```

### Key Components:
1. **Azure Resource Group** - Centralized resource management
2. **AKS (Azure Kubernetes Service)** - Managed Kubernetes cluster
3. **Application Gateway** - Layer 7 load balancer with WAF
4. **Azure Container Registry** - Private Docker registry
5. **Key Vault** - Certificate and secrets management
6. **Virtual Network** - Isolated network with subnets
7. **Log Analytics** - Monitoring and observability

**"What makes this special is the security-first approach and complete automation."**

---

## Infrastructure Provisioning Demo (5-6 minutes)

### 1. Terraform Infrastructure as Code
**"First, let's look at how we define our infrastructure as code..."**

```powershell
# Show the Terraform files structure
ls *.tf
```

**Key files to highlight:**
- `main.tf` - Core AKS and ACR resources
- `vnet.tf` - Network architecture
- `gateway.tf` - Application Gateway with TLS
- `keyvault.tf` - Security and certificate management
- `aad_oidc.tf` - GitHub Actions authentication

```powershell
# Initialize and plan
terraform init
terraform plan
```

**"Notice how we're using:"**
- **Modular design** - Each service in its own file
- **Security by default** - Private subnets, NSGs, TLS
- **Cost optimization** - Basic SKUs where appropriate

### 2. Deploy Infrastructure
```powershell
terraform apply -auto-approve
```

**"This creates approximately 20+ Azure resources in about 8-10 minutes, including:"**
- AKS cluster with system-assigned identity
- Application Gateway with WAF protection
- Virtual network with proper subnet segmentation
- Container registry for our Docker images
- Key Vault for certificate management

---

## Security & Traffic Flow Demonstration (4-5 minutes)

### "Let's examine the security layers..."

**[Navigate through security configuration files]**

### Traffic Flow Walkthrough:
1. **External Request** → `gateway.tf` (Public IP, port 443/80)
2. **NSG Filtering** → `nsg.tf` (Allow specific ports only)
3. **Application Gateway** → TLS termination, WAF protection
4. **AKS Ingress** → Internal routing to pods
5. **Pod Communication** → Private network only

```powershell
# Show NSG rules
az network nsg rule list --resource-group rg-bookapi-minimal --nsg-name nsg-bookapi-minimal --output table
```

### Security Features:
- **TLS encryption** end-to-end
- **Web Application Firewall** protection
- **Network segmentation** with private subnets
- **Identity-based access** with RBAC
- **Certificate automation** via Key Vault

---

## Container & Kubernetes Deployment (4-5 minutes)

### 1. Container Registry
**"Our Docker images are stored securely in Azure Container Registry..."**

```powershell
# Show ACR contents
az acr repository list --name acrbookapi
```

### 2. Helm Chart Structure
**"We use Helm for Kubernetes deployments - let's look at our chart..."**

```powershell
# Show Helm chart structure
tree bookapi-chart
```

**Key components:**
- `Chart.yaml` - Chart metadata
- `values.yaml` - Configuration parameters
- `templates/` - Kubernetes manifests

### 3. Deploy to AKS
```powershell
# Get AKS credentials
az aks get-credentials --resource-group rg-bookapi-minimal --name aks-bookapi-minimal

# Deploy with Helm
helm install bookapi bookapi-chart --namespace bookapi --create-namespace

# Verify deployment
kubectl get pods -n bookapi
kubectl get services -n bookapi
kubectl get ingress -n bookapi
```

---

## Observability & Monitoring (2-3 minutes)

### "Built-in monitoring and logging..."

```powershell
# Show Log Analytics workspace
az monitor log-analytics workspace list --output table

# View container insights
kubectl top nodes
kubectl top pods -n bookapi
```

### Monitoring Stack:
- **Log Analytics** - Centralized logging
- **Application Insights** - APM and telemetry
- **Container Insights** - Kubernetes monitoring
- **Key Vault diagnostics** - Security audit logs

---

## CI/CD Automation (3-4 minutes)

### "Everything we just did manually is automated via GitHub Actions..."

**[Show GitHub Actions workflow or explain the automation]**

### Automated Pipeline:
1. **Code push** triggers workflow
2. **Terraform plan/apply** - Infrastructure updates
3. **Docker build/push** - Image creation and registry push
4. **Helm deployment** - Application deployment
5. **Health checks** - Verify deployment success

### OIDC Authentication:
- **No stored secrets** - Uses federated credentials
- **Just-in-time access** - Temporary tokens
- **Audit trail** - All actions logged

---

## Cost Optimization Highlights (2-3 minutes)

### "This solution is designed for cost efficiency..."

### Cost Optimization Strategies:
- **Basic/Standard SKUs** where performance allows
- **Single AKS node** for development (scales as needed)
- **Log retention** optimized (30 days)
- **GRS storage** for balance of cost/availability
- **Resource tagging** for cost tracking

```powershell
# Show current costs (if available)
az consumption usage list --output table
```

---

## Live Application Demo (2-3 minutes)

### "Let's see our BookAPI in action..."

```powershell
# Get the application URL
kubectl get ingress -n bookapi

# Test the API
curl http://bookapi.internal.local/api/books
# Or show in browser if accessible
```

### API Endpoints:
- `GET /api/books` - List all books
- `GET /api/books/{id}` - Get specific book
- `POST /api/books` - Create new book
- Health check endpoints

---

## Troubleshooting & Operations (2-3 minutes)

### "Here's how we handle operations and troubleshooting..."

```powershell
# Pod inspection
kubectl describe pod -n bookapi [pod-name]

# Logs viewing
kubectl logs -n bookapi -l app=bookapi --tail=50

# Resource monitoring
kubectl get events -n bookapi --sort-by='.lastTimestamp'

# Scale applications
helm upgrade bookapi bookapi-chart --set replicaCount=3
```

---

## Questions & Summary (3-5 minutes)

### Key Takeaways:
1. **Infrastructure as Code** - Repeatable, version-controlled infrastructure
2. **Security-First Design** - Multiple layers of protection
3. **Complete Automation** - From code to production
4. **Cost Optimized** - Enterprise features at minimal cost
5. **Production Ready** - Monitoring, logging, and operational tools

### Technologies Demonstrated:
- **Terraform** - Infrastructure provisioning
- **Azure Kubernetes Service** - Container orchestration
- **Application Gateway** - Load balancing and WAF
- **Helm** - Kubernetes package management
- **GitHub Actions** - CI/CD automation
- **Azure Container Registry** - Container image management

**"This architecture can handle production workloads while maintaining security, scalability, and cost efficiency. The entire solution is codified and can be deployed to any Azure region in under 15 minutes."**

---

## Demo Commands Quick Reference

```powershell
# Terraform
terraform init && terraform plan && terraform apply

# AKS Connection
az aks get-credentials --resource-group rg-bookapi-minimal --name aks-bookapi-minimal

# Helm Deployment
helm install bookapi bookapi-chart --namespace bookapi --create-namespace

# Kubernetes Operations
kubectl get all -n bookapi
kubectl logs -n bookapi -l app=bookapi
kubectl describe ingress -n bookapi

# Monitoring
kubectl top nodes
kubectl top pods -n bookapi
az monitor metrics list --resource [resource-id]
```

---

## Preparation Checklist
- [ ] Ensure Azure CLI is authenticated
- [ ] Terraform is initialized
- [ ] Docker image is built and pushed to ACR
- [ ] AKS cluster is running
- [ ] Application is deployed and healthy
- [ ] Have backup slides/screenshots ready
- [ ] Test all demo commands beforehand
