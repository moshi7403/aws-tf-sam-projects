resource "aws_s3_bucket" "s3_static_website_0112" {
  bucket = "s3-static-website-0112"


  tags = {
    Name        = "s3-static-website-0112"
    Environment = "Dev"
  }
}
resource "aws_s3_bucket_public_access_block" "s3_static_website_0112" {
  bucket = aws_s3_bucket.s3_static_website_0112.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "s3_static_website_0112_policy" {
  bucket = aws_s3_bucket.s3_static_website_0112.id
  policy = data.aws_iam_policy_document.s3_static_website_0112_policy_document.json
}

data "aws_iam_policy_document" "s3_static_website_0112_policy_document" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:*",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.s3_static_website_0112.arn,
      "${aws_s3_bucket.s3_static_website_0112.arn}/*",
    ]
  }
}


locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3_static_website_0112.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.s3_static_website_0112.id

#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
#     }
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  # AWS Managed Caching Policy (CachingDisabled)
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.s3_static_website_0112.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # ... other configuration ...
}