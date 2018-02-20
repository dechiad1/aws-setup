variable "aws_vpc_cidr_block" {}
variable "aws_subnet_public_cidr_block" {}
variable "aws_subnet_public_az" {}
variable "aws_subnet_private_cidr_block" {}
variable "aws_subnet_private_az" {}
variable "aws_inbound_ip_list" {
	type = "list"
}
variable "public_sg_from_port" {}
variable "public_sg_to_port" {}
