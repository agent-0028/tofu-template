# template-tofu
A template repo for OpenTofu projects.

## Local Dev notes

### Non-prod

```
tofu workspace select --or-create dev
```

### Prod

```
tofu workspace select default
```

## All environments

```
tofu plan
tofu apply
tofo destroy
```

## Repo set up

* Change `nonprod/main.tf` to specify a new key for state instead of `terraform-state/template-tofu-nonprod/tf"`

* Change `prod/main.tf` to specify a new key for state instead of `terraform-state/template-tofu-prod/tf`

* Populate these secrets in all environments
    * `AWS_SECRET_ACCESS_KEY`
    * `SSH_PRIV_FOR_GROSGRAIN`

* Populate these environment variables in all environments
    * `AWS_ACCESS_KEY_ID`
    * `AWS_DEFAULT_REGION`
