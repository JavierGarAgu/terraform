# Generate random resource group name

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.prefix
}

# Manages the Virtual Network

# AKS Virtual Network

resource "azurerm_virtual_network" "aks" {
  address_space       = ["172.16.0.0/16"]
  location            = azurerm_resource_group.rg.location
  name                = "vnet-aks"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "aks" {
  address_prefixes     = ["172.16.0.0/16"]
  name                 = "subnetaks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.aks.name
  depends_on = [azurerm_virtual_network.aks]
}

# MYSQL Virtual Network

resource "azurerm_virtual_network" "default" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  name                = "vnet-${var.prefix}"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "default" {
  address_prefixes     = ["10.0.4.0/24"]
  name                 = "subnetvm"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.default.name
  depends_on = [azurerm_virtual_network.default]
}

resource "azurerm_subnet" "mysql" {
  address_prefixes     = ["10.0.2.0/24"]
  name                 = "subnet-${var.prefix}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.default.name
  service_endpoints    = ["Microsoft.Storage"]
  depends_on = [azurerm_virtual_network.default]
  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Vnet Peering

resource "azurerm_virtual_network_peering" "initiator_to_target" {

  name                         = "ab"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.default.name
  remote_virtual_network_id    = azurerm_virtual_network.aks.id
  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "target_to_initiator" {

  name                         = "ba"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.aks.name
  remote_virtual_network_id    = azurerm_virtual_network.default.id
  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}


# Enables you to manage Private DNS zones within Azure DNS
resource "azurerm_private_dns_zone" "default" {
  name                = "${var.prefix}.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

# Enables you to manage Private DNS zone Virtual Network Links
resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "mysqlfsVnetZone${var.prefix}.com"
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_id    = azurerm_virtual_network.default.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
  name                  = "aksjga"
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_id    = azurerm_virtual_network.aks.id
}

# AKS Cluster creation

resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = "aks-cluster"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-cluster"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.aks.id
  }
  identity {
    type = "SystemAssigned"
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.cluster_ca_certificate)
}

resource "kubernetes_namespace" "test_ns" {
  metadata {
    name = "test"
  }
}

resource "kubernetes_deployment" "web_app_deployment" {
  metadata {
    name      = "hostname-test"
    namespace = kubernetes_namespace.test_ns.metadata.0.name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "hostname-test"
      }
    }

    template {
      metadata {
        labels = {
          app = "hostname-test"
        }
      }

      spec {
        container {
          name  = "hostname-test"
          image = "javiergaragu/04app"

         port {
            name           = "port-5000"
            container_port = 5000
          }

          env {
            name = "MYSQLSERVER"
            value = "${azurerm_mysql_flexible_server.default.name}.mysql.database.azure.com"
          }

          env {
            name = "MYSQLUSER"
            value = azurerm_mysql_flexible_server.default.administrator_login
          }

          env {
            name = "MYSQLPASSWD"
            value = azurerm_mysql_flexible_server.default.administrator_password
          }

          env {
            name = "MYSQLDB"
            value = azurerm_mysql_flexible_database.main.name
          }


        }
      }
    }
  }
}


resource "kubernetes_service" "nginx_service" {
  metadata {
    name      = "test"
    namespace = kubernetes_namespace.test_ns.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.web_app_deployment.spec.0.template.0.metadata.0.labels.app
    }
    port {
      port        = 80
      target_port = 5000
    }
    type = "LoadBalancer"
  }
}






