terraform {
  backend "s3" {
    bucket = "terraform-remote-state-example1"
    key    = "insurance-backend/dev1"
    region = "us-east-1"
  }
}