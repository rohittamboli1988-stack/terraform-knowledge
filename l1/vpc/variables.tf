variable "name" {
  description = "Name tag for the VPC."
  type        = string
}

variable "cidr_block" {
  description = "IPv4 CIDR block for the VPC (e.g. 10.0.0.0/16)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "Additional tags to merge onto all resources."
  type        = map(string)
  default     = {}
}
