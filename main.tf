terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project}_eks_cluster_role"
  assume_role_policy = data.aws_iam_policy_document.cluster_role_assume_role_policy.json
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.project}_eks_node_group_role"
  assume_role_policy = data.aws_iam_policy_document.node_group_role_assume_role_policy.json
}

# # # For Actions on EKS
resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  for_each = local.cluster_role_permissions_policy # for_each requires a map or set. ❌for_each does not work directly on a list. ✅ Convert a list to a map if needed. ✅ Use each.key and each.value inside the resource.
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  role       = aws_iam_role.eks_cluster_role.name
}

# # For Actions on EC2
resource "aws_iam_role_policy_attachment" "eks_node_group_role_attachment" {
  for_each = local.node_group_role_permissions_policy # for_each requires a map or set. ❌for_each does not work directly on a list. ✅ Convert a list to a map if needed. ✅ Use each.key and each.value inside the resource.
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_eks_cluster" "eks_cluster" {
  name = "${var.project}_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling. Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_attachment,
  ]
}


resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.project}_node_goup"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.node_scale_desired_size
    max_size     = var.node_scale_max_size
    min_size     = var.node_scale_min_size
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_role_attachment,
  ]
}