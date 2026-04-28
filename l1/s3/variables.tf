variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
}

variable "versioning_enabled" {
  description = "Whether to enable versioning on the bucket."
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules."
  type = list(object({
    id              = string
    prefix          = string
    expiration_days = number
  }))
  default = []
}

variable "tags" {
  description = "Additional tags to merge onto all resources."
  type        = map(string)
  default     = {}
}
