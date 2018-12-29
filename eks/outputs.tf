output "eks_worker_arn" {
	value = "${aws_iam_role.eks-worker.arn}"
}

output "worker_sg_id" {
	value = "${aws_security_group.eks-worker.id}"
}
