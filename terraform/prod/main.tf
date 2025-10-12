provider "aws" {
  region = module.config.aws_region
}

terraform {
  backend "s3" {
    bucket = "grosgrain"
    # Change this!
    # Should be different from nonprod.
    key    = "terraform-state/template-tofu-prod/tf"
    region = "us-west-2"
  }
}

module "config" {
  source = "git@github.com:tinisi/grosgrain.git//terraform/modules/config?ref=master"
  env    = "prod"
  repo   = var.repo
}
output "env-suffix" {
  value = module.config.env-suffix
}

output "env" {
  value = module.config.env
}
