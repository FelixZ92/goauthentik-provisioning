terraform {
  required_version = ">= 0.14.0"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

output "my_ip_addr" {
  value = data.http.myip.body
}
