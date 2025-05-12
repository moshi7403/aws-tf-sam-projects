resource "aws_s3_bucket" "bucket" {
  bucket = "${var.project}-bucket-${var.bucket_id}"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    transition {
      days          = 30
      storage_class = "GLACIER"
    }
    expiration {
      days = 365
    }
  }

  tags = {
    Name = "${var.project}-bucket"
  }
}