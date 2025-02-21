output "eks_cluster_role" {
  description = "Name and Arn of ${var.project} EKS Cluster Role"
  value = {
  name = aws_iam_role.eks_cluster_role.name
  arn  = aws_iam_role.eks_cluster_role.arn
  }
}

output "eks_node_group_role" {
  description = "Name and Arn of ${var.project} EKS Node Group Role"
  value = {
  name = aws_iam_role.eks_node_group_role.name
  arn  = aws_iam_role.eks_node_group_role.arn
  }
}
