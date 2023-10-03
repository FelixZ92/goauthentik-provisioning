from authentik.core.models import Group
#email = request.context["oauth_userinfo"]["email"]
group, _ = Group.objects.get_or_create(name="some-group")
# ["groups"] *must* be set to an array of Group objects, names alone are not enough.
request.context["flow_plan"].context["groups"] = [group]
return True