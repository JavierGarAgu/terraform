## Terraform Project: Azure Web App with Python and Azure SQL Database

This Terraform project sets up an Azure Web App to host a Python web application, along with an Azure SQL Database to store data for the application.

### Prerequisites

Before deploying the project, ensure you have the following prerequisites:

1. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and logged in with the appropriate credentials.
2. [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
3. [mssql-tools](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver15) installed for executing SQL scripts.

### Project Structure

The project contains the following files and directories:

| File / Directory   | Description                                               |
|--------------------|-----------------------------------------------------------|
| main.tf            | The Terraform configuration file. It defines the Azure resources required for the web app and the database. |
| variables.tf       | The Terraform variables file. It defines the variables used in the Terraform configuration.                 |
| outputs.tf       | The Terraform outputs file. It defines the output of URL WebApp.                 |
| coches.sql         | SQL script to create the 'coches' table in the Azure SQL Database.                                           |

### Terraform Resources

The main.tf file contains the following Terraform resources:

| Resource Type                             | Description                                                                                         |
|------------------------------------------|-----------------------------------------------------------------------------------------------------|
| azurerm_resource_group.rg                | This resource creates an Azure resource group. A resource group acts as a logical container for Azure resources and allows you to manage them collectively. |
| random_integer.ri                        | This resource generates a random integer within the specified range. It is used for resource naming to ensure that the resource names are unique for each deployment. |
| azurerm_service_plan.appserviceplan      | This resource creates an Azure App Service Plan. The App Service Plan defines the computing resources and settings for hosting the web app. |
| azurerm_linux_web_app.webapp             | This resource creates an Azure Linux Web App. The Web App will host the Python web application, making it accessible over the internet. |
| azurerm_app_service_source_control.example | This resource connects the web app to a source control repository (e.g., GitHub) for continuous deployment. The web app will automatically update when changes are pushed to the repository. |
| azurerm_mssql_server.server              | This resource creates an Azure SQL Database server. The server will host the Azure SQL Database, where data for the web app will be stored. |
| azurerm_mssql_database.db                | This resource creates an Azure SQL Database. The database will store the 'coches' table data, which will be used by the Python web application. |
| azurerm_mssql_firewall_rule.azureresources | This resource defines a firewall rule for the Azure SQL Database server. The rule allows access from all IP addresses to the database server. |
| azurerm_mssql_firewall_rule.mypublicip   | This resource defines a firewall rule for the Azure SQL Database server. The rule allows access only from a specific public IP address (e.g., your public IP address). |

### Getting Started

Follow these steps to deploy the project:

1. Ensure you have the Azure CLI installed and logged in with the appropriate credentials.
2. Install Terraform on your local machine.
3. Install `mssql-tools` for executing SQL scripts.
4. Clone this repository to your local system.
5. Navigate to the project directory.
6. Update the variables.tf file with your desired values or use the default values.
7. Initialize Terraform: `terraform init`
8. Review the Terraform plan: `terraform plan`
9. Apply the Terraform configuration: `terraform apply`

Once the deployment is successful, you will receive the URL of the deployed web app.
