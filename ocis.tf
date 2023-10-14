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
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.ocis_ldap_key.private_key_pem

  subject {
    common_name  = "ak-outpost-ldap"
    organization = "fzx"
  }
  dns_names = [
    "ak-outpost-ldap",
    "ak-outpost-ldap.authentik",
    "ak-outpost-ldap.authentik.svc",
    "ak-outpost-ldap.authentik.svc.cluster.local",
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
