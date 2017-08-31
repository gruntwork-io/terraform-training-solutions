# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A "MICROSERVICE" ACROSS AN AUTO SCALING GROUP (ASG) WITH AN APPLICATION LOAD BALANCER (ALB) IN FRONT OF IT
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_autoscaling_group" "microservice" {
  # Note that we intentionally depend on the Launch Configuration name so that creating a new Launch Configuration
  # (e.g. to deploy a new AMI) creates a new Auto Scaling Group. This will allow for rolling deployments.
  name                 = "${aws_launch_configuration.microservice.name}"
  launch_configuration = "${aws_launch_configuration.microservice.name}"

  min_size         = "${var.size}"
  max_size         = "${var.size}"
  desired_capacity = "${var.size}"
  min_elb_capacity = "${var.size}"

  # Deploy all the subnets (and therefore AZs) available
  vpc_zone_identifier = ["${data.aws_subnet_ids.default.ids}"]

  # Automatically register this ASG's Instances in the ALB and use the ALB's health check to determine when an Instance
  # needs to be replaced
  health_check_type         = "ELB"
  health_check_grace_period = 30
  target_group_arns         = ["${aws_alb_target_group.web_servers.arn}"]

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  # To support rolling deployments, we tell Terraform to create a new ASG before deleting the old one. Note: as
  # soon as you set create_before_destroy = true in one resource, you must also set it in every resource that it
  # depends on, or you'll get an error about cyclic dependencies (especially when removing resources).
  lifecycle {
    create_before_destroy = true
  }

  # This needs to be here to ensure the ALB has at least one listener rule before the ASG is created. Otherwise, on the
  # very first deployment, the ALB won't bother doing any health checks, which means min_elb_capacity will not be
  # achieved, and the whole deployment will fail.
  depends_on = ["aws_alb_listener.http"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAUNCH CONFIGURATION
# This is a "template" that defines the configuration for each EC2 Instance in the ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "microservice" {
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  user_data     = "${data.template_file.user_data.rendered}"

  key_name        = "${var.key_name}"
  security_groups = ["${aws_security_group.web_server.id}"]

  # When used with an aws_autoscaling_group resource, the aws_launch_configuration must set create_before_destroy to
  # true. Note: as soon as you set create_before_destroy = true in one resource, you must also set it in every resource
  # that it depends on, or you'll get an error about cyclic dependencies (especially when removing resources).
  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE USER DATA SCRIPT EACH SERVER WILL RUN DURING BOOT
# Note that the user of this module can choose the User Data script to run using var.user_data_script_name
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data/${var.user_data_script_name}")}"

  vars {
    server_text      = "${var.server_text}"
    server_http_port = "${var.server_http_port}"
    backend_url      = "${var.backend_url}"
  }
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
  name   = "${var.name}"
  vpc_id = "${data.aws_vpc.default.id}"

  # This is here because aws_launch_configuration.web_servers sets create_before_destroy to true and depends on this
  # resource
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "web_server_allow_http_inbound" {
  type              = "ingress"
  from_port         = "${var.server_http_port}"
  to_port           = "${var.server_http_port}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.web_server.id}"

  # Only allow incoming requests from the ALB
  source_security_group_id = "${aws_security_group.alb.id}"
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
  internal        = "${var.is_internal_alb}"

  # This is here because aws_alb_listener.htp depends on this resource and sets create_before_destroy to true
  lifecycle {
    create_before_destroy = true
  }
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

  # This is here because aws_autoscaling_group.web_servers depends on this resource and sets create_before_destroy
  # to true
  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ALB TARGET GROUP FOR THE ASG
# This target group will perform health checks on the web servers in the ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb_target_group" "web_servers" {
  name     = "${var.name}"
  port     = "${var.server_http_port}"
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.default.id}"

  # Give existing connections 10 seconds to complete before deregistering an instance. The default delay is 300 seconds
  # (5 minutes), which significantly slows down redeploys. In theory, the ALB should deregister the instance as long as
  # there are no open connections; in practice, it waits the full five minutes every time. If your requests are
  # generally processed quickly, set this to something lower (such as 10 seconds) to keep redeploys fast.
  deregistration_delay = 10

  health_check {
    path                = "/"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  # This is here because aws_autoscaling_group.web_servers depends on this resource and sets create_before_destroy
  # to true
  lifecycle {
    create_before_destroy = true
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
  name   = "${var.name}-alb"
  vpc_id = "${data.aws_vpc.default.id}"
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
# CREATE AN OPTIONAL ROUTE 53 HEALTH CHECK
# This is only created if the ALB is not internal
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route53_health_check" "service_up" {
  count = "${1 - var.is_internal_alb}"

  type = "HTTP"
  fqdn = "${aws_alb.web_servers.dns_name}"
  port = "${var.alb_http_port}"

  failure_threshold = 2
  request_interval  = 30

  tags {
    Name = "${var.name}-${aws_alb.web_servers.dns_name}"
  }
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