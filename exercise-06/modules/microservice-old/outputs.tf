output "alb_dns_name" {
  value = "${aws_alb.web_servers.dns_name}"
}

output "url" {
  value = "http://${aws_alb.web_servers.dns_name}:${var.alb_http_port}/"
}
