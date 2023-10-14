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
  search_mode = "cached"
  bind_mode = "cached"
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