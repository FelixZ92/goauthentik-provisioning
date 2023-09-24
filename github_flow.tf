resource "authentik_flow" "github_flow" {
  designation = "authentication"
  name        = "Welcome to authentik!"
  slug        = "github-source-authentication"
  title       = "Welcome to authentik!"
  authentication = "require_unauthenticated"
}

resource "authentik_policy_expression" "github_flow_is_sso" {
  expression = "return ak_is_sso_flow"
  name       = "github_flow_is_sso"
}

resource "authentik_policy_binding" "github_flow_is_sso" {
  order  = 0
  target = authentik_flow.github_flow.uuid
  policy = authentik_policy_expression.github_flow_is_sso.id
  timeout = 30
}
