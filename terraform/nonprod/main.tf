provider "aws" {
  region = module.config.aws_region
}

terraform {
  backend "s3" {
    bucket = "grosgrain"
    # Change this!
    # Should be different from prod.
    key    = "terraform-state/template-tofu-nonprod/tf"
    region = "us-west-2"
  }
}

module "config" {
  source = "git@github.com:tinisi/grosgrain.git//terraform/modules/config?ref=master"
  env    = terraform.workspace
  repo   = var.repo
}
output "env-suffix" {
  value = module.config.env-suffix
}

output "env" {
  value = module.config.env
}
