terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.56.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.58.0"
    }
  }
}

# Make sure you enabled Compute Engine API
provider "google" {
  # use GOOGLE_CREDENTIALS environment variable
  region  = var.gcp_region1
  project = var.gcp_project_id
}

provider "aws" {
  region = var.aws_region1
  # use AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables
}
