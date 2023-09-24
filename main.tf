terraform {
  required_version = ">= 0.14.0"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

variable "test_var" {
  default = ""
}

output "my_ip_addr" {
  value = data.http.myip.body
}

output "wusa" {
  value = var.test_var
}
