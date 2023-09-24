# Ensure flow is only run during oauth logins via Github
if context["source"].provider_type != "github":
    return True

accepted_org = "fzx"

# Get the user-source connection object from the context, and get the access token
connection = context["goauthentik.io/sources/connection"]
access_token = connection.access_token

# We also access the user info authentik already retrieved, to get the correct username
github_username = context["oauth_userinfo"]

# Github does not include Organisations in the userinfo endpoint, so we have to call another URL

orgs_response = requests.get(
    "https://api.github.com/user/orgs",
    auth=(github_username["login"], access_token),
    headers={
        "accept": "application/vnd.github.v3+json"
    }
)

orgs_response.raise_for_status()
orgs = orgs_response.json()

# `orgs` will be formatted like this
# [
#     {
#         "login": "goauthentik",
#         [...]
#     }
# ]
user_matched = any(org['login'] == accepted_org for org in orgs)
if not user_matched:
    ak_message(f"User is not member of {accepted_org}.")
return user_matched