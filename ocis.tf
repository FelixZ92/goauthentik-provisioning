resource "authentik_group" "ocis_admin" {
  name = "ocis-admin"
}

resource "authentik_group" "ocis_space_admin" {
  name = "ocis-space-admin"
}

resource "authentik_group" "ocis_user" {
  name = "ocis-user"
}

resource "authentik_group" "ocis_guest" {
  name = "ocis-guest"
}

resource "authentik_group" "ldap_search" {
  name = "ldap-search"

}

resource "authentik_user" "ocis_ldap_user" {
  username = "ocis-ldap"
  type = "service_account"
  groups = [authentik_group.ldap_search.id]
  path = "goauthentik.io/serviceaccounts"
}

#resource "authentik_token" "ocis_ldap_password" {
#  identifier = "ldap-ocis-bind-password"
#  user       = authentik_user.ocis_ldap_user.id
#  intent = "app_password"
#  expiring = false
#  retrieve_key = true
#}
#
#resource "doppler_secret" "ldap_bind_password" {
#  config  = "${var.environment}_ocis"
#  name    = "LDAP_BIND_PASSWORD"
#  project = "infrastructure"
#  value   = authentik_token.ocis_ldap_password.key
#}

resource "tls_private_key" "ocis_ldap_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "ocis_ldap_cert" {
  private_key_pem = tls_private_key.ocis_ldap_key.private_key_pem

  subject {
    common_name  = "ak-outpost-ldap"
    organization = "fzx"
  }
  dns_names = [
    "ak-outpost-ldap-ocis",
    "ak-outpost-ldap-ocis.authentik",
    "ak-outpost-ldap-ocis.authentik.svc",
    "ak-outpost-ldap-ocis.authentik.svc.cluster.local",
  ]
  validity_period_hours = 1440

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "kubernetes_secret" "hcloud_token" {
  metadata {
    name      = "ldap-ca"
    namespace = "ocis"
  }

  data = {
    "ldap-ca.crt" = tls_self_signed_cert.ocis_ldap_cert.cert_pem
  }
}

resource "authentik_certificate_key_pair" "ldap-cert" {
  certificate_data = tls_self_signed_cert.ocis_ldap_cert.cert_pem
  key_data = tls_private_key.ocis_ldap_key.private_key_pem
  name             = "ldap-cert"
}

data "authentik_flow" "default-authentication-flow" {
  slug = "default-authentication-flow"
}

resource "authentik_provider_ldap" "ldap_ocis" {
  base_dn   = "DC=ldap,DC=goauthentik,DC=io"
  bind_flow = data.authentik_flow.default-authentication-flow.id
  name      = "ldap-ocis"
  search_group = authentik_group.ldap_search.id
  search_mode = "direct"
  bind_mode = "direct"
  certificate = authentik_certificate_key_pair.ldap-cert.id
  tls_server_name = "ak-outpost-ldap-ocis.authentik.svc.cluster.local"
}

resource "authentik_provider_oauth2" "ocis" {
  name               = "ocis"
  client_id          = "ocis"
  client_type = "public"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  property_mappings  = data.authentik_scope_mapping.scope-mapping.ids
  redirect_uris      = [format("https://ocis.%s/*", var.base_domain)]
  sub_mode = "user_email"
}

resource "authentik_application" "ocis" {
  name              = "ocis"
  slug              = "ocis"
  protocol_provider = authentik_provider_oauth2.ocis.id
  meta_icon         = "https://avatars.githubusercontent.com/u/1645051?s=200&v=4"
  meta_description  = "https://owncloud.com/infinite-scale-4-0"
  meta_launch_url   = format("https://ocis.%s/", var.base_domain)
  backchannel_providers = [authentik_provider_ldap.ldap_ocis.id]
}

resource "authentik_outpost" "ldap-ocis" {
  name               = "ldap-ocis"
  protocol_providers = [
    authentik_provider_ldap.ldap_ocis.id
  ]
  type = "ldap"
  config = jsonencode({
    authentik_host                 = format("http://authentik/")
    authentik_host_insecure        = true
    authentik_host_browser         = format("https://authentik.%s/", var.base_domain)
    log_level                      = "info"
    object_naming_template         = "ak-outpost-%(name)s"
    kubernetes_replicas            = 1
    kubernetes_namespace           = "authentik"
    kubernetes_service_type        = "ClusterIP"
    kubernetes_disabled_components = ["ingress"]
  })
  service_connection = authentik_service_connection_kubernetes.local.id
}
