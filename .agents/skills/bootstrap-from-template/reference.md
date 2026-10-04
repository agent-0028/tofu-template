# Bootstrap reference

Companion to [SKILL.md](SKILL.md).

## Placeholders

Find them:

```bash
grep -rn "example-bucket-for-state\|template-tofu\|tofu-template-bucket-example" terraform/
```

| File | Template value | Replace with |
|------|----------------|--------------|
| `terraform/nonprod/main.tf` | `bucket = "example-bucket-for-state"` | State bucket |
| `terraform/nonprod/main.tf` | `key = "terraform-state/template-tofu-nonprod/tf"` | `terraform-state/{repo-name}-nonprod/tf` |
| `terraform/prod/main.tf` | `bucket = "example-bucket-for-state"` | State bucket |
| `terraform/prod/main.tf` | `key = "terraform-state/template-tofu-prod/tf"` | `terraform-state/{repo-name}-prod/tf` |
| `terraform/{nonprod,prod}/main.tf` | `# Change this!` comments | Delete |
| `terraform/{nonprod,prod}/variables.tf` | `default = "template-tofu"` | `{repo-name}` |
| `terraform/{nonprod,prod}/example-bucket.tf` | `bucket : "tofu-template-bucket-example"` | Smoke-test base name |
| `terraform/{nonprod,prod}/variables.tf` | `aws_region` default `us-west-2` | Only if using another region — see below |
| `README.md` | `# tofu-template` title and intro line | `# {repo-name}` and a one-line description |

The `bucket` module appends an environment suffix, so a base name of `my-repo-bucket` creates `my-repo-bucket-nonprod` and `my-repo-bucket`.

### Region (only if not `us-west-2`)

| Where | Change |
|-------|--------|
| `terraform/{nonprod,prod}/variables.tf` `aws_region` default | Region for resources (passed to the provider through `module "config"`) |
| `terraform/{nonprod,prod}/main.tf` backend `region` | The **state bucket's** region — can differ from the resource region. |
| `terraform/init-terraform-state/variables.tf` `aws_region` | Only when creating a new bucket |
| GitHub environments `AWS_DEFAULT_REGION` | Same as the resource region |

## State key collision check

An S3 backend stores the `default` workspace at `<key>` and other workspaces at `env:/<workspace>/<key>`. Nonprod runs in `dev`; prod runs in `default`.

```bash
BUCKET=<state-bucket>
REPO=<repo-name>
aws s3 ls "s3://$BUCKET/terraform-state/$REPO-nonprod/"
aws s3 ls "s3://$BUCKET/env:/dev/terraform-state/$REPO-nonprod/"
aws s3 ls "s3://$BUCKET/terraform-state/$REPO-prod/"
```

No output from any of them means the keys are free. Any object means stop and ask the user.

## Local smoke test

```bash
cd terraform/nonprod
tofu init
tofu workspace select --or-create dev
tofu plan

cd ../prod
tofu init
tofu workspace select default
tofu plan
```

Expected for each: `Plan: 2 to add, 0 to change, 0 to destroy.` (`aws_s3_bucket` + `aws_s3_bucket_ownership_controls`).

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `tofu init`: 403 / AccessDenied on state bucket | Missing credentials, wrong account, or bucket owned by someone else | Recheck Checkpoint A; `aws s3api head-bucket --bucket <bucket>` |
| `tofu init`: "Backend configuration changed" | Backend edited after an earlier `init` | `tofu init -reconfigure` (only if no state was written under the old key) |
| `tofu init`: can't fetch `git::https://github.com/agent-0028/deps.git...` | No network, or GitHub unreachable | Retry; the repo is public, no auth needed |
| Plan shows resources to change or destroy | State key already holds another repo's state | Stop. Re-run the collision check |
| Deploy fails: `BucketAlreadyExists` | Smoke-test bucket name taken globally | Pick a more specific base name, re-plan, re-run |
| CI fails on "OpenTofu lint" | Unformatted files | `tofu fmt -recursive terraform/`, commit, push |
| CI fails on credentials or empty region | GitHub environment missing vars/secrets, or names misspelled | Recheck Checkpoint B (vars vs. secret matter) |
| Create-new path: bucket state missing on another machine | `init-terraform-state` uses local state | Use the import steps in `terraform/init-terraform-state/README.md` |
