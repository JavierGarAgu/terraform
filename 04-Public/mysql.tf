# Manages the MySQL Flexible Server

resource "azurerm_mysql_flexible_server" "default" {
  location                     = azurerm_resource_group.rg.location
  name                         = "mysqlfs-${var.prefix}"
  resource_group_name          = azurerm_resource_group.rg.name
  administrator_login          = var.mysqluser
  administrator_password       = var.mysqlpassword
  backup_retention_days        = 7
  delegated_subnet_id          = azurerm_subnet.mysql.id
  geo_redundant_backup_enabled = false
  private_dns_zone_id          = azurerm_private_dns_zone.default.id
  sku_name                     = "B_Standard_B1s"
  version                      = "8.0.21"
  zone                         = "1"
  maintenance_window {
    day_of_week  = 0
    start_hour   = 8
    start_minute = 0
  }
  storage {
    iops    = 360
    size_gb = 20
  }
  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
}

# Turning "require_secure_transport" to OFF

resource "azurerm_mysql_flexible_server_configuration" "default" {
  name                = "require_secure_transport"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.default.name
  value               = "OFF"

  provisioner "local-exec" {
    command = "az mysql flexible-server restart --name ${azurerm_mysql_flexible_server.default.name} --resource-group ${azurerm_resource_group.rg.name}"
}

}

# Manages the MySQL Flexible Server Database
resource "azurerm_mysql_flexible_database" "main" {
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
  name                = "coches"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.default.name
}
