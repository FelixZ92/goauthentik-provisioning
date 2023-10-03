resource "authentik_flow" "github_source_enrollment" {
  designation = "enrollment"
  name        = "Welcome to authentik!"
  slug        = "github-source-enrollment"
  title       = "Welcome to authentik!"
  authentication = "none"
  denied_action = "message_continue"
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

resource "authentik_policy_binding" "github_enrollment_flow_check_org" {
  order  = 0
  target = authentik_flow.github_source_enrollment.uuid
  policy = authentik_policy_expression.check_github_org.id
  timeout = 30
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

resource "authentik_policy_expression" "source_enrollment_add_to_cluster_groups" {
  expression = file("./add_to_groups.py")
  name       = "github-source-enrollment-add-to-cluster-groups"
  execution_logging = true
}

resource "authentik_policy_binding" "github_enrollment_add_to_cluster_groups" {
  order  = 0
  target = authentik_flow_stage_binding.github_enrollment_write.id
  policy = authentik_policy_expression.source_enrollment_add_to_cluster_groups.id
  timeout = 30
}

resource "authentik_flow_stage_binding" "github_enrollment_login" {
  order  = 2
  stage  = data.authentik_stage.default_source_enrollment_login.id
  target = authentik_flow.github_source_enrollment.uuid
}
