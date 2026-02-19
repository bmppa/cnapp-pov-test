# Create an S3 bucket to store the MongoDB backups
resource "aws_s3_bucket" "db-bkp" {
  bucket        = "db-bkp-${random_string.random.result}"
  force_destroy = true
}

# Configure the S3 Bucket (db-bkp) to allow public access
resource "aws_s3_bucket_public_access_block" "db-bkp" {
  bucket = aws_s3_bucket.db-bkp.id

  block_public_acls       = false
  block_public_policy     = false
  restrict_public_buckets = false
  ignore_public_acls      = false
}

# Allow public read to bucket db-bkp (MongoDB backups)
resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.db-bkp.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject", "s3:ListBucket"]
        Resource  = [aws_s3_bucket.db-bkp.arn, "${aws_s3_bucket.db-bkp.arn}/*"]
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.db-bkp]
}

# Create a bucket where objects can be public
resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "my-bucket-${random_string.random.result}"
  force_destroy = true
}

# Upload sensitive test data to S3 bucket
resource "aws_s3_object" "objects" {
  for_each = fileset("uploads/", "*")
  bucket   = aws_s3_bucket.s3_bucket.id
  key      = each.value
  source   = "uploads/${each.value}"
}