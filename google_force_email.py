email = request.context["prompt_data"]["email"]
# Direct set username to email
request.context["prompt_data"]["username"] = email
# Set username to email without domain
# request.context["prompt_data"]["username"] = email.split("@")[0]
return True