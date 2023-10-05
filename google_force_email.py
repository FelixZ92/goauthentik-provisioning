email = request.context["prompt_data"]["email"]
# Direct set username to email

accepted_users = ["felix.zippel@gmail.com", "zerdus9999@gmail.com"]

user_matched = any(user in email for user in accepted_users)
if not user_matched:
    ak_message("You are not allowed to log in. This attempt has been logged.\nIf you think this is not applicable to you, please contact your administrator")
    return False

request.context["prompt_data"]["username"] = email

# Set username to email without domain
# request.context["prompt_data"]["username"] = email.split("@")[0]
return True
