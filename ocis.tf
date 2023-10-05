#           - role_name: admin
#claim_value: ocis-admin
#- role_name: spaceadmin
#claim_value: ocis-space-admin
#- role_name: user
#claim_value: ocis-user
#- role_name: guest
#claim_value: ocis-guest
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

resource "authentik_group" "ocis_ldap_search" {
  name = "ocis-ldap-search"

}

resource "authentik_user" "ocis_ldap_user" {
  username = "ocis-ldap"
  type = "service_account"
  groups = [authentik_group.ocis_ldap_search.id]
  path = "goauthentik.io/serviceaccounts"
}
