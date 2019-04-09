#--------------------------------------------------------------
# S3 Bucket
#--------------------------------------------------------------
resource "aws_s3_bucket" "s3_cloudfront_bucket" {
  bucket        = "${var.bucket_name}"
  acl           = "${var.acl}"
  policy        = "${var.policy}"
  force_destroy = "${var.force_destroy}"
}

#--------------------------------------------------------------
# Certificate
#--------------------------------------------------------------
resource "aws_acm_certificate" "s3_cloudfront_ssl" {
  count = "${var.use_default_certificate == "true" ? 0 : 1}"

  provider          = "aws.us-east-1"
  domain_name       = "${var.ssl_domain}"
  validation_method = "DNS"


  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------
# Cloudfront
#--------------------------------------------------------------
data "aws_region" "current" {}

resource "aws_cloudfront_distribution" "s3_cloudfront" {
  count      = 1
  depends_on = ["aws_s3_bucket.s3_cloudfront_bucket"]

  origin {
    custom_origin_config {
      http_port              = "${var.http_port}"
      https_port             = "${var.https_port}"
      origin_protocol_policy = "${var.origin_protocol_policy}"
      origin_ssl_protocols   = "${var.origin_ssl_protocols}"
    }

    // Important to use this format of origin domain name, it is the only format that
    // supports S3 redirects with CloudFront
    domain_name = "${var.bucket_name}.s3.amazonaws.com"

    origin_id   = "${var.origin_id}"
    origin_path = "${var.origin_path}"
  }

  enabled             = "${var.enabled}"
  is_ipv6_enabled     = "${var.is_ipv6_enabled}"
  default_root_object = "${var.default_root_object}"

  aliases = ["${var.aliases}"]

  default_cache_behavior {
    allowed_methods  = "${var.allowed_methods}"
    cached_methods   = "${var.cache_methods}"
    target_origin_id = "${var.origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "${var.viewer_protocol_policy}"

    min_ttl     = "${var.min_ttl}"
    default_ttl = "${var.default_ttl}"
    max_ttl     = "${var.max_ttl}"
    compress    = "${var.compress}"
  }

  price_class = "${var.price_class}"

  viewer_certificate {
    cloudfront_default_certificate = "${var.use_default_certificate}"
    acm_certificate_arn            = "${var.use_default_certificate == "true" ? "" : join("", aws_acm_certificate.s3_cloudfront_ssl.*.arn)}"
    ssl_support_method             = "${var.use_default_certificate == "true" ? "" : var.ssl_support_method}"
    minimum_protocol_version       = "${var.minimum_protocol_version}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "${var.restriction_type}"
    }
  }
}