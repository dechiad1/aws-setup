output "public_subnet_id" {
	value = "${aws_subnet.public-subnet.id}"
}

output "private_subnet_id" {
	value = "${aws_subnet.private-subnet.id}"
}

output "public_security_group_id" {
	value = "${aws_security_group.public.id}"
}

output "private_security_group_id" {
	value = "${aws_security_group.private.id}"
}

output "vpc_id" {
	value = "${aws_vpc.main.id}"
}
