---
name: bootstrap-from-template
description: >-
  Bootstrap a new repo created from tofu-template: AWS credentials check,
  state bucket reuse-or-create, wire OpenTofu S3 backends and repo name,
  GitHub Actions environments, CI validation, and agent-log.md. Use when
  template placeholders remain (example-bucket-for-state, template-tofu,
  tofu-template-bucket-example), init-terraform-state is mentioned, or the
  user is setting up a new tofu-template fork.
---

# Bootstrap a repo from tofu-template

Turn a fresh copy of [tofu-template](https://github.com/agent-0028/tofu-template) into a working OpenTofu repo with remote state and a GitHub Actions pipeline.

Exact commands, the placeholder table, and troubleshooting are in [reference.md](reference.md).

## Rules

- Follow `AGENTS.md`: run `tofu plan` locally; `apply`/`destroy` only through GitHub Actions. The one exception is `terraform/init-terraform-state/` on the create-new-bucket path.
- Never handle AWS secrets. The user configures credentials and GitHub secrets themselves.
- Pause at every **Checkpoint** and wait for the user.
- Log every decision, command, and outcome to `agent-log.md`.

## Steps

### 0. Check whether bootstrap is needed

- If `git remote get-url origin` points at `agent-0028/tofu-template` itself, stop: this is the template, not a fork.
- Search `terraform/` for the placeholders in [reference.md](reference.md#placeholders). No hits → already bootstrapped; say so and stop.

### 1. Read first

- `AGENTS.md`
- `README.md` — setup overview
- `terraform/init-terraform-state/README.md` — only if creating a new state bucket

### 2. Start logging

Append a dated "Bootstrap" section to `agent-log.md` at the repo root (create it if missing). Keep appending through every step.

### 3. Gather inputs

Ask the user, proposing defaults, and log the answers:

| Input | Default |
|-------|---------|
| Repo name | Last path segment of `git remote get-url origin` (else the directory name) |
| AWS region | `us-west-2` |
| State bucket | Reuse an existing bucket (ask for the name) or create a new one |
| Smoke-test bucket base name | `{repo-name}-bucket` — S3 names are global, so the template name will collide |

### 4. Checkpoint A — AWS credentials

Run `aws sts get-caller-identity`. If it fails, stop and ask the user to create an IAM access key and configure the AWS CLI (they can reuse keys from another tofu-template repo). Resume when it succeeds.

### 5. State bucket

- **Reuse:** `aws s3api head-bucket --bucket <bucket>` must succeed. Skip `init-terraform-state`.
- **Create:** follow `terraform/init-terraform-state/README.md`. Set the bucket name (and region, if not `us-west-2`), run `tofu init` and `tofu plan`, **pause for review**, then the user approves the one local `tofu apply`. Warn the user that this bucket's state lives only in `terraform/init-terraform-state/state/` on this machine.

### 6. State key collision check — hard stop

Keys follow `terraform-state/{repo-name}-{env}/tf`. Check that both are empty (commands in [reference.md](reference.md#state-key-collision-check)). Nonprod uses the `dev` workspace, so its state sits under `env:/dev/`.

If anything exists, stop and ask the user: another repo may own that state. Do not overwrite or delete it.

### 7. Code changes

Make the edits in [reference.md](reference.md#placeholders): backends, `var.repo`, smoke-test bucket names, README title, and region if not `us-west-2`. Leave module sources (`agent-0028/deps`) unchanged.

Run `tofu fmt -recursive terraform/` — CI fails on unformatted code.

### 8. Local smoke test (plan only)

Run `tofu init` and `tofu plan` in `terraform/nonprod` (`dev` workspace) and `terraform/prod` (`default` workspace).

Expected: only the smoke-test bucket and its ownership controls to add; nothing to change or destroy. This is a private bucket with no URL to visit.

**Pause** so the user can review the plans and commit.

### 9. Checkpoint B — GitHub environments

Ask the user to create environments `nonprod` and `prod` (Settings → Environments), each with:

- Variable `AWS_ACCESS_KEY_ID`
- Variable `AWS_DEFAULT_REGION` (the region from step 3)
- Secret `AWS_SECRET_ACCESS_KEY`

If `gh` is available, confirm with `gh api repos/{owner}/{repo}/environments`. Otherwise wait for the user to confirm.

### 10. Checkpoint C — CI validation

All workflows are manual (`workflow_dispatch`, Actions tab). The user runs them; log each result.

1. On the feature branch: **Check Infra nonprod**, **Check Infra prod**
2. After merging to `main`: **Deploy Infra nonprod** → optionally **Destroy Infra nonprod** → **Deploy Infra prod**

### 11. Wrap up

- Summarize the bootstrap in `agent-log.md`.
- Problems in the template itself: suggest an issue or PR on `agent-0028/tofu-template`.
- App-specific infrastructure is a separate task. Replace or remove `example-bucket.tf` when real resources arrive.
