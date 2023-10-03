from authentik.core.models import Group
email = request.context["prompt_data"]["email"]
username = request.context["oauth_userinfo"]["login"]
if email == "contact@zippelf.com" and username.lower() == "felixz92":
    grafana_admins, _ = Group.objects.get_or_create(name="Grafana Admins")
    grafana_editors, _ = Group.objects.get_or_create(name="Grafana Editors")
    cluster_admins, _ = Group.objects.get_or_create(name="cluster-admins")
    wego_admins, _ = Group.objects.get_or_create(name="wego-admin")
    wego_readonly, _ = Group.objects.get_or_create(name="wego-readonly")
# ["groups"] *must* be set to an array of Group objects, names alone are not enough.
request.context["flow_plan"].context["groups"] = [grafana_editors, grafana_admins, cluster_admins, wego_admins, wego_readonly]
return True