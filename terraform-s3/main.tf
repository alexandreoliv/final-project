terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_dynamodb_table" "terraform_lock_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = var.dynamodb_table_name
  }
}

resource "aws_s3_bucket" "terraform-state-storage" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

variable "bucket_name" {
  type    = string
  default = "alex-project3-state-bucket"
}

variable "dynamodb_table_name" {
  type    = string
  default = "project3-terraform-lock-table"
}

variable "aws_region" {
  type        = string
  default     = "us-west-2"
}