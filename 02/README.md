# Terraform Project: Azure Load Balancer Setup

This Terraform project automates the setup of an Azure Load Balancer with NAT rules, network interfaces, virtual machines, and Nginx installation on the virtual machines.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- Azure subscription and appropriate permissions

## Usage

1. Clone this repository to your local machine.

2. Update the `main.tf` file with your specific configurations and values.

3. Open a terminal and navigate to the project directory.

4. Initialize the Terraform project:

   
   `terraform init`

5.  Review the changes that will be applied:
    
    
    `terraform plan` 
    
6.  Apply the changes:
    
    
    `terraform apply` 
    

This will create an Azure Load Balancer with NAT rules, network interfaces, virtual machines, and install Nginx on the virtual machines according to your configurations.

To destroy the resources:

`terraform destroy -auto-approve` 

## Project Structure

-   `main.tf`: Defines the main resources including load balancer, NAT rules, network interfaces, virtual machines, and Nginx installation.
-   `providers.tf`: Configures the required providers.
-   `html`: Folder with the necessary files for the webpage.
-   `scripts`: Folder with the necessary scripts.
-   `outputs.tf`: File with outputs .
-   `variables.tf`: File with variables.

## Configuration

Modify the values in `main.tf` to match your specific requirements.

## Architecture Overview

This project sets up the following components:

-   An Azure Resource Group
-   An Azure Virtual Network with Subnet
-   An Azure Public IP
-   An Azure Load Balancer
-   NAT rules for SSH access to virtual machines
-   Azure Network Interfaces
-   Azure Virtual Machines with Nginx installation
-   Azure Virtual Machine Extensions for Nginx setup

## Security Considerations

-   **Sensitive Information**: Ensure that sensitive information such as usernames, passwords, and authentication tokens are stored securely and not hard-coded in the configuration files. Consider using environment variables or secure key management solutions.
-   **Network Security**: Review and configure network security rules to restrict incoming and outgoing traffic to the necessary ports and protocols only.

## Note

Make sure to handle sensitive information securely, especially when dealing with authentication credentials and private keys.

## Troubleshooting

If you encounter any issues or errors during the Terraform deployment, refer to the Terraform documentation and Azure portal for troubleshooting steps and resources.
- **Note** I have a problem when I try to deploy with debian: https://stackoverflow.com/questions/76841139/azurerm-virtual-machine-extension-never-finish-in-terraform-with-debian-vm
 

