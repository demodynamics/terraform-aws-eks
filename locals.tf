locals {
 cluster_role_permissions_policy =  {for idx, id in var.cluster_role_permissions_policy: idx => id}
}

locals {
 node_group_role_permissions_policy =  {for idx, id in var.node_group_role_permissions_policy: idx => id}
}