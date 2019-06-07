variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "use_ssl" {
  description = ""
  default     = "true"
}

variable "ssl_domain" {
  description = ""
}

#===================== S3 Configs =====================#

variable "bucket_name" {
  description = "The name of the bucket. If omitted, Terraform will assign a random, unique name."
  type        = string
}

variable "acl" {
  description = "The canned ACL to apply. See https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl for options."
  default     = "private"
}

variable "policy" {
  description = "A valid bucket policy JSON document."
  default     = ""
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = false
}

#===================== Cloudfront Configs =====================#

variable "enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content."
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Whether the IPv6 is enabled for the distribution."
  default     = true
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  default     = "index.html"
}

variable "origin_path" {
  description = "An optional element that causes CloudFront to request your content from a directory in your Amazon S3 bucket or your custom origin."
  default     = ""
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  type        = list(string)
}

variable "price_class" {
  description = "The price class for this distribution. [PriceClass_All, PriceClass_200, PriceClass_100]"
  default     = "PriceClass_All"
}

## Cache Behavior

variable "allowed_methods" {
  description = "Controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin."
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cache_methods" {
  description = "Controls whether CloudFront caches the response to requests using the specified HTTP methods."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "viewer_protocol_policy" {
  description = "Use this element to specify the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern. [allow-all, https-only, or redirect-to-https]"
  default     = "redirect-to-https"
}

variable "min_ttl" {
  description = "The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated."
  default     = "0"
}

variable "default_ttl" {
  description = "The default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an Cache-Control max-age or Expires header."
  default     = "1"
}

variable "max_ttl" {
  description = "The maximum amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated."
  default     = "365"
}

variable "compress" {
  description = "Whether you want CloudFront to automatically compress content for web requests that include Accept-Encoding: gzip in the request header"
  default     = "false"
}

## Viewer Ceritificate

variable "use_default_certificate" {
  description = "If you want viewers to use HTTPS to request your objects and you're using the CloudFront domain name for your distribution."
  default     = "false"
}

variable "ssl_support_method" {
  description = "Specifies how you want CloudFront to serve HTTPS requests. [vip, sni-only]"
  default     = "sni-only"
}

variable "minimum_protocol_version" {
  description = "The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections. [SSLv3, TLSv1, TLSv1_2016, TLSv1.1_2016, TLSv1.2_2018]"
  default     = "TLSv1"
}

## Restriction

variable "restriction_type" {
  description = "The method that you want to use to restrict distribution of your content by country, [none, whitelist, blacklist]"
  default     = "none"
}

