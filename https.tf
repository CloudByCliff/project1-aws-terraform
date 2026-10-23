
# ==================================================
# AWS PROJECT 1 - DOMAIN, ROUTE 53 AND HTTPS
# Domain purchased from Namecheap
# ==================================================

locals {
  domain_name = "cloudbycliff.com"
  app_domain  = "project1.${local.domain_name}"
}

# --------------------------------------------------
# 1. CREATE PUBLIC ROUTE 53 HOSTED ZONE
# --------------------------------------------------

resource "aws_route53_zone" "portfolio" {
  name = local.domain_name

  tags = {
    Name    = local.domain_name
    Project = var.project_name
  }
}

# --------------------------------------------------
# 2. REQUEST ACM SSL/TLS CERTIFICATE
# --------------------------------------------------

resource "aws_acm_certificate" "project1" {
  domain_name       = local.app_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name    = local.app_domain
    Project = var.project_name
  }
}

# --------------------------------------------------
# 3. CREATE DNS RECORD TO VALIDATE CERTIFICATE
# --------------------------------------------------

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.project1.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.portfolio.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60

  records = [each.value.value]
}

# --------------------------------------------------
# 4. WAIT FOR ACM CERTIFICATE VALIDATION
# --------------------------------------------------

resource "aws_acm_certificate_validation" "project1" {
  certificate_arn = aws_acm_certificate.project1.arn

  validation_record_fqdns = [
    for record in aws_route53_record.certificate_validation :
    record.fqdn
  ]
}

# --------------------------------------------------
# 5. ENABLE HTTPS ON APPLICATION LOAD BALANCER
# --------------------------------------------------

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.project1.arn

  port       = 443
  protocol   = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  certificate_arn = aws_acm_certificate_validation.project1.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# --------------------------------------------------
# 6. CONNECT PROJECT SUBDOMAIN TO LOAD BALANCER
# --------------------------------------------------

resource "aws_route53_record" "project1" {
  zone_id = aws_route53_zone.portfolio.zone_id
  name    = local.app_domain
  type    = "A"

  alias {
    name                   = aws_lb.project1.dns_name
    zone_id                = aws_lb.project1.zone_id
    evaluate_target_health = true
  }
}
