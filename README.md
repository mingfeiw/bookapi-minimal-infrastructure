# bookapi-minimal-infrastructure

Terraform code and GitHub Actions workflow to provision Azure infrastructure and deploy BookAPI.

## Resources Provisioned
- Azure Key Vault
- Azure Storage Account
- AKS Cluster & Namespace
- Kubernetes Secrets

## CI/CD
- Lints Dockerfile and Terraform
- Builds and pushes Docker image to ACR
- Applies Terraform for infrastructure

## Usage
1. Set required variables in `terraform.tfvars`.
2. Set up GitHub Secrets for Azure authentication.
3. Push to `main` branch to trigger pipeline.