variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-west-2"
}

variable "aws_vpc_cidr_block" {}
variable "aws_subnet_public_az" {}
variable "aws_subnet_public_cidr_block" {}
variable "aws_subnet_private_az" {}
variable "aws_subnet_private_cidr_block" {}

