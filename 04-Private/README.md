# Azure MySQL Private Server and AKS Cluster Project

## Overview

This project involves setting up an Azure MySQL Server and connecting it securely to an AKS (Azure Kubernetes Service) cluster. The aim is to restrict external access to the database by creating a temporary virtual machine responsible for importing SQL content into MySQL.

## File Structure

- `providers.tf`: Terraform providers configuration.
- `vm.tf`: Creation and configuration of the temporary VM.
- `main.tf`: General configuration for Azure and AKS.
- `mysql.tf`: Specific Azure MySQL Server configuration.
- `variables.tf`: Centralized variables.
- `outputs.tf`: Info for AKS connection and verification.
- `coches.sql`: SQL content to import.
- `python`: Custom AKS application on Docker Hub [link](https://hub.docker.com/repository/docker/javiergaragu/04app/general).

## Deployment Steps

1. Install Terraform.
2. Run `terraform init`.
3. Prepare creation plan: `terraform plan -out plancreate`.
4. Execute plan: `terraform apply plancreate`.

**Note**: The deployment proccess can last around 15-30 minutes.

Now you can access to the Public IP provided in the output, you will see the pod hostname and mysql content. if you reload the page you will see that the hostname change.

![webapp](https://github.com/JavierGarAgu/terraform/blob/master/04-Private/images/show.png)

5. Prepare plan for delete the VM: `terraform plan -destroy -target='azurerm_linux_virtual_machine.virtual_machine' -target='azurerm_network_interface.nic' -target='azurerm_network_security_group.nsg' -target='azurerm_public_ip.public_ip' -out vmdestroy`

6. Delete the VM: `terraform apply vmdestroy`

Finally the resources in Aure are:
![Resources](https://github.com/JavierGarAgu/terraform/blob/master/04-Private/images/show2.png)

## Infrastructure Destruction

1. Prepare destruction plan: `terraform plan -destroy -out plandestroy`.
2. Execute plan: `terraform apply plandestroy`.

**Note**: If errors occur during destruction, wait 30 seconds, then retry. MySQL subnet link might need time to clear before deletion.

## Testing and Considerations

Local testing may be limited due to private MySQL server. For local testing, check `04-Public` repository.

## Possible Improvements

- Implement MySQL security best practices.
- Use Azure Key Vault for sensitive data.
- Automate imports with scheduled jobs.
- Extend AKS cluster for scalability.

Feel free to explore enhancements as per your needs.
