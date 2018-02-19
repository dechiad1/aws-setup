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
*  Private subnet
*  private route table
*  private route table association
*  EIP
*  NAT gateway
*/
resource "aws_subnet" "private-subnet" {
    vpc_id            = "${aws_vpc.main.id}"
    cidr_block        = "${var.aws_subnet_private_cidr_block}"
    availability_zone = "${var.aws_subnet_private_az}"
    tags {
        Name    = "Private Subnet"
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

resource "aws_route_table_association" "private-rta" {
    subnet_id      = "${aws_subnet.private-subnet.id}"
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
	
	/* ingress for all traffic of instances within the same sg */		
	ingress {
		from_port = 0
		to_port   = 0
		protocol  = -1
		self = true
	}
	
  /* access into the public subnet */
	ingress {
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = ["${var.aws_inbound_ip_list}"]
	}
	
	/* egress should be allowed for all traffic */
	egress {
		from_port   = 0
		to_port     = 0
		protocol    = -1
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "private" {
	name        = "private-sg"
	description = "security group for private access"
	vpc_id      = "${aws_vpc.main.id}"

	/* ingress for all traffic of instances within the same sg */		
	ingress {
		from_port = 0
		to_port   = 0
		protocol  = -1
		self = true
	}

	/* egress should be for all */
	egress {
		from_port   = 0 
		to_port     = 0 
		protocol    = -1
		cidr_blocks = ["0.0.0.0/0"]
	}
}	

/*
*  Now define the rules for the created public & private SGs to allow traffic to each other 
*/

resource "aws_security_group_rule" "public-to-private-ingress" {
	type      = "ingress"
	from_port = 0
	to_port   = 0
	protocol  = -1
	security_group_id        = "${aws_security_group.public.id}"	
	source_security_group_id = "${aws_security_group.private.id}"	
}

resource "aws_security_group_rule" "private-to-public-ingress" {
	type      = "ingress"
	from_port = 0
	to_port   = 0
	protocol  = -1
	security_group_id        = "${aws_security_group.private.id}"
	source_security_group_id = "${aws_security_group.public.id}"
}
