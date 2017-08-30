output "public_ips" {
  value = ["${aws_instance.web_server.*.public_ip}"]
}

output "urls" {
  value = ["${formatlist("http://%s:%s", aws_instance.web_server.public_ip, var.http_port)}"]
}