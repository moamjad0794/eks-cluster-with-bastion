variable "cluster_name" {
  type = string
  default = "myekscluster"
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "allowed_cidrs" {
  type = list(string)
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  type        = string
}


# variable "authentication_mode" {
#   type    = string
#   default = "CONFIG_MAP"
# }
