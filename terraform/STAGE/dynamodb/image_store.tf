resource "aws_s3_bucket" "image_store" {
  bucket = "staging-acs730-project"
}

resource "aws_s3_bucket_ownership_controls" "image_store" {
  bucket = aws_s3_bucket.image_store.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "image_store" {
  bucket = aws_s3_bucket.image_store.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "image_store" {
  depends_on = [
    aws_s3_bucket_ownership_controls.image_store,
    aws_s3_bucket_public_access_block.image_store,
  ]

  bucket = aws_s3_bucket.image_store.id
  acl    = "public-read"
}