resource "aws_instance" bastion {
	ami                         = "${var.bastion_ami}"
	instance_type               = "${var.bastion_instance_type}"
	key_name                    = "${var.bastion_key_name}"
	vpc_security_group_ids      = ["${var.bastion_security_group}"]
	subnet_id                   = "${var.bastion_subnet}"
	associate_public_ip_address = true	

	tags {
		Name = "Bastion"
	}
}
