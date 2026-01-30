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
  name_prefix            = var.project_name
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.st_sg_id]
  key_name               = var.key_name

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e

    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

    # Update system
    apt-get update -y

    # Install Nginx
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx

    # Install Docker
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker

    # Create docker network
    docker network inspect starttech-app >/dev/null 2>&1 || true
    docker network create starttech-app

    ## Start mongodb container
    docker run -d \
    --name mongodb \
    --network starttech-app \
    -e MONGO_INITDB_ROOT_USERNAME=${var.mongo_username} \
    -e MONGO_INITDB_ROOT_PASSWORD=${var.mongo_password} \
    --restart unless-stopped \
    -v mongodb-data:/data/db \
    mongo

    # Start application container. This is to ensure new instaces started
    # by the autoscaling group have the application running automatically.
    docker run -d \
    --name starttech-app \
    --network starttech-app \
    --restart unless-stopped \
    -p 8080:8080 \
    -e MONGO_URI=mongodb://${var.mongo_username}:${var.mongo_password}@mongodb:27017 \
    -e DB_NAME=${var.project_name} \
    --log-driver awslogs \
    --log-opt awslogs-region=${var.aws_region} \
    --log-opt awslogs-group=/${var.project_name}/backend \
    --log-opt awslogs-stream=$INSTANCE_ID/${var.project_name} \
    --log-opt awslogs-create-group=false \
    ${var.docker_image}:latest

    # Configure NGINX
    sudo rm -f /etc/nginx/sites-enabled/default
    echo \"server { listen 80; location / { proxy_pass http://127.0.0.1:8080; } }\" | sudo tee /etc/nginx/sites-available/backend
    sudo ln -sf /etc/nginx/sites-available/backend /etc/nginx/sites-enabled/backend
    sudo systemctl reload nginx

    # Install CloudWatch Agent
    apt-get install -y amazon-cloudwatch-agent

    # Start agent later with config
    systemctl enable amazon-cloudwatch-agent
    systemctl enable amazon-cloudwatch-agent
  EOF
  )

}

resource "aws_autoscaling_group" "st_asg" {
  name = "${var.project_name}-asg"

  vpc_zone_identifier = var.private_subnets_ids

  desired_capacity = 2
  max_size         = 4
  min_size         = 2

  target_group_arns = [aws_lb_target_group.lb_tg.arn]
  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.st_lt.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 120
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ASG"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.project_name}-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.st_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75
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
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
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


