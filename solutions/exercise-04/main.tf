# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN AUTO SCALING GROUP (ASG) WITH AN APPLICATION LOAD BALANCER (ALB) IN FRONT OF IT
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_autoscaling_group" "web_servers" {
  name                 = "${var.name}"
  launch_configuration = "${aws_launch_configuration.web_servers.name}"

  min_size         = 3
  max_size         = 3
  desired_capacity = 3

  # Deploy all the subnets (and therefore AZs) available
  vpc_zone_identifier = ["${data.aws_subnet_ids.default.ids}"]

  # Automatically register this ASG's Instances in the ALB and use the ALB's health check to determine when an Instance
  # needs to be replaced
  health_check_type = "ELB"
  target_group_arns = ["${aws_alb_target_group.web_servers.arn}"]

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAUNCH CONFIGURATION
# This is a "template" that defines the configuration for each EC2 Instance in the ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "web_servers" {
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"

  key_name        = "${var.key_name}"
  security_groups = ["${aws_security_group.web_server.id}"]

  # To keep this example simple, we run a web server as a User Data script. In real-world usage, you would typically
  # install the web server and its dependencies in the AMI.
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.web_server_http_port}" &
              EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# FOR THIS EXAMPLE, WE JUST RUN A PLAIN UBUNTU 16.04 AMI
# ---------------------------------------------------------------------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT TRAFFIC CAN GO IN AND OUT OF THE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "web_server" {
  name = "${var.name}"
}

resource "aws_security_group_rule" "web_server_allow_http_inbound" {
  type              = "ingress"
  from_port         = "${var.web_server_http_port}"
  to_port           = "${var.web_server_http_port}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.web_server.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_server_allow_ssh_inbound" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.web_server.id}"

  # To keep this example simple, we allow SSH requests from any IP. In real-world usage, you should lock this down
  # to just the IPs of trusted servers (e.g., your office IPs).
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_server_allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.web_server.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ALB TO DISTRIBUTE TRAFFIC ACROSS THE ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb" "web_servers" {
  name            = "${var.name}"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${data.aws_subnet_ids.default.ids}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ALB LISTENER FOR HTTP REQUESTS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.web_servers.arn}"
  port              = "${var.alb_http_port}"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.web_servers.arn}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ALB TARGET GROUP FOR THE ASG
# This target group will perform health checks on the web servers in the ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb_target_group" "web_servers" {
  name     = "${var.name}"
  port     = "${var.web_server_http_port}"
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.default.id}"

  health_check {
    path                = "/"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ALB LISTENER RULE TO SEND ALL REQUESTS TO THE ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb_listener_rule" "send_all_to_web_servers" {
  listener_arn = "${aws_alb_listener.http.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.web_servers.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT TRAFFIC CAN GO IN AND OUT OF THE ALB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name = "${var.name}-alb"
}

resource "aws_security_group_rule" "alb_allow_http_inbound" {
  type              = "ingress"
  from_port         = "${var.alb_http_port}"
  to_port           = "${var.alb_http_port}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.alb.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

# We need to allow outbound connections from the ALB so it can perform health checks
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.alb.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY INTO THE DEFAULT VPC AND SUBNETS
# To keep this example simple, we are deploying into the Default VPC and its subnets. In real-world usage, you should
# deploy into a custom VPC and private subnets.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}