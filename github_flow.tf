# TODO: add policy to enrollment flow
resource "authentik_flow" "github_flow" {
  designation = "authentication"
  name        = "Welcome to authentik!"
  slug        = "github-source-authentication"
  title       = "Welcome to authentik!"
  authentication = "require_unauthenticated"
  denied_action = "message"
}

resource "authentik_policy_expression" "github_flow_is_sso" {
  expression = "return ak_is_sso_flow"
  name       = "github_flow_is_sso"
  execution_logging = true
}

resource "authentik_policy_binding" "github_flow_is_sso" {
  order  = 0
  target = authentik_flow.github_flow.uuid
  policy = authentik_policy_expression.github_flow_is_sso.id
  timeout = 30
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
  order  = 0
  target = authentik_flow_stage_binding.github_flow_login_binding.id
  policy = authentik_policy_expression.check_github_org.id
  timeout = 30
}

resource "authentik_flow" "github_source_enrollment" {
  designation = "enrollment"
  name        = "Welcome to authentik!"
  slug        = "github-source-enrollment"
  title       = "Welcome to authentik!"
  authentication = "none"
  denied_action = "message_continue"
}

resource "authentik_policy_binding" "github_enrollment_flow_is_sso" {
  order  = 0
  target = authentik_flow.github_source_enrollment.uuid
  policy = authentik_policy_expression.github_flow_is_sso.id
  timeout = 30
}

data "authentik_stage" "default_source_enrollment_prompt" {
  name = "default-source-enrollment-prompt"
}

data "authentik_stage" "default_source_enrollment_write" {
  name = "default-source-enrollment-write"
}

data "authentik_stage" "default_source_enrollment_login" {
  name = "default-source-enrollment-login"
}

resource "authentik_flow_stage_binding" "github_enrollment_prompt" {
  order  = 0
  stage  = data.authentik_stage.default_source_enrollment_prompt.id
  target = authentik_flow.github_source_enrollment.uuid
}

resource "authentik_policy_expression" "source_enrollment_if_username" {
  expression = "return 'username' not in context.get('prompt_data', {})"
  name       = "github-source-enrollment-if-username"
}

resource "authentik_policy_binding" "github_enrollment_prompt_if_username" {
  order  = 0
  target = authentik_flow_stage_binding.github_enrollment_prompt.id
  policy = authentik_policy_expression.source_enrollment_if_username.id
  timeout = 30
}

resource "authentik_flow_stage_binding" "github_enrollment_write" {
  order  = 1
  stage  = data.authentik_stage.default_source_enrollment_write.id
  target = authentik_flow.github_source_enrollment.uuid
}

resource "authentik_flow_stage_binding" "github_enrollment_login" {
  order  = 2
  stage  = data.authentik_stage.default_source_enrollment_login.id
  target = authentik_flow.github_source_enrollment.uuid
}

resource "authentik_policy_binding" "github_enrollment_flow_check_org" {
  order  = 1
  target = authentik_flow_stage_binding.github_enrollment_write.id
  policy = authentik_policy_expression.check_github_org.id
  timeout = 30
}
