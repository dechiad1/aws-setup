/* 
*   main VPC
*/
resource "aws_vpc" "main" {
  cidr_block           = "${var.aws_vpc_cidr_block}"
  enable_dns_hostnames = true 
	tags {
    Name    = "main"
    Purpose = "vpc module"
  }
}

/* 
*  Public subnet
*  internet gateway
*  route table
*  route table association
*/
resource "aws_subnet" "public-subnet" {
    vpc_id            = "${aws_vpc.main.id}"
    cidr_block        = "${var.aws_subnet_public_cidr_block}"
    availability_zone = "${var.aws_subnet_public_az}"
    tags {
        Name = "Public Subnet"
    }
}

resource "aws_internet_gateway" "main-ig" {
    vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "public-rt" {
    vpc_id = "${aws_vpc.main.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main-ig.id}"
    }

    tags {
        Name = "Public Subnet"
    }
}

resource "aws_route_table_association" "public-rta" {
    subnet_id      = "${aws_subnet.public-subnet.id}"
    route_table_id = "${aws_route_table.public-rt.id}"
}

/* 
*  Private subnets
*  private route table
*  private route table association
*  EIP
*  NAT gateway
*/
resource "aws_subnet" "private-subnet-a" {
    vpc_id            = "${aws_vpc.main.id}"
    cidr_block        = "${var.aws_subnet_private_cidr_block_a}"
    availability_zone = "${var.aws_subnet_private_az_a}"
    tags {
        Name = "Private Subnet A"
    }
}

resource "aws_subnet" "private-subnet-b" {
		vpc_id            = "${aws_vpc.main.id}"
		cidr_block        = "${var.aws_subnet_private_cidr_block_b}"
		availability_zone = "${var.aws_subnet_private_az_b}"
		tags {
				Name = "Private Subnet B" 
		}
}

resource "aws_route_table" "private-rt" {
    vpc_id = "${aws_vpc.main.id}"
		
		route {
    	cidr_block = "0.0.0.0/0"
    	gateway_id = "${aws_nat_gateway.nat-gw.id}"
    }
		
		tags {
        Name = "Private Subnet"
    }
}	

resource "aws_route_table_association" "private-rta-a" {
    subnet_id      = "${aws_subnet.private-subnet-a.id}"
    route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_route_table_association" "private-rta-b" {
		subnet_id      = "${aws_subnet.private-subnet-b.id}"
		route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_eip" "nat" {
    vpc        = true
    depends_on = ["aws_internet_gateway.main-ig"]
}

resource "aws_nat_gateway" "nat-gw" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id     = "${aws_subnet.public-subnet.id}"
}

/*
*	Security group public
* Security group private
*/

resource "aws_security_group" "public" {
	name        = "public-sg"
	description = "security group for public access"
	vpc_id      = "${aws_vpc.main.id}"
	
}

resource "aws_security_group" "private" {
	name        = "private-sg"
	description = "security group for private access"
	vpc_id      = "${aws_vpc.main.id}"

}	

/*
*  Public security group rules
*  ingress from itself, private sg & specified internet ips
*  egress to all
*/
resource "aws_security_group_rule" "public-from-self-ingress" {
		type      = "ingress"
		from_port = 0
		to_port   = 0
		protocol  = -1
		security_group_id = "${aws_security_group.public.id}"
		self              = true
}

resource "aws_security_group_rule" "public-from-internet-apps-ingress" {
	type      = "ingress"
	from_port = "${var.public_sg_from_port}"
	to_port   = "${var.public_sg_to_port}"
	protocol  = "tcp"
	security_group_id = "${aws_security_group.public.id}"
	cidr_blocks       = ["${var.aws_inbound_ip_list}"]
}

resource "aws_security_group_rule" "public-from-private-ingress" {
	type      = "ingress"
	from_port = 0
	to_port   = 0
	protocol  = -1
	security_group_id        = "${aws_security_group.public.id}"	
	source_security_group_id = "${aws_security_group.private.id}"	
}	

resource "aws_security_group_rule" "public-to-all-egress" {
	type              = "egress"
	from_port         = 0
	to_port           = 0
	protocol          = -1
	security_group_id = "${aws_security_group.public.id}"
	cidr_blocks       = ["0.0.0.0/0"]
}

/* 
* private security group rules 
* ingress from public & itself
* egress to all
*/
resource "aws_security_group_rule" "private-from-self-ingress" {
	type      = "ingress"
	from_port = 0
	to_port   = 0
	protocol  = -1
	security_group_id = "${aws_security_group.private.id}"
	self              = true
}

resource "aws_security_group_rule" "private-from-public-ingress" {
	type      = "ingress"
	from_port = 0
	to_port   = 0
	protocol  = -1
	security_group_id        = "${aws_security_group.private.id}"
	source_security_group_id = "${aws_security_group.public.id}"
}

resource "aws_security_group_rule" "private-to-all-egress" {	
    type        = "egress"
		from_port   = 0 
		to_port     = 0 
		protocol    = -1
		security_group_id = "${aws_security_group.private.id}"		
		cidr_blocks       = ["0.0.0.0/0"]
}

