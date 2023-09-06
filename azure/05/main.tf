# Domain Information
data "azuread_domains" "default" {
  only_initial = true
}

data "azuread_client_config" "current" {}

locals {
  domain_name = data.azuread_domains.default.domains.0.domain_name
  users       = csvdecode(file("${path.module}/users.csv"))
  groups      = toset(local.users[*].department)
}

# User and Group Creation via CSV

resource "azuread_user" "users" {
  for_each = { for user in local.users : user.first_name => user }

  user_principal_name   = format(
    "%s.%s@%s",
    lower(each.value.first_name),
    lower(each.value.last_name),
    local.domain_name
  )

  password              = "Strong!1234"
  force_password_change = true

  display_name = "${each.value.first_name} ${each.value.last_name}"
# assignable_to_role = true #ONLY AAD PREMIUM
  department   = each.value.department
}

resource "azuread_group" "groups" {
  for_each          = local.groups
  display_name      = each.key
  security_enabled = true
}

# Assign Users to Respective Group from CSV

resource "azuread_group_member" "members" {
  for_each = { for user in local.users : user.first_name => user }

  group_object_id  = azuread_group.groups[each.value.department].id
  member_object_id = azuread_user.users[each.key].id
}

# Resource Group

resource "azurerm_resource_group" "rg" {
  name     = "example-resources"
  location = "West Europe"
}

# Service Plan

resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp-jga"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Application Creation

resource "random_uuid" "app_user_impersonation_scope" {}

resource "azuread_application" "app_reg" {
  provider         = azuread
  display_name     = "webapp_login"
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  feature_tags {
    custom_single_sign_on = true
    enterprise            = true
  }

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access app on behalf of the signed-in user."
      admin_consent_display_name = "Access jgaweb"
      id                         = random_uuid.app_user_impersonation_scope.result
      enabled                    = true
      type                       = "User"
      user_consent_description   = "Allow the application reg to access app on your behalf."
      user_consent_display_name  = "Access jgaweb"
      value                      = "user_impersonation"
    }
  }

  web {
    homepage_url  = "https://jgaweb.azurewebsites.net"
    logout_url    = "https://jgaweb.azurewebsites.net/logout"
    redirect_uris = ["https://jgaweb.azurewebsites.net/.auth/login/aad/callback"]

    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
}

# Linux Web App Creation and Association with App Service Plan

resource "azurerm_linux_web_app" "webapp" {
  name                = "jgaweb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.appserviceplan.id

  site_config {
    application_stack {
      python_version = "3.9"
    }
  }

  auth_settings_v2 {
    auth_enabled             = true
    default_provider         = "aad"
    forward_proxy_convention = "NoProxy"
    require_authentication   = true
    require_https            = true
    unauthenticated_action   = "RedirectToLoginPage"

    active_directory_v2 {
      client_id                  = azuread_application.app_reg.application_id
      tenant_auth_endpoint       = "https://sts.windows.net/${data.azuread_client_config.current.tenant_id}/v2.0"
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
    }
    login {
      token_store_enabled = true
    }
  }
}

# Create Enterprise App from the Previously Created App

resource "azuread_service_principal" "main" {
  application_id               = azuread_application.app_reg.application_id
  app_role_assignment_required = true # When an application is configured to require assignment for users to be able to sign in, users are not allowed to consent to that application.
}

# Assign Read Role to Users

resource "azuread_app_role_assignment" "webapp" {
  for_each = azuread_user.users

  app_role_id         = "00000000-0000-0000-0000-000000000000" # The default role for access to the web app.
  principal_object_id = each.value.id
  resource_object_id  = azuread_service_principal.main.id
}
