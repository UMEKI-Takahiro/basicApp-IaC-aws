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

output "domain_name" {
  value = aws_route53_record.dns_record.name
}

