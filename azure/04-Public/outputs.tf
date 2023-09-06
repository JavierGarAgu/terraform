output "azurerm_mysql_flexible_server" {
  value = "${azurerm_mysql_flexible_server.default.name}.mysql.database.azure.com"
}

output "admin_login" {
  value = azurerm_mysql_flexible_server.default.administrator_login
}

output "admin_password" {
  sensitive = true
  value     = azurerm_mysql_flexible_server.default.administrator_password
}

output "mysql_flexible_server_database_name" {
  value = azurerm_mysql_flexible_database.main.name
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "nginx_service_ip" {
  value = kubernetes_service.nginx_service.status.0.load_balancer.0.ingress.0.ip
}
