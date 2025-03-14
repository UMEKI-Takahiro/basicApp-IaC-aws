######################
# alb
######################

resource "aws_lb" "alb" {
  name                       = "alb"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false # 作って壊してを繰り返す予定なので false にする。本来は true にすべき。
  subnets = [
    aws_subnet.public_subnet_0.id,
    aws_subnet.public_subnet_1.id,
  ]
  security_groups = [
    aws_security_group.sg_for_lb.id,
  ]
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

# listener for http (80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Hello, HTTP (80)!"
      status_code  = 200
    }
  }
}

# listener for https (443)

