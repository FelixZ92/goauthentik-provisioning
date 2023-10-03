from authentik.core.models import Group
email = request.context["prompt_data"]["email"]
group1, _ = Group.objects.get_or_create(name="some-group")
group2, _ = Group.objects.get_or_create(name=email)
# ["groups"] *must* be set to an array of Group objects, names alone are not enough.
request.context["flow_plan"].context["groups"] = [group1, group2]
return True