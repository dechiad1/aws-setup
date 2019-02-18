/*
* launch configuration for ASG 
*/
resource "aws_launch_configuration" "launch-config" {
	associate_public_ip_address = false
	image_id                    = "${var.asg_ami}"
	instance_type               = "${var.asg_instance_type}"
	key_name                    = "${var.asg_key_name}"
	name_prefix                 = "dtd-asg"
	security_groups             = ["${var.asg_vpc_private_sg}"]
}

/*
* ASG - make desired cap the same as max & min for ease of dev
*/
resource "aws_autoscaling_group" "asg" {
	launch_configuration = "${aws_launch_configuration.launch-config.id}"
	vpc_zone_identifier  = ["${var.asg_subnet_1}", "${var.asg_subnet_2}"]
	desired_capacity     = "${var.asg_desired_capacity}"
	max_size             = "${var.asg_desired_capacity}"
	min_size             = 1

	tag {
		key                 = "Name"
		value               = "dtd-asg"
		propagate_at_launch = true
	}
}
