#This retrieves the current AWS account information, including the account_id dynamically.
data "aws_caller_identity" "current" {}

# Fetching data from our EKS cluster's default OIDC provider
data "aws_iam_openid_connect_provider" "oidc" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

#Generating Assume Role policy for EKS Cluster Role
data "aws_iam_policy_document" "cluster_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { 
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}
#Generating Assume Role policy for EKS Node Group Role
data "aws_iam_policy_document" "node_group_role_assume_role_policy" {
  statement {
    actions =  ["sts:AssumeRole"]
    principals { 
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Generating Assume Role policy for IRSA
data "aws_iam_policy_document" "irsa_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.oidc.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "oidc.eks.${var.region}.${data.aws_caller_identity.current.account_id}:sub"
      values   = ["system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"]
    }
  }
}







