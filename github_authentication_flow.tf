# TODO: add policy to enrollment flow
resource "authentik_flow" "github_flow" {
  designation = "authentication"
  name        = "Welcome to authentik!"
  slug        = "github-source-authentication"
  title       = "Welcome to authentik!"
  authentication = "require_unauthenticated"
  denied_action = "message_continue"
}

data "authentik_stage" "default_source_authentication_login" {
  name = "default-source-authentication-login"
}

resource "authentik_flow_stage_binding" "github_flow_login_binding" {
  order  = 0
  stage  = data.authentik_stage.default_source_authentication_login.id
  target = authentik_flow.github_flow.uuid
}

resource "authentik_policy_expression" "check_github_org" {
  expression = file("./check_org.py")
  name       = "github_check_organization"
  execution_logging = true
}

resource "authentik_policy_binding" "github_flow_check_org" {
  order  = 10
  target = authentik_flow.github_flow.uuid
  policy = authentik_policy_expression.check_github_org.id
  timeout = 30
}
