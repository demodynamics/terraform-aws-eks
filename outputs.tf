output "eks_cluster_role" {
  description = "Name and Arn of EKS Cluster Role"
  value = {
  name = aws_iam_role.eks_cluster_role.name
  arn  = aws_iam_role.eks_cluster_role.arn
  }
}

output "eks_node_group_role" {
  description = "Name and Arn of EKS Node Group Role"
  value = {
  name = aws_iam_role.eks_node_group_role.name
  arn  = aws_iam_role.eks_node_group_role.arn
  }
}

output "eks_cluster_name" {
  description = "Name of EKS Cluster"
  value = aws_eks_cluster.eks_cluster.name
}

output "ecr_pull_service_account_name" {
  description = "Service Account Name for Pulling Images from Private ECR"
  value = kubernetes_service_account.ecr_pull_sa.metadata
}
