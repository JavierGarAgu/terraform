terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.3"
    }


  }
}

provider "azurerm" {
  features {}
}
