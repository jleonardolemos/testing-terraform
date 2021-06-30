data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_security_group" "allow_ssh_worker" {
  name        = "allow_ssh_worker"
  description = "Allow SSH inbound traffic"
  vpc_id = var.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_worker"
  }
}

resource "aws_security_group" "allow_http_worker" {
  name        = "allow_http_worker"
  description = "Allow HTTP inbound traffic"
  vpc_id = var.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_worker"
  }
}

resource "aws_launch_template" "swarm_cluster_test" {
  name = "cluster_test"

  image_id = "ami-09e67e426f25ce0d7"

  instance_type = "t2.micro"

  key_name = "ecs-key"

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.allow_http_worker.id,
      aws_security_group.allow_ssh_worker.id,
    ]
    subnet_id = var.subnet_one
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Cluster Test"
    }
  }

  user_data = filebase64("${path.module}/user_data.sh")
}

resource "aws_autoscaling_group" "swarm_worker_autoscaling" {
  # availability_zones = ["us-east-1a"]
  availability_zones = [data.aws_availability_zones.available.names[0]]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2

  launch_template {
    id      = aws_launch_template.swarm_cluster_test.id
    version = "$Latest"
  }
  
  lifecycle {
    ignore_changes = [
      load_balancers,
      target_group_arns,
    ]
  }
}

resource "aws_alb_target_group" "swarm_worker_target_group" {
  name     = "swarm-worker-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_autoscaling_attachment" "swarm_worker_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.swarm_worker_autoscaling.id
  alb_target_group_arn   = aws_alb_target_group.swarm_worker_target_group.arn
}

resource "aws_lb" "swarm_load_balancer" {
  name               = "swarm-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_worker.id]
  subnets            = [
    var.subnet_one,
    var.subnet_two,
  ]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "swarm_http_application" {
  load_balancer_arn = aws_lb.swarm_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.swarm_worker_target_group.arn
  }
}