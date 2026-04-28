# L1 Resource: aws_iam_role with an inline policy
# Designed for service roles (Lambda, ECS Task, EC2, etc.)

resource "aws_iam_role" "this" {
  name        = var.role_name
  description = var.description
  path        = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = { Service = var.trusted_service }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = var.role_name
  })
}

resource "aws_iam_role_policy" "this" {
  count  = var.inline_policy_document != null ? 1 : 0
  name   = "${var.role_name}-inline"
  role   = aws_iam_role.this.id
  policy = var.inline_policy_document
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = toset(var.managed_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}
