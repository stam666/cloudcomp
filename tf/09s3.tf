resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  force_destroy = true
  tags = {
    Name = "s3"
  }
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "main" {
  bucket = aws_s3_bucket.main.id
  acl    = "public-read"
  depends_on = [
    aws_s3_bucket_ownership_controls.main,
    aws_s3_bucket_public_access_block.main,
  ]
}
