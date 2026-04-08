data "aws_region" "current" {}

data "aws_acm_certificate" "cert" {
  domain      = "*.${var.dns_domain}"
  provider    = aws.us_east_1
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}