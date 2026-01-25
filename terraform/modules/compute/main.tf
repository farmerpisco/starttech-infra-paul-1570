data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical’s official AMI owner ID
}


resource "aws_launch_template" "st_lt" {
  name_prefix            = "${var.project_name}"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.st_sg_id]
  key_name               = var.key_name

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    # set -e

    # Update system
    apt-get update -y

    # Install Nginx
    apt-get install -y nginx
    echo "<h1>Hello from $(hostname)</h1><p>IP: $(hostname -I)</p>" > /var/www/html/index.html
    systemctl start nginx
    systemctl enable nginx

    # Install Docker
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker

    # Install CloudWatch Agent
    # apt-get install -y amazon-cloudwatch-agent

    # Start agent later with config
    # systemctl enable amazon-cloudwatch-agent
  EOF
  )

}

resource "aws_autoscaling_group" "st_asg" {
  name = "${var.project_name}-asg"

  vpc_zone_identifier = var.private_subnets_ids

  desired_capacity   = 2
  max_size           = 4
  min_size           = 2

  target_group_arns = [aws_lb_target_group.lb_tg.arn]
  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.st_lt.id
    version = "$Latest"
  }

  tag {  
    key                 = "Name"   
    value               = "${var.project_name}-ASG"    
    propagate_at_launch = true
  }
}

resource "aws_lb" "st_lb" {
  name               = "${var.project_name}-LB"
  load_balancer_type = "application"
  subnets            = var.public_subnets_ids
  security_groups    = [var.st_alb_sg_id]
}

resource "aws_lb_target_group" "lb_tg" {
  name     = "${var.project_name}-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }
}

resource "aws_lb_listener" "lb_http" {
  load_balancer_arn = aws_lb.st_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

resource "aws_lb_listener_rule" "asg" {  
  listener_arn = aws_lb_listener.lb_http.arn  
  priority     = 100  
  
  condition {    
    path_pattern {      
      values = ["/*"]    
    }  
  }  
  
  action {    
    type             = "forward"    
    target_group_arn = aws_lb_target_group.lb_tg.arn  
  }
}