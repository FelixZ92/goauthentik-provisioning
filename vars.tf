variable "authentik_token" {
  default = ""
  sensitive = true
}

variable "authentik_url" {
  default = ""
}

variable "environment" {
  default = "staging"
}

variable "base_domain" {
  default = ""
}

variable "grafana_client_secret" {
  default = ""
  sensitive = true
}

variable "github_app_client_secret" {
  default = ""
  sensitive = true
}

variable "github_app_client_id" {
  default = ""
  sensitive = true
}
