module "example_bucket" {
  source = "git@github.com:tinisi/grosgrain.git//terraform/modules/bucket?ref=master"
  attributes = {
    bucket : "tinisi-example"
  }
  env-suffix = module.config.env-suffix
  env        = module.config.env
  repo       = module.config.repo
}