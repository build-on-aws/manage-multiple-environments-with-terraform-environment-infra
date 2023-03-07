module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "CodeCatalyst-Terraform"
  cidr = var.vpc_cidr

  azs            = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  public_subnets = var.public_subnet_ranges

  enable_nat_gateway = false
  enable_vpn_gateway = false
}