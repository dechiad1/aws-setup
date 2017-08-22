/* main VPC
*/
resource "aws_vpc" "main" {
  cidr_block = "${var.aws_vpc_cidr_block}"
  tags {
    Name = "main"
    Purpose = "terraform-practice"
  }
}

/* 
*  Public subnet
*  internet gateway
*  route table
*  route table association
*/
resource "aws_subnet" "us-west-2a-public" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${var.aws_subnet_public_cidr_block}"
    availability_zone = "${var.aws_subnet_public_az}"
    tags {
        Name = "Public Subnet"
        Purpose = "terraform-practice"
    }
}

resource "aws_internet_gateway" "main-ig" {
    vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "us-west-2a-public" {
    vpc_id = "${aws_vpc.main.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main-ig.id}"
    }

    tags {
        Name = "Public Subnet"
    }
}

resource "aws_route_table_association" "us-west-2a-public" {
    subnet_id = "${aws_subnet.us-west-2a-public.id}"
    route_table_id = "${aws_route_table.us-west-2a-public.id}"
}

/* 
*  Private subnet
*/
resource "aws_subnet" "us-west-2b-private" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${var.aws_subnet_private_cidr_block}"
    availability_zone = "${var.aws_subnet_private_az}"
    tags {
        Name = "Private Subnet"
        Purpose = "terraform-practice"
    }
}

resource "aws_route_table" "us-west-2b-private" {
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "Private Subnet"
    }
}

resource "aws_route_table_association" "us-west-2b-private" {
    subnet_id = "${aws_subnet.us-west-2b-private.id}"
    route_table_id = "${aws_route_table.us-west-2b-private.id}"
}
