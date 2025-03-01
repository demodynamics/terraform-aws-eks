terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# ---------------------------------------------------------- EKS Cluster ---------------------------------------------------------- #
resource "aws_iam_role" "eks_cluster_role" {
  description = "${var.default_tags["Project"]} EKS Cluster Role"
  name = "${var.default_tags["Project"]}_eks_cluster_role"
  assume_role_policy = data.aws_iam_policy_document.cluster_role_assume_role_policy.json
}

# # Attaching permissions policies to the EKS clusetr role.
resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  for_each = local.cluster_role_permissions_policy # for_each requires a map or set. ❌for_each does not work directly on a list. ✅ Convert a list to a map if needed. ✅ Use each.key and each.value inside the resource.
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  role       = aws_iam_role.eks_cluster_role.name
}


resource "aws_eks_cluster" "eks_cluster" {
  name = "${var.default_tags["Project"]}_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling. Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_attachment,
  ]
}

# ---------------------------------------------------------- Node Group (Nodes) ---------------------------------------------------------- #

resource "aws_iam_role" "eks_node_group_role" {
  description = "${var.default_tags["Project"]} EKS Node group Role"
  name = "${var.default_tags["Project"]}_eks_node_group_role"
  assume_role_policy = data.aws_iam_policy_document.node_group_role_assume_role_policy.json
}


# # Attaching permissions policies to the Node Group role.
resource "aws_iam_role_policy_attachment" "eks_node_group_role_attachment" {
  for_each = local.node_group_role_permissions_policy # for_each requires a map or set. ❌for_each does not work directly on a list. ✅ Convert a list to a map if needed. ✅ Use each.key and each.value inside the resource.
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  role       = aws_iam_role.eks_node_group_role.name
}

# A node group is one or more EC2 instances that are deployed in an EC2 Auto Scaling group. EKS nodes are standard Amazon EC2 instances.
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.default_tags["Project"]}_node_goup"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.subnet_ids
  
  capacity_type  = var.node_capacity_type
  instance_types = var.node_instance_type

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

# -----------------------------------------------------------Service Account ---------------------------------------------------------- #

# Creating IRSA (IAM Role for Service Accounts) using deafault OIDC provider of EKS cluster.
resource "aws_iam_role" "ecr_image_pull_irsa" {
   description = "ECR Image Pull IRSA for pods"
   name = "ecr_image_pull_irsa"
   assume_role_policy = data.aws_iam_policy_document.irsa_assume_role_policy.json # Generated Assume Role Policy JSON for IRSA
 }

# Attaching permissions policy to the IRSA that will give it to pull images from ECR.
resource "aws_iam_role_policy_attachment" "attachement" {
  role       = aws_iam_role.ecr_image_pull_irsa.name # IRSA name
  policy_arn = "arn:aws:iam::aws:policy/${var.ecr_pull_permissions_policy}" # ECR Pull Permissions Policy Arn

}

# Create Kubernetes Service Account with IRSA annotation
resource "kubernetes_service_account" "ecr_pull_sa" {
  metadata {
    name      = "${var.default_tags["Project"]}-${var.service_account_name}"
    namespace = var.service_account_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.ecr_image_pull_irsa.arn # IRSA Arn
    }
  }
}
