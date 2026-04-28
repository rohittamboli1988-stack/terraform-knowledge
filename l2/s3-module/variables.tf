variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
}

variable "versioning_enabled" {
  description = "Enable bucket versioning."
  type        = bool
  default     = true
}

variable "lifecycle_enabled" {
  description = "Enable lifecycle transitions and expiration rules."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for SSE-KMS. Null = use AES256."
  type        = string
  default     = null
}

variable "access_log_bucket_id" {
  description = "Bucket ID to write access logs to. Null = disabled."
  type        = string
  default     = null
}

variable "bucket_policy_json" {
  description = "JSON bucket policy string. Null = no policy."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the bucket."
  type        = map(string)
  default     = {}
}
