terraform {
  required_version = ">= 0.14.0"
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "~> 2023.8.0"
    }
  }
}

provider "authentik" {
  token = var.authentik_token
  url   = var.authentik_url
  insecure = var.environment != "prod" ? true : false
}

resource "authentik_service_connection_kubernetes" "local" {
  name  = "local"
  local = true
}

resource "authentik_group" "cluster_admins" {
  name         = "cluster-admins"
  is_superuser = false
}
