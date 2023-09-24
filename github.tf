data "authentik_flow" "default-authentication-flow" {
  slug = "default-authentication-flow"
}

data "authentik_flow" "default-enrollment-flow" {
  slug = "default-source-enrollment"
}

resource "authentik_source_oauth" "github_app" {
  authentication_flow = data.authentik_flow.default-authentication-flow.id
  consumer_key        = var.github_app_client_id
  consumer_secret     = var.github_app_client_secret
  enrollment_flow     = data.authentik_flow.default-enrollment-flow.id
  additional_scopes = "read:org"
  name                = "Github"
  provider_type       = "github"
  slug                = "github"
}
