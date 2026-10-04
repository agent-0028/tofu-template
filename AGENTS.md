# Instructions for AI Coding Agents

This is a Terraform infrastructure project.

We are using OpenTofu, so the command line tool is `tofu`.

OpenTofu v1.11.1 is compatible with Terraform v1.5.7 and earlier versions.

Many examples online will use the official Terraform command line client,  `terraform`.

## Principles

The goal with this project is to utilize the GitHub Actions pipeline as much as possible.

Coding agents and humans should avoid running `tofu apply` or `tofu destroy` locally.

The one exception is `terraform/init-terraform-state/`, which uses local state and is applied locally once, only when creating a new state bucket. See its `README.md`.

Instead, code should be merged and pushed to GitHub and run using GitHub Actions through the web console.

## Practices

You can run `tofu plan` locally to smoke test changes.

Pause and allow the user to review and commit changes when you are getting expected output from `tofu plan`.

Always run `tofu fmt` to auto-correct formatting.
