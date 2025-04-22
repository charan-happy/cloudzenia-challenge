# cloudzenia-challenge

![image](https://github.com/user-attachments/assets/398be53a-6858-4e98-9752-33b8d7b0bc3a)


## Overview

This project deploys a comprehensive AWS infrastructure using Terraform, addressing all CloudZenia requirements:

Challenge 1: ECS Fargate with WordPress and Node.js microservice, RDS MySQL, SecretsManager, ALB with HTTPS.
Challenge 2: Two EC2 instances with NGINX, Docker, Let’s Encrypt SSL, and ALB.
Observability: CloudWatch alarms, dashboard, and centralized logging.
Automation: GitHub Actions for CI/CD of the microservice and infrastructure.
S3 Static Hosting: Documentation site at docs.nagacharan.site.
Cost Management: AWS Budget for cost monitoring.
State Management: Terraform state stored in S3 with DynamoDB locking.

## Architecture

VPC: 2 public and 2 private subnets across 2 AZs.
Challenge 1:
ECS Fargate cluster with WordPress and microservice.
RDS MySQL (t4g.micro) in private subnets with backups.
SecretsManager for RDS credentials.
ALB with ACM certificate, HTTP-to-HTTPS redirect.


Challenge 2:
2 EC2 instances (t3.micro) with Elastic IPs.
NGINX serving "Hello from Instance" and proxying to Docker.
Let’s Encrypt for SSL.
CloudWatch for RAM metrics and NGINX logs.


Observability:
CloudWatch alarms for ECS/EC2 CPU/memory (>80%).
Dashboard for ECS, EC2, RDS metrics.
Log groups for ECS tasks and EC2 NGINX logs.


S3 Static Hosting:
S3 bucket hosting documentation site.
Route 53 record for docs.nagacharan.site.


Cost Management:
AWS Budget ($50/month, 80% threshold alerts).


Terraform State:
S3 bucket: cloudzenia-terraform-state
DynamoDB table: cloudzenia-terraform-locks
State file: cloudzenia/terraform.tfstate



## DNS Configuration

Domain: nagacharan.site (registered with Hostinger).
DNS Management: AWS Route 53 (Hosted Zone ID: Z05135773VBNXAZ3YSQ5W).
Steps:
Delegated DNS to Route 53 via Hostinger name servers.
Terraform creates Route 53 records for subdomains and ACM validation.



## Endpoints

Challenge 1:
WordPress: https://wordpress.nagacharan.site
Microservice: https://microservice.nagacharan.site


Challenge 2:
Instance 1: https://ec2-instance1.nagacharan.site
Docker 1: https://ec2-docker1.nagacharan.site
Instance 2: https://ec2-instance2.nagacharan.site
Docker 2: https://ec2-docker2.nagacharan.site
ALB Instance: https://ec2-alb-instance.nagacharan.site
ALB Docker: https://ec2-alb-docker.nagacharan.site


S3 Static Site:
Documentation: http://docs.nagacharan.site



## Setup Steps

Clone: `git clone https://github.com/<your-username>/cloudzenia-challenge.git`
Deploy backend resources:cd bootstrap
terraform init
terraform apply


Configure AWS credentials and GitHub Secrets (TF_VAR_db_password, TF_VAR_hosted_zone_id).
Deploy main infrastructure:cd terraform
terraform init
terraform apply


Upload S3 content:aws s3 sync ./docs/ s3://cloudzenia-static-site-vh6xuuwz/


Push microservice to ECR via GitHub Actions.
Verify endpoints and observability.

**Notes**

Resolved dependency cycle between ECS and RDS.
Fixed ALB outputs, db_password, EC2 EIP, Secrets Manager outputs.
Corrected terraform.tfvars syntax.
Implemented observability with CloudWatch alarms, dashboard, and logs.
Automated microservice and infrastructure deployment with GitHub Actions.
Configured S3 static hosting and AWS Budget.
Added Terraform state backend with S3 and DynamoDB.
Fixed S3 bucket name error by using lowercase random suffix.
Resolved Secrets Manager error by force-deleting wordpress-db-password in deploy.yml.
Fixed hosted_zone_id error by setting correct Route 53 ID (Z05135773VBNXAZ3YSQ5W).
Fixed RDS password error by ensuring db_password >=8 characters.
Fixed docs.nagacharan.site by reapplying Terraform to create Route 53 A record aliased to S3 website endpoint (cloudzenia-static-site-vh6xuuwz.s3-website.ap-south-1.amazonaws.com).
Pending: Resolve 503 error across ALB endpoints (health checks, ECS/EC2 services).

## Cost Management

Used Free Tier (t3.micro, t4g.micro, Fargate).
AWS Budget monitors costs ($50/month).
Destroy after 48 hours: terraform destroy.

## Repository

GitHub: https://github.com/charan-happy/cloudzenia-challenge



