# ###############################
# API Gateway: List
# ###############################

locals {
  s3_origin_id  = "s3-${aws_s3_bucket.web_host_bucket.bucket}"
  api_origin_id = "api-${aws_api_gateway_rest_api.app.id}"
  dns_record    = "${var.dns_subdomain}.${var.dns_domain}"
}

# cloudfront
resource "aws_cloudfront_distribution" "app" {

  # S3 Website Origin
  origin {
    domain_name = aws_s3_bucket_website_configuration.website_config.website_endpoint
    origin_id   = local.s3_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # S3 host
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # API Gateway Origin
  origin {
    origin_id   = local.api_origin_id
    domain_name = "${aws_api_gateway_rest_api.app.id}.execute-api.${var.aws_region}.amazonaws.com"
    origin_path = ""

    custom_origin_config {
      http_port              = 443
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default cache behavior: S3 website
  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["HEAD", "GET", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    viewer_protocol_policy = "redirect-to-https"

    # Forwards CORS-related headers
    forwarded_values {
      query_string = true # Enable query string forwarding

      # Headers for CORS
      headers = [
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
        "Origin",
        "Authorization",
        "Content-Type"
      ]

      cookies {
        forward = "none"
      }
    }
  }

  # ordered cache
  ordered_cache_behavior {
    path_pattern           = "/${var.env}/*"
    target_origin_id       = local.api_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true

    forwarded_values {
      query_string = true
      headers = [
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
        "Origin",
        "Authorization",
        "Content-Type"
      ]
      cookies { forward = "none" }
    }
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = ["${local.dns_record}"]

  price_class = "PriceClass_100" # Use only North America and Europe

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Error pages
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  depends_on = [
    aws_s3_bucket.web_host_bucket,
    aws_api_gateway_deployment.app
  ]
}
