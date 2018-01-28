/* 
*   main VPC
*/
resource "aws_vpc" "main" {
  cidr_block = "${var.aws_vpc_cidr_block}"
  tags {
    Name = "main"
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
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${var.aws_subnet_public_cidr_block}"
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

resource "aws_nat_gateway" "nat_gw" {
    allocation_id = "${aws_eip.nat.id}"
    subnet        = "${aws_subnet.public-subnet.id}"
}


