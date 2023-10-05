resource "authentik_group" "ocis_ldap_search" {
  name = "ocis-ldap-search"
}

resource "authentik_user" "ocis_ldap_user" {
  username = "ocis-ldap"
  type = "service-account"
  groups = [authentik_group.ocis_ldap_search.id]
  path = "goauthentik.io/serviceaccounts"
}
