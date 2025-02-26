variable "project" {
  description = "Project name"
  type = string
}

variable "policy_type" {
  description = "Indentifier in statement block of policy that defines which type of policy will be generated: Permissions Policy or Assume Role Policy"
  type = list(string)
}

variable "role_assumer_type" {
  description = "Type of role assumer : What type of AWS object will be assume the role ` AWS (User or Role) or Service"
  type = string
}

variable "cluster_role_assumer" {
  description = "Identifier of Cluster Role asuumer : Who Will asume the Role" 
  type = list(string)
}

variable "node_group_role_assumer" {
  description = "Identifier of Node Group Role asuumer : Who Will asume the Role" 
  type = list(string)
}


variable "cluster_role_permissions_policy" {
  description = "List of permissions policy for Cluster Role"
  type = list(string)
}

variable "node_group_role_permissions_policy" {
  description = "List of permissions policy for Node Group Role"
  type = list(string)
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