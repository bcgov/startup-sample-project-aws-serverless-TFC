terraform {
 backend "s3" {}
required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
resource "aws_s3_bucket" "web_distribution" {
  bucket = "sample-app-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  #checkov:skip=CKV_AWS_145:Bucket encryption is automatically done by ASEA
  #checkov:skip=CKV_AWS_18:Bucket logging is not required for sample application
  #checkov:skip=CKV2_AWS_6:Block Public Access is automatically done by ASEA
  #checkov:skip=CKV_AWS_19:Serverside Encryption is automatically done by ASEA
  #checkov:skip=CKV_AWS_144:Bucket replication is not required for sample application
}
resource "aws_s3_bucket_versioning" "web_distribution" {
  bucket = aws_s3_bucket.web_distribution.id
  versioning_configuration {
      status = "Enabled"
  }
}
resource "aws_cloudfront_origin_access_identity" "web_distribution" {
}
data "aws_iam_policy_document" "web_distribution" {
  statement {
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.web_distribution.iam_arn}"]
    }
    resources = ["${aws_s3_bucket.web_distribution.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "web_distribution" {
  bucket = aws_s3_bucket.web_distribution.id
  policy = data.aws_iam_policy_document.web_distribution.json
}
resource "aws_cloudfront_distribution" "web_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  wait_for_deployment = false
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket.web_distribution.bucket_regional_domain_name
    origin_id   = "web_distribution_origin"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.web_distribution.cloudfront_access_identity_path
    }
  }
  #checkov:skip=CKV_AWS_86:Cloudfront distribution logging is not required for sample application
  #checkov:skip=CKV_AWS_68:WAF not required for sample application
  #checkov:skip=CKV2_AWS_32:Response policy headers not required for sample application
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "web_distribution_origin"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
      headers = ["Origin"]
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400


  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2018"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["CA"]
    }
  }
}
locals {
  src_dir = "./build/"
  content_type_map = {
    html = "text/html",
    ico  = "image/x-icon",
    js   = "application/javascript",
    json = "application/json",
    svg  = "image/svg+xml",
    ttf  = "font/ttf",
    txt  = "text/txt"

  }
}

resource "aws_s3_bucket_object" "site_files" {
  # Enumerate all the files in ./src
  for_each = fileset(local.src_dir, "**")

  #checkov:skip=CKV_AWS_186:S3 Encryption is automatically done by ASEA

  # Create an object from each
  bucket = aws_s3_bucket.web_distribution.id
  key    = each.value
  source = "${local.src_dir}/${each.value}"

  content_type = lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.value).extension, "application/octet-stream")
}
