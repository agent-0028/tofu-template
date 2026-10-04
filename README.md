# tofu-template

A template repo for OpenTofu projects.

## Repo and pipeline set up

### 1. State bucket

Decide whether to **reuse an existing S3 state bucket** or **create a new one**.

**Reuse (common for additional projects in the same AWS account):**

- Skip `terraform/init-terraform-state/` entirely.
- Verify access: `aws s3api head-bucket --bucket $YOUR_BUCKET_NAME`
- Use the bucket name in the backend blocks below.

**Create new (first project, no shared bucket yet):**

- Follow [`terraform/init-terraform-state/README.md`](terraform/init-terraform-state/README.md).
- Customize `terraform/init-terraform-state/bucket-for-state.tf` with your bucket name.
- Run `tofu init`, `tofu plan`, and `tofu apply` locally in that directory.
- This is the **only** local `tofu apply` allowed — see [`AGENTS.md`](AGENTS.md).

### 2. Remote backends

Change `terraform/nonprod/main.tf` and `terraform/prod/main.tf`:

- Set `bucket` to your state bucket (not `example-bucket-for-state`).
- Set `key` to a unique path per environment. Pattern:

  ```
  terraform-state/{repo-name}-{env}/tf
  ```

  For example: `terraform-state/my-repo-nonprod/tf` and `terraform-state/my-repo-prod/tf`.

Also update `var.repo` in `terraform/nonprod/variables.tf` and `terraform/prod/variables.tf`.

### 3. GitHub Actions environments

Create two environments in this repository's GitHub settings:

- `prod`
- `nonprod`

In **both** environments, configure:

- **Secret:** `AWS_SECRET_ACCESS_KEY`
- **Variable:** `AWS_ACCESS_KEY_ID`
- **Variable:** `AWS_DEFAULT_REGION`

### 4. Validate

Run workflows manually from the Actions tab (`workflow_dispatch`):

1. **Check Infra nonprod** — plan only
2. **Deploy Infra nonprod** — plan and apply
3. **Check Infra prod** — plan only
4. **Deploy Infra prod** — plan and apply

Use **Check** workflows on feature branches. Use **Deploy** workflows after merging to `main`.

## Setup for local dev

Install [OpenTofu](https://opentofu.org). Use local commands to verify a plan; use GitHub Actions to apply or destroy infrastructure in `terraform/nonprod/` and `terraform/prod/`.

```
tofu init
tofu fmt
tofu plan
```

Do **not** run `tofu apply` or `tofu destroy` locally for nonprod or prod — use the GitHub Actions workflows instead.

## Local Dev Cheat Sheet

### Non-prod

```
cd terraform/nonprod
tofu workspace select --or-create dev
tofu plan
```

### Prod

```
cd terraform/prod
tofu workspace select default
tofu plan
```
