data "authentik_flow" "default-source-authentication-flow" {
  slug = "default-source-authentication"
}

data "authentik_flow" "default-enrollment-flow" {
  slug = "default-source-enrollment"
}

resource "authentik_flow" "google_enrollment_flow" {
  designation = "enrollment"
  name        = "Welcome to authentik!"
  slug        = "google-source-enrollment"
  title       = "Welcome to authentik!"
  authentication = "none"
  denied_action = "message_continue"
}

resource "authentik_policy_expression" "google_source_enrollment_is_sso" {
  expression = "return ak_is_sso_flow"
  name       = "google-source-enrollment-is-sso"
}

resource "authentik_flow_stage_binding" "google_source_enrollment_write" {
  order  = 10
  stage  = data.authentik_stage.default_source_enrollment_write.id
  target = authentik_flow.google_enrollment_flow.uuid
}

resource "authentik_policy_expression" "google_source_enrollment_force_email" {
  expression = file("./google_force_email.py")
  name       = "google-source-enrollment-force-email"
}

resource "authentik_policy_binding" "google_source_enrollment_force_email" {
  order  = 0
  target = authentik_flow.google_enrollment_flow.uuid
  policy = authentik_policy_expression.google_source_enrollment_force_email.id
}

resource "authentik_flow_stage_binding" "google_source_enrollment_login" {
  order  = 20
  stage  = data.authentik_stage.default_source_enrollment_login.id
  target = authentik_flow.google_enrollment_flow.uuid
}

data "doppler_secrets" "google" {
  config = "${var.environment}_google-oauth"
  project = "infrastructure"
}

resource "authentik_source_oauth" "google_source" {
  authentication_flow = data.authentik_flow.default-source-authentication-flow.id
  consumer_key        = data.doppler_secrets.google.map.CLIENT_ID
  consumer_secret     = data.doppler_secrets.google.map.CLIENT_SECRET
  enrollment_flow     = authentik_flow.google_enrollment_flow.uuid
  name                = "google"
  provider_type       = "google"
  slug                = "google"
}
