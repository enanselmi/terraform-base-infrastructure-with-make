variable "public_subnets" {
  description = "CIDR list for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR list for private subnets"
  type        = list(string)
}

variable "azs" {
  description = "List of AZs"
  type        = list(string)
}

variable "region" {
  description = "Region to deploy resources"
  type        = string
}

variable "tags" {
  description = "Default tags"
  type        = map(string)
}

variable "vpc" {
  description = "VPC variables"
  type        = map(string)
}
