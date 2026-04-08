# provider.tf
# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.app_name
      Environment = var.env
      ManagedBy   = "Terraform"
    }
  }
}

# acm certificate
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Configure the cloudflare Provider
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
