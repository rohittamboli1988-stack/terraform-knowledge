variable "name" {
  description = "Name prefix for all resources in this module."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g. 10.0.0.0/16)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to use."
  type        = number
  default     = 2
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway for all AZs (cheaper for dev; not HA)."
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "CloudWatch log retention for VPC Flow Logs (days)."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}
