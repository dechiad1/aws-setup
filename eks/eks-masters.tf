/*
* EKS master IAM role & associated policies
*/
resource "aws_iam_role" "eks-cluster" {
	name = "${var.eks_cluster_name}"
  
	assume_role_policy = <<MASTER_POLICY
{
	"Version" : "2012-10-17",
  "Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Service": "eks.amazonaws.com"
			},
		"Action": "sts:AssumeRole"
		}
	]
}
	MASTER_POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks-cluster.name}"
}

/*
* EKS master plane security groups
*/
resource "aws_security_group" "eks-cluster" {
	name        = "eks-cluster-masters"
  description = "sg for eks master plane"
  vpc_id      = "${var.eks_vpc_id}"

  egress {
		from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
	}

  tags {
		Name = "${var.eks_cluster_name}"
	}
}

resource "aws_security_group_rule" "eks-cluster-masterplane-workstation-ingress" {
	cidr_blocks       = ["${var.workstation_ip}"]
  description       = "Allow workstation to speak to api server"
	from_port         = 443
  to_port           = 443
  protocol          = "tcp"
	security_group_id = "${aws_security_group.eks-cluster.id}"
  type              = "ingress"
}

resource "aws_security_group_rule" "eks-cluster-masterplane-workernodes-ingress" {
  description              = "Allow workers to speak to api server"
	from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
	security_group_id        = "${aws_security_group.eks-cluster.id}"
	source_security_group_id = "${aws_security_group.eks-worker.id}"
  type                     = "ingress"
}

/*
* EKS master plane
*/
resource "aws_eks_cluster" "eks-cluster" {
	name     = "${var.eks_cluster_name}"
	role_arn = "${aws_iam_role.eks-cluster.arn}"

  vpc_config {
		security_group_ids = ["${aws_security_group.eks-cluster.id}"]
    subnet_ids         = ["${var.eks_subnet_1}", "${var.eks_subnet_2}"]
	}

	depends_on = [
		"aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy",
		"aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy",
	]
}
