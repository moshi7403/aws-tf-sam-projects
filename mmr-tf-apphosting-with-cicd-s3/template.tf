resource "aws_s3_bucket" "website_s3_bucket" {
  bucket = "mmr-static-website-artifact-bucket"
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_s3_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}


# S3 Bucket Policy for Public Access
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_s3_bucket.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadForGetBucketObjects"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_s3_bucket.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.website_s3_bucket_access_block]  # Ensure the access block is applied first
}

# S3 Public Access Block
resource "aws_s3_bucket_public_access_block" "website_s3_bucket_access_block" {
  bucket = aws_s3_bucket.website_s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}