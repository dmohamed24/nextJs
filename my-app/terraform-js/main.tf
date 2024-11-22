provider "aws" {
  region = "eu-west-2"
}

# s3 bucket ==> stores the static files for the nextjs boilerplate app
resource "aws_s3_bucket" "nextjs_bucket" {
  bucket = "nextjs-my-app-bucket-dm"
}

# ownership control

resource "aws_s3_bucket_ownership_controls" "nextjs_bucket_ownership_controls" {
  bucket = aws_s3_bucket.nextjs_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# disable public access block 
resource "aws_s3_bucket_public_access_block" "nextjs_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.nextjs_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# enabling acl to be public read on the bucket
resource "aws_s3_bucket_acl" "nextjs_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.nextjs_bucket_ownership_controls,
  aws_s3_bucket_public_access_block.nextjs_bucket_public_access_block, ]

  bucket = aws_s3_bucket.nextjs_bucket
  acl    = "public-read"
}

# construct S3 bucket policy data
data "aws_iam_policy_document" "nextjs_bucket_policy_doc" {
  statement {
    sid     = "PublicReadGetObject"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["${aws_s3_bucket.nextjs_bucket.arn}/*"]
  }
}

# create s3 bucket policy
resource "aws_s3_bucket_policy" "nextjs_bucket_public_policy" {
  bucket = aws_s3_bucket.nextjs_bucket.id
  policy = data.aws_iam_policy_document.nextjs_bucket_policy_doc.json
}