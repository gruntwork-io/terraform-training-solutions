# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A SIMPLE WEB SERVER ON A SINGLE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.18.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE EC2 INSTANCE
# It will run a simple "Hello, World" web server
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "web_server" {
  ami           = "099720109477"
  instance_type = "t2.micro"

  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.web_server.id}"]

  # To keep this example simple, we run a web server as a User Data script. In real-world usage, you would typically
  # install the web server and its dependencies in the AMI.
  user_data = <<-EOF
              #!/bin/bash
              echo "${var.server_text}" > index.html
              nohup busybox httpd -f -p "${var.http_port}" &
              EOF

  tags = {
    Name = "${var.name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# FOR THIS EXAMPLE, WE JUST RUN A PLAIN UBUNTU 16.04 AMI
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT TRAFFIC CAN GO IN AND OUT OF THE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "web_server" {
  name = "${var.name}-${terraform.workspace}"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  from_port         = "${var.http_port}"
  to_port           = "${var.http_port}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.web_server.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.web_server.id}"

  # To keep this example simple, we allow SSH requests from any IP. In real-world usage, you should lock this down
  # to just the IPs of trusted servers (e.g., your office IPs).
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.web_server.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}
