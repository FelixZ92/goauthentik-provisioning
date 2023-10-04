resource "authentik_source_oauth" "github_app" {
  authentication_flow = authentik_flow.github_flow.uuid
  consumer_key        = var.github_app_client_id
  consumer_secret     = var.github_app_client_secret
  enrollment_flow     = authentik_flow.github_source_enrollment.uuid
  additional_scopes = "read:org"
  name                = "Github"
  provider_type       = "github"
  slug                = "github"
}
