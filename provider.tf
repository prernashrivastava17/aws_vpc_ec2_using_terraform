terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  access_key = "AKIARQHZTVT6YHL72KMJ"
  secret_key = "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"
  region     = "ap-southeast-1"
}
