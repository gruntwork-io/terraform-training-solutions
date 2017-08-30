output "public_ip" {
  value = "${aws_instance.web_server.public_ip}"
}

output "url" {
  value = "http://${aws_instance.web_server.public_ip}:${var.http_port}"
}