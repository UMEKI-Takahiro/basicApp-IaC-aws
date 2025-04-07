##################
# public domain
##################
data "aws_route53_zone" "hosted_zone" {
  name = "takahiro2.com"
}

resource "aws_route53_record" "dns_record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = data.aws_route53_zone.hosted_zone.name
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "certificate" {
  for_each = {
    for dvo in aws_acm_certificate.acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  zone_id = data.aws_route53_zone.hosted_zone.id
  ttl     = 60
}

output "domain_name" {
  value = aws_route53_record.dns_record.name
}

##################
# local domain
##################
resource "aws_route53_zone" "private_zone" {
  name = "local"
  vpc {
    vpc_id = aws_vpc.vpc.id
  }
  force_destroy = true
  comment       = "Private Hosted Zone for .local domains"
}

# db.local
resource "aws_route53_record" "db_record" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "db.local"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.basic-app-db.endpoint]
}

# app.local
resource "aws_route53_record" "app_local_cname" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "app.local"
  type    = "CNAME"
  ttl     = 300
  records = ["app.asdpdn.local"]
}
resource "aws_service_discovery_private_dns_namespace" "asdpdn_local" {
  name        = "asdpdn.local"
  description = "Private DNS namespace for ECS service discovery"
  vpc         = aws_vpc.vpc.id
}
resource "aws_service_discovery_service" "asds" {
  name = "app"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.asdpdn_local.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

