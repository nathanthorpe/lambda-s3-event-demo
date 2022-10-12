# Create S3 Bucket
resource "aws_s3_bucket" "images_bucket" {
  bucket_prefix = var.image_bucket_prefix
  force_destroy = true
}

# Default ACL to private
resource "aws_s3_bucket_acl" "artifacts_acl" {
  bucket = aws_s3_bucket.images_bucket.id
  acl    = "private"
}

# Block public access
resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.images_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

# Enable bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "uploads_encrypt" {
  bucket = aws_s3_bucket.images_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Invoke lambda on file upload
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.images_bucket.id

  lambda_function {
    id                  = "notify-on-image-upload"
    lambda_function_arn = aws_lambda_function.image_optimizer.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.uploads_prefix
  }

  depends_on = [aws_lambda_permission.allow_bucket_notification]
}

# Create empty folder
resource "aws_s3_object" "object" {
  for_each = toset([var.thumbnail_destination, var.uploads_prefix])
  bucket = aws_s3_bucket.images_bucket.id
  key    = each.key
}
