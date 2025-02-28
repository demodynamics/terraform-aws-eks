variable "project" {
  description = "Project name"
  type = string
}

variable "region" {
  description = "AWS region"
  type = string
}


variable "cluster_role_permissions_policy" {
  description = "List of AWS managed permissions policy for Cluster Role"
  type = list(string)
}

variable "node_group_role_permissions_policy" {
  description = "List of AWS managed permissions policy for Node Group Role"
  type = list(string)
}

variable "service_account_name" {
  description = "Service Account Name for IRSA that pull images from ECR Private Repository"
  type = string

}
variable "service_account_namespace" {
  description = "Service Account Namespace for IRSA that pull images from ECR Private Repository"
  type = string
}


variable "ecr_pull_permissions_policy" {
  description = "An AWS managed permissions policy that wiill give IRSA to pull images from ECR Private Repository "
  type = string
}

variable "subnet_ids" {
  description = "Subnet ID's of VPC Where the cluster and it's nodes will be created"
  type = list(string)
}

 variable "node_scale_desired_size" {
   description = "Scaling Config for EKS Node Group: Desired Count of Nodes"
   type = number
 }

 variable "node_scale_max_size" {
   description = "Scaling Config for EKS Node Group: Max Count of Nodes"
   type = number
 }

 variable "node_scale_min_size" {
   description = "Scaling Config for EKS Node Group: Min Count Of Nodes"
   type = number
 }

 variable "node_capacity_type" {
   description = "Pricing and Provisioning Type of AWS EC2 instances` Node(s) : On-Demand: More expensive but reliable or Spot: Cheaper but can be interrupted or terminated by AWS"
   type = string
 }

 variable "node_instance_type" {
   description = "EKS Node(s) Instance Type"
   type = list(string)
 }