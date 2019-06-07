#--------------------------------------------------------------
# Provider proxy
#--------------------------------------------------------------
provider "aws" {
  alias = "default"
}

provider "aws" {
  alias = "ssl"
}

#--------------------------------------------------------------
# S3 Bucket
#--------------------------------------------------------------
resource "aws_s3_bucket" "s3_cloudfront_bucket" {
  provider      = aws.default
  bucket_prefix = var.bucket_name
  acl           = var.acl
  policy        = var.policy
  force_destroy = var.force_destroy
}

data "aws_iam_policy_document" "s3_cloudfront_bucket" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_cloudfront_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.s3_cloudfront_bucket.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.s3_cloudfront_bucket.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.s3_cloudfront_bucket.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_cloudfront_bucket" {
  bucket = aws_s3_bucket.s3_cloudfront_bucket.id
  policy = data.aws_iam_policy_document.s3_cloudfront_bucket.json
}

#--------------------------------------------------------------
# Certificate
#--------------------------------------------------------------
resource "aws_acm_certificate" "s3_cloudfront_ssl" {
  count = var.use_default_certificate == true ? 0 : 1

  provider          = aws.ssl
  domain_name       = var.ssl_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------
# Cloudfront
#--------------------------------------------------------------
resource "aws_cloudfront_origin_access_identity" "s3_cloudfront_bucket" {
}

resource "aws_cloudfront_distribution" "s3_cloudfront" {

  depends_on = [
    aws_s3_bucket.s3_cloudfront_bucket]
  provider   = aws.default

  origin {
    // Important to use this format of origin domain name, it is the only format that
    // supports S3 redirects with CloudFront
    domain_name = aws_s3_bucket.s3_cloudfront_bucket.bucket_domain_name

    origin_id   = aws_s3_bucket.s3_cloudfront_bucket.id
    origin_path = var.origin_path

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_cloudfront_bucket.cloudfront_access_identity_path
    }
  }

  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  default_root_object = var.default_root_object

  aliases = var.aliases

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cache_methods
    target_origin_id = aws_s3_bucket.s3_cloudfront_bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy

    min_ttl     = var.min_ttl
    default_ttl = var.default_ttl
    max_ttl     = var.max_ttl
    compress    = var.compress
  }

  price_class = var.price_class

  viewer_certificate {
    cloudfront_default_certificate = var.use_default_certificate
    acm_certificate_arn            = var.use_default_certificate == true ? "" : join("", aws_acm_certificate.s3_cloudfront_ssl.*.arn)
    ssl_support_method             = var.use_default_certificate == true ? "" : var.ssl_support_method
    minimum_protocol_version       = var.minimum_protocol_version
  }

  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
    }
  }
}

