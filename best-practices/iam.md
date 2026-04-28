# IAM Terraform Best Practices

## Least Privilege
- Grant only the minimum permissions required.
- Never use `"Action": "*"` or `"Resource": "*"` in production policies.
- Scope `Resource` to specific ARN patterns.

## Roles over Users
- Use IAM roles for EC2, Lambda, ECS, and service-to-service access.
- Never embed access keys in code or Terraform files.

## Policy Structure
- Separate policies by function (one policy per service/action group).
- Use managed policies for common patterns, inline policies for resource-specific rules.
- Add `Condition` blocks to restrict access by source IP, MFA, or VPC endpoint.

## Naming
- Roles: `<project>-<env>-<purpose>-role`
- Policies: `<project>-<env>-<purpose>-policy`

## Trust Policies
- Restrict `Principal` to the specific AWS service or account.
- Never use `"Principal": "*"` in trust policies.

## Example Minimal Role (for Lambda)
```hcl
resource "aws_iam_role" "lambda_exec" {
  name = "acme-prod-lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}
```

## Audit
- Enable AWS IAM Access Analyzer in all regions.
- Review and rotate IAM credentials regularly.
- Tag all roles and policies with Owner and Project.
