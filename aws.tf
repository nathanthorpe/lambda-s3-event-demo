terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.25.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile

  default_tags {
    tags = {
      createdby = "Terraform"
      application = "Lambda S3 Demo"
      environment = "Dev"
    }
  }
}
