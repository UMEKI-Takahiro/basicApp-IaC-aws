terraform {
  backend "s3" {
    bucket  = "tfstate-basic-app"
    key     = "prod/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}
