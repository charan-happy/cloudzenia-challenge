resource "aws_iam_policy" "s3_access" {
       name        = "cloudzenia-s3-access"
       description = "Policy for S3 bucket management"
       policy = jsonencode({
         Version = "2012-10-17"
         Statement = [
           {
             Effect = "Allow"
             Action = [
               "s3:PutBucketPolicy",
               "s3:GetBucketPolicy",
               "s3:ListBucket",
               "s3:PutObject",
               "s3:GetObject",
               "s3:DeleteObject"
             ]
             Resource = [
               "arn:aws:s3:::cloudzenia-static-site-*",
               "arn:aws:s3:::cloudzenia-static-site-*/*"
             ]
           }
         ]
       })
     }

     resource "aws_iam_user_policy_attachment" "s3_access" {
       user       = "Microservices-admin"
       policy_arn = aws_iam_policy.s3_access.arn
     }

     # Existing Terraform state policy
     resource "aws_iam_policy" "terraform_state" {
       name        = "cloudzenia-terraform-state-access"
       description = "Policy for Terraform state backend access"
       policy = jsonencode({
         Version = "2012-10-17"
         Statement = [
           {
             Effect = "Allow"
             Action = [
               "s3:ListBucket",
               "s3:GetObject",
               "s3:PutObject",
               "s3:DeleteObject"
             ]
             Resource = [
               "arn:aws:s3:::cloudzenia-terraform-state",
               "arn:aws:s3:::cloudzenia-terraform-state/*"
             ]
           },
           {
             Effect = "Allow"
             Action = [
               "dynamodb:GetItem",
               "dynamodb:PutItem",
               "dynamodb:DeleteItem"
             ]
             Resource = "arn:aws:dynamodb:ap-south-1:*:table/cloudzenia-terraform-locks"
           }
         ]
       })
     }

     resource "aws_iam_user_policy_attachment" "terraform_state" {
       user       = "Microservices-admin"
       policy_arn = aws_iam_policy.terraform_state.arn
     }
