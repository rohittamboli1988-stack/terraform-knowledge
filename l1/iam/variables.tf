variable "role_name" {
  description = "Name of the IAM role."
  type        = string
}

variable "description" {
  description = "Human-readable description of the role."
  type        = string
  default     = ""
}

variable "trusted_service" {
  description = "AWS service principal to trust (e.g. 'lambda.amazonaws.com')."
  type        = string
}

variable "inline_policy_document" {
  description = "JSON string of the inline IAM policy. Null = no inline policy."
  type        = string
  default     = null
  sensitive   = false
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to merge onto the role."
  type        = map(string)
  default     = {}
}
