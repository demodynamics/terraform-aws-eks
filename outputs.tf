output "eks_cluster_role" {
  value = {
  name = aws_iam_role.eks_cluster_role.name
  arn  = aws_iam_role.eks_cluster_role.arn
  }
}

output "eks_node_group_role" {
  value = {
  name = aws_iam_role.eks_node_group_role.name
  arn  = aws_iam_role.eks_node_group_role.arn
  }
}
