# Configure the AWS Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  # Las credenciales se toman automáticamente de:
  # 1. Variables de entorno (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
  # 2. Archivo ~/.aws/credentials

  default_tags {
    tags = {
      Project     = var.prefix_name
      ManagedBy   = "Terraform"
      Environment = "Development"
    }
  }
}