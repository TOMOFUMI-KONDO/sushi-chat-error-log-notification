terraform {
  backend "s3" {
    bucket = "sushi-chat-error-log-notification-terraform-181562662531"
    key    = "prod/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  profile = var.profile
}
