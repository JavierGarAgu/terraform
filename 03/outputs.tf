# Url of WebApp.
output "url" {
    value = "${azurerm_linux_web_app.webapp.name}.azurewebsites.net"
}
