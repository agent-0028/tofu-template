module "example_bucket" {
  source = "git@github.com:agent-0028/deps.git//terraform/modules/bucket?ref=master"
  attributes = {
    bucket : "bucket-example"
  }
  env-suffix = module.config.env-suffix
  env        = module.config.env
  repo       = module.config.repo
}
