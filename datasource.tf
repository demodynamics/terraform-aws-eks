#Generating Assume Role policy for EKS Cluster Role
data "aws_iam_policy_document" "cluster_role_assume_role_policy" {
  statement {
    actions = var.policy_type
    principals { 
      type        = var.role_assumer_type
      identifiers = var.cluster_role_assumer
    }
  }
}
#Generating Assume Role policy for EKS Node Group Role
data "aws_iam_policy_document" "node_group_role_assume_role_policy" {
  statement {
    actions = var.policy_type
    principals { 
      type        = var.role_assumer_type
      identifiers = var.node_group_role_assumer
    }
  }
}



