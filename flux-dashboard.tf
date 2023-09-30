resource "authentik_group" "wego_admins" {
  name         = "wego-admin"
  is_superuser = false
}

resource "authentik_group" "wego_readonly" {
  name         = "wego-readonly"
  is_superuser = false
}

resource "authentik_provider_oauth2" "wego" {
  name               = "wego"
  client_id          = "wego"
  client_secret      = var.wego_client_secret
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  property_mappings  = data.authentik_scope_mapping.scope-mapping.ids
  redirect_uris      = [format("https://flux.%s/oauth2/callback", var.base_domain)]
}

resource "authentik_application" "wego" {
  name              = "wego"
  slug              = "wego"
  protocol_provider = authentik_provider_oauth2.wego.id
  meta_icon         = "https://avatars.githubusercontent.com/u/9976052?s=200&v=4"
  meta_description  = "https://docs.gitops.weave.works/"
  meta_launch_url   = format("https://flux.%s/", var.base_domain)
}
