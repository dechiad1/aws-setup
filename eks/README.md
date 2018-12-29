## Summary: 
This module creates an EKS cluster with an ASG for the worker nodes, the master plane and the expected IAM roles & bindings necessary for the system to operate

## Input variables:

Name | Example Value                          
--- | ---
eks_cluster_name | cluster-name
eks_subnet_1 | subnet1.id
eks_subnet_2 | subnet2.id
eks_vpc_id | vpc.id
eks_worker_count | 5
eks_worker_instance_type | t2.medium
workstation_ip | your.workstation.ip.addr/32
eks_worker_key_name | key pair name to ssh

## Example usage
Create a module in a root file. Example below:
```
module "eks" {
  source = "git@github.com:dechiad1/infrastructure-modules.git//eks?ref=master"

	eks_cluster_name = "${var.eks_cluster_name}"
  eks_subnet_1 = "${module.vpc.private_subnet_id_a}"
  eks_subnet_2 = "${module.vpc.private_subnet_id_b}"
  eks_vpc_id = "${module.vpc.vpc_id}"
  eks_worker_count = "${var.eks_worker_count}"
  eks_worker_instance_type = "${var.eks_worker_instance_type}"
  workstation_ip = "${var.workstation_ip}"
  eks_worker_key_name = "${var.eks_worker_key_name}"
}
```
