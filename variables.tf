variable "project" {
  type = string
}

variable "policy_type" {
    type = list(string)
}

variable "role_assumer_type" {
    type = string
}

variable "cluster_role_assumer" {
    type = list(string)
}

variable "node_group_role_assumer" {
    type = list(string)
}


variable "cluster_role_permissions_policy" {
  type = list(string)
}

variable "node_group_role_permissions_policy" {
  type = list(string)
}


variable "subnet_ids" {
  type = list(string)
}
