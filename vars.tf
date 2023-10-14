variable "doppler_token" {
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
