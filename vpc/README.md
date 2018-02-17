##Summary: 
This module creates a VPC with a public and private subnet, where each have a route table and an association. The public subnet's route table points all traffic to an internet gateway and contains a NAT gateway. The private subnet's traffic is routed through the NAT gateway in the public subnet. 

##Input variables:

Name | Example Value                          
--- | ---
aws_vpc_cidr_block | 10.0.0.0/16
aws_subnet_public_cidr_block | 10.0.1.0/24
aws_subnet_public_az | ca-central-1a
aws_subnet_private_cidr_block | 10.0.2.0/24
aws_subnet_private_az | ca-central-1b