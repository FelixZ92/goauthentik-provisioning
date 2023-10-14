terraform {
  required_version = ">= 0.14.0"
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "~> 2023.8.0"
    }
    doppler = {
      source = "DopplerHQ/doppler"
      version = "1.3.0"
    }
  }
}

provider "doppler" {
  doppler_token = var.doppler_token
}

data "doppler_secrets" "authentik" {
  config = "${var.environment}_authentik"
  project = "infra"
}

provider "authentik" {
  token = data.doppler_secrets.authentik.map.AUTHENTIK_BOOTSTRAP_TOKEN
  url   = var.authentik_url
}

resource "authentik_service_connection_kubernetes" "local" {
  name  = "local"
  local = true
}

resource "authentik_group" "cluster_admins" {
  name         = "cluster-admins"
  is_superuser = false
}
