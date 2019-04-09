output "acm_certificate_arn" {
  value = "${join("", aws_acm_certificate.s3_cloudfront_ssl.*.arn)}"
}

output "cloudfront_hostname" {
  value = "${aws_cloudfront_distribution.s3_cloudfront.domain_name}"
}

output "s3_bucket_arn" {
  value = "${aws_s3_bucket.s3_cloudfront_bucket.arn}"
}