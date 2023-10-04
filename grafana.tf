data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_scope_mapping" "scope-mapping" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile"
  ]
}

resource "authentik_group" "grafana_admins" {
  name         = "Grafana Admins"
  is_superuser = false
}

resource "authentik_group" "grafana_editors" {
  name         = "Grafana Editors"
  is_superuser = false
}

resource "authentik_provider_oauth2" "grafana" {
  name               = "grafana"
  client_id          = "grafana"
  client_secret      = var.grafana_client_secret
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  property_mappings  = data.authentik_scope_mapping.scope-mapping.ids
  redirect_uris      = [format("https://grafana.%s/login/generic_oauth", var.base_domain)]
}

resource "authentik_application" "grafana" {
  name              = "grafana"
  slug              = "grafana"
  protocol_provider = authentik_provider_oauth2.grafana.id
  meta_icon         = "https://cdn.worldvectorlogo.com/logos/grafana.svg"
  meta_description  = "https://grafana.com/docs/grafana/latest/"
  meta_launch_url   = format("https://grafana.%s/", var.base_domain)
}

resource "authentik_policy_binding" "grafana_editors" {
  order  = 0
  target = authentik_application.grafana.uuid
  group = authentik_group.grafana_editors.id
}

resource "authentik_policy_binding" "grafana_admins" {
  order  = 0
  target = authentik_application.grafana.uuid
  group = authentik_group.grafana_admins.id
}

