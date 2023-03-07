variable "aws_region" {
  default = "us-east-1"
}

variable "tf_caller" {
  default = "User"
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_ranges" {
  type = list
}