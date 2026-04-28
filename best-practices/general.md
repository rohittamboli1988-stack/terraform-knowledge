# General Terraform Best Practices

## Naming Convention
- Use lowercase letters, numbers, and hyphens only.
- Format: `<project>-<environment>-<resource-type>[-<suffix>]`
- Example: `acme-prod-vpc`, `acme-dev-s3-logs`

## Required Tags
Every resource MUST carry these tags:
```hcl
tags = {
  Name        = "<resource name>"
  Project     = "<project name>"
  Environment = "<dev|staging|prod>"
  Owner       = "<team or email>"
  ManagedBy   = "terraform"
}
```

## Resource Organization
- One resource type per `.tf` file (e.g. `vpc.tf`, `subnet.tf`).
- Variables in `variables.tf`, outputs in `outputs.tf`, providers in `versions.tf`.
- Use `locals {}` for repeated computed values.

## State Management
- Always use a remote backend (S3 + DynamoDB for AWS).
- Never commit `terraform.tfstate` to version control.

## Variables
- Always provide a `description` for every variable.
- Use `type` constraints — never use untyped `any` unless unavoidable.
- Sensitive values must be marked `sensitive = true`.

## Security
- Enable encryption at rest for all storage resources.
- Block public access on all S3 buckets by default.
- Apply least-privilege IAM policies — no `*` actions on sensitive services.
- Enable VPC Flow Logs on all VPCs.
- Enable CloudTrail in all regions.

## Versioning
- Pin provider versions: `version = "~> 5.0"` (minor updates allowed).
- Pin Terraform version: `required_version = ">= 1.5"`.
