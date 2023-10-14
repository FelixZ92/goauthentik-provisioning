data "doppler_secrets" "github" {
  config = "${var.environment}_github-application"
  project = "infrastructure"
}

resource "authentik_source_oauth" "github_app" {
  authentication_flow = authentik_flow.github_flow.uuid
  consumer_key        = data.doppler_secrets.github.map.CLIENT_ID
  consumer_secret     = data.doppler_secrets.github.map.CLIENT_SECRET
  enrollment_flow     = authentik_flow.github_source_enrollment.uuid
  additional_scopes = "read:org"
  name                = "Github"
  provider_type       = "github"
  slug                = "github"
}
