# Azure Terraform Nginx VM Deployment

This Terraform configuration deploys an Azure virtual machine running Nginx web server. The infrastructure consists of the following components:

- Resource Group: Defines the Azure resource group to contain the resources.
- Virtual Network: Creates a virtual network for the virtual machine.
- Subnet: Defines a subnet within the virtual network.
- Public IP: Allocates a dynamic public IP address for the virtual machine.
- Network Security Group (NSG): Sets up a NSG with inbound rules to allow SSH (port 22) and HTTP (port 80) traffic.
- Network Interface: Configures the network interface of the virtual machine.
- Virtual Machine: Deploys an Azure Linux virtual machine with Debian OS, using a custom script extension to install Nginx.
- Remote-Exec Provisioners: Sets the initial permissions on Nginx's web root directory (/var/www/html) to allow file transfer, and then resets the permissions to a more secure state.

## How to Use

1. Install Terraform and Azure CLI on your local machine.
2. Set up your Azure credentials using `az login`.
3. Clone this repository to your local machine.
4. Navigate to the cloned directory.
5. Create a `terraform.tfvars` file and fill in the required variables (if not already specified in `variables.tf`).
6. Run `terraform init` to initialize the Terraform configuration.
7. Run `terraform plan` to preview the changes that will be made.
8. Run `terraform apply` to apply the changes and create the Azure resources.
9. After the deployment, the public IP address of the VM will be outputted. You can access your Nginx webpage using that IP address.

## Variables

You can customize the deployment using the following variables in `variables.tf`:

- `resource_group_location`: Location of the resource group (default: "eastus").
- `install`: Path to the custom script used for installing Nginx on the virtual machine (default: "scripts/install.sh").
- `output`: Path to the custom script used to prepare the output (default: "scripts/output.sh").
- `prefix`: Prefix for naming resources (default: "jga").
- `resource_group_name`: Name of the resource group (default: "01-VM-Nginx-Webpage").
- `user`: Username of the virtual machine (default: "adminazure").
- `password`: Password of the virtual machine (default: "MyPassword#1234").

## Outputs

The following outputs will be displayed after the deployment:

- `resource_group_name`: Name of the created resource group.
- `public_ip_address`: Public IP address of the deployed virtual machine.
- `admin_password`: Admin password of the virtual machine (sensitive value).
- `nginx_status_output`: Status of Nginx on the Debian virtual machine.

Note: Make sure to handle the `admin_password` securely and avoid exposing it in public repositories.

## License

This Terraform configuration is licensed under the [MIT License](LICENSE).
