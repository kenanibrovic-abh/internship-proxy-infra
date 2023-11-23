terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "tfstate-nginx-reverse-proxy"
    key = "terraform.tfstate"
    region = "eu-central-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

