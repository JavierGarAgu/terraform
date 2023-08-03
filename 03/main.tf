# Define an Azure Resource Group to group related resources together
resource "azurerm_resource_group" "rg" {
  name     = "example-resources"       # Name of the Resource Group to create in Azure
  location = "West Europe"             # Geographic location where the Resource Group will be created
}

# Create a Linux App Service Plan in Azure
resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp-${random_integer.ri.result}"  # Name of the App Service Plan
  location            = azurerm_resource_group.rg.location       # Location of the Resource Group
  resource_group_name = azurerm_resource_group.rg.name            # Name of the Resource Group
  os_type             = "Linux"                                  # Specify the operating system as Linux
  sku_name            = "B1"                                     # Specify the SKU for the App Service Plan (B1: Basic)
}

# Create a Linux web app and associate it with the App Service Plan
resource "azurerm_linux_web_app" "webapp" {
  depends_on           = [azurerm_mssql_database.db]             # Define a dependency on the "azurerm_mssql_database.db" resource
  name                 = "webapp-${random_integer.ri.result}"    # Name of the web app
  location             = azurerm_resource_group.rg.location       # Location of the Resource Group
  resource_group_name  = azurerm_resource_group.rg.name            # Name of the Resource Group
  service_plan_id      = azurerm_service_plan.appserviceplan.id   # ID of the associated App Service Plan

  site_config {
    application_stack {
      python_version = "3.9"                                       # Specify the version of Python to be used
    }
  }

  # Configure environment variables (app_settings) for the web app
  app_settings = {
    "SERVER"   = azurerm_mssql_server.server.fully_qualified_domain_name  # Database server address
    "DB"       = var.database                                            # Database name (defined in the variables.tf file)
    "USER"     = var.user                                                # Database user (defined in the variables.tf file)
    "PASSWORD" = var.password                                            # Database user password (defined in the variables.tf file)
  }
}

# Configure source control for the web app from GitHub
resource "azurerm_app_service_source_control" "example" {
  app_id   = azurerm_linux_web_app.webapp.id                         # ID of the web app to apply source control to
  repo_url = "https://github.com/JavierGarAgu/03webapp"              # URL of the GitHub repository for the web app
  branch   = "master"                                               # Specify the branch of the repository to use
}

# Create an Azure SQL Server
resource "azurerm_mssql_server" "server" {
  name                         = var.servername                      # Name of the SQL Server (defined in the variables.tf file)
  location                     = azurerm_resource_group.rg.location # Location of the Resource Group
  resource_group_name          = azurerm_resource_group.rg.name      # Name of the Resource Group
  administrator_login          = var.user                            # SQL Server administrator login name (defined in the variables.tf file)
  administrator_login_password = var.password                        # SQL Server administrator login password (defined in the variables.tf file)
  version                      = "12.0"                              # Specify the version of the SQL Server
}

# Create an Azure SQL Database on the SQL Server
resource "azurerm_mssql_database" "db" {
  name      = var.database                                          # Name of the database (defined in the variables.tf file)
  server_id = azurerm_mssql_server.server.id                         # ID of the SQL Server to associate the database with

  collation                   = "SQL_Latin1_General_CP1_CI_AS"       # Database collation setting
  auto_pause_delay_in_minutes = 60                                   # Time to wait before pausing the database
  max_size_gb                 = 1                                    # Maximum size of the database (1 GB)
  min_capacity                = 0.5                                  # Minimum capacity of the database
  read_replica_count          = 0                                    # Number of read replicas
  read_scale                  = false                                # Read scale setting
  sku_name                    = "GP_S_Gen5_1"                        # SKU for the database
  zone_redundant              = false                                # Zone-redundant setting

  # Provisioner to run the "sqlcmd" command locally and execute the SQL script in the database during creation
  provisioner "local-exec" {
    command = "sqlcmd -U ${var.user} -P ${var.password} -S ${azurerm_mssql_server.server.fully_qualified_domain_name} -d ${var.database} -i coches.sql"
  }
}

# Firewall rule to allow access from any Azure Resource
resource "azurerm_mssql_firewall_rule" "azureresources" {
  name          = "azurerecourses"
  server_id     = azurerm_mssql_server.server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Firewall rule to allow access from a specific IP address (replace with your own public IP address)
resource "azurerm_mssql_firewall_rule" "mypublicip" {
  name          = "mypublicip"
  server_id     = azurerm_mssql_server.server.id
  start_ip_address = "yourpublicip"
  end_ip_address   = "yourpublicip"
}











