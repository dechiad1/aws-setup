/*
* EKS worker policies
*/
resource "aws_iam_role" "eks-worker" {
  name = "eks-worker-node"

  assume_role_policy = <<WORKER_POLICY
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Service": "ec2.amazonaws.com"
			},
			"Action": "sts:AssumeRole"
		}
	]
}
	WORKER_POLICY
}

resource "aws_iam_role_policy_attachment" "eks-worker-AmazonEKSWorkerNodePolicy" {
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks-worker.name}"
}

resource "aws_iam_role_policy_attachment" "eks-worker-AmazonEKS_CNI_Policy" {
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks-worker.name}"
}

resource "aws_iam_role_policy_attachment" "eks-worker-AmazonEC2ContainerRegistryReadOnly" {
	policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks-worker.name}"
}

resource "aws_iam_instance_profile" "eks-worker" {
	name = "eks-worker"
  role = "${aws_iam_role.eks-worker.name}"
}

/*
* EKS worker sg
*/

resource "aws_security_group" "eks-worker" {
	name        = "eks-worker sg"
	description = "security group for traffic to/from eks worker nodes"
  vpc_id      = "${var.eks_vpc_id}"

  egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = "${
		map(
			"Name", "eks-worker-node",
			"kubernetes.io/cluster/${var.eks_cluster_name}", "owned",
		)
	}"
} 

resource "aws_security_group_rule" "eks-worker-ingress-self" {
	description              = "Allow nodes to speak to each other"
	from_port                = 0
	to_port                  = 65535
	protocol                 = "-1"
	security_group_id        = "${aws_security_group.eks-worker.id}"	
	source_security_group_id = "${aws_security_group.eks-worker.id}"
	type                     = "ingress"
}

resource "aws_security_group_rule" "eks-worker-ingress-master" {
	description              = "Allow masters to speak to workers"
	from_port                = 0
	to_port                  = 65535
	protocol                 = "-1"
	security_group_id        = "${aws_security_group.eks-worker.id}"	
	source_security_group_id = "${aws_security_group.eks-cluster.id}"
	type                     = "ingress"
}

/*
* EC2 launch configuration and autoscaling group
*/
data "aws_ami" "eks-worker" {
	filter {
		name   = "name"
		values = ["amazon-eks-node-1.11-v20181210"] #this is usually amazon-eks-node-v* & the most_recent can take it from there 
	}
	
	most_recent = true
	owners      = ["602401143452"] # Amazon EKS AMI Account ID - according to hashi docs
}


locals {
	eks-worker-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks-cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks-cluster.certificate_authority.0.data}' '${var.eks_cluster_name}'
USERDATA
}

resource "aws_launch_configuration" "workers" {
	associate_public_ip_address = false
	iam_instance_profile        = "${aws_iam_instance_profile.eks-worker.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.eks_worker_instance_type}"
	name_prefix                 = "eks-terraform"
	security_groups             = ["${aws_security_group.eks-worker.id}"]
	user_data_base64            = "${base64encode(local.eks-worker-userdata)}"
	key_name                    = "${var.eks_worker_key_name}"

  lifecycle {
		create_before_destroy = true #why do we need this
	}
}

resource "aws_autoscaling_group" "eks-workers" {
	desired_capacity     = "${var.eks_worker_count}"
	launch_configuration = "${aws_launch_configuration.workers.id}"
	max_size             = "${var.eks_worker_count}"
  min_size             = 1
	name                 = "eks-asg"
	vpc_zone_identifier  = ["${var.eks_subnet_1}", "${var.eks_subnet_2}"]

	tag {
		key                 = "Name"
		value               = "eks-workers"
		propagate_at_launch = true
	}

	tag {
		key                 = "kubernetes.io/cluster/${var.eks_cluster_name}"
		value               = "owned"
		propagate_at_launch = true
	}
}
