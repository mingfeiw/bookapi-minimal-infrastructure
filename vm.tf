resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.github_repo_owner}-runner-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  admin_password                  = var.admin_password
  disable_password_authentication = false
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.bookapi_uami.id]
  }

  custom_data = base64encode(<<EOF
#!/bin/bash
apt-get update
apt-get install -y curl jq docker.io git powershell

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Azure PowerShell
pwsh -Command "Install-Module -Name Az -AllowClobber -Scope AllUsers -Force"

# Register as GitHub self-hosted runner
mkdir actions-runner && cd actions-runner

curl -o actions-runner-linux-x64-2.314.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-linux-x64-2.314.1.tar.gz
tar xzf ./actions-runner-linux-x64-2.314.1.tar.gz

export RUNNER_ALLOW_RUNASROOT=1
./config.sh --url https://github.com/${var.github_repo_owner}/${var.github_repo_name} --token $(curl -s -H "Authorization: token ${var.github_pat}" https://api.github.com/repos/${var.github_repo_owner}/${var.github_repo_name}/actions/runners/registration-token | jq -r .token) --labels azure,managed-identity --name azure-vm-runner-$(hostname) --unattended
./run.sh &
EOF
  )
}