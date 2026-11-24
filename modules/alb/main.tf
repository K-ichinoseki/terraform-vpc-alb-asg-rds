resource "aws_lb" "alb" {
  name = "${var.project}-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = var.public_subnet_ids
}

resource "aws_security_group" "alb_sg" {
  name = "${var.project}-alb-sg"
  description = "Allow http from Internet"
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.project}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "inbound_allow_http" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  ip_protocol = "tcp"
  to_port = 80
}

resource "aws_vpc_security_group_egress_rule" "outbound_allow_all" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.project}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path = "/health.html"
    protocol = "HTTP"
    port = 80
    matcher = "200"
    interval = 30
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
