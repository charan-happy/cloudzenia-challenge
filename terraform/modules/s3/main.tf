resource "aws_s3_bucket" "static_site" {
  bucket = "cloudzenia-static-site-${random_string.suffix.result}"
}

resource "aws_s3_bucket_website_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket                  = aws_s3_bucket.static_site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "static_site" {
  bucket = aws_s3_bucket.static_site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

resource "aws_route53_record" "static_site" {
  zone_id = var.hosted_zone_id
  name    = "docs.nagacharan.site"
  type    = "A"
  alias {
    name                   = aws_s3_bucket_website_configuration.static_site.website_endpoint
    zone_id                = aws_s3_bucket.static_site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID"
  type        = string
}
