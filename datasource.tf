# Obtain the name of the AWS region configured on the provider.btain the name of the AWS region configured on the provider.
data "aws_region" "current" {}

#This retrieves the current AWS account information, including the account_id dynamically.
data "aws_caller_identity" "current" {}

# Fetching data from our EKS cluster's default OIDC provider
data "aws_iam_openid_connect_provider" "oidc" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

# Generating JSON of Assume Role policy(trust policy) for EKS Cluster Role
data "aws_iam_policy_document" "cluster_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"] # Allows The role to be assumed via STS, to whom will be attached this Assume Role policy (trust policy) JSON
    principals { 
      type        = "Service" # Defines the entity that can assume the role: AWS Service can asume the role
      identifiers = ["eks.amazonaws.com"] # EKS service is allowed to assume the role to whom will be attached this Assume Role policy (trust policy) JSON: EKS is allowed to assume the role and permissions policy(ies) that will be attached to that role.
    }
  }
}
# Generating json of Assume Role policy(trust policy) for EKS Node Group Role
data "aws_iam_policy_document" "node_group_role_assume_role_policy" {
  statement {
    actions =  ["sts:AssumeRole"]
    principals { 
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Generating json of Assume Role policy(trust policy) for IRSA
data "aws_iam_policy_document" "irsa_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"] # Allows The role to be assumed by OIDC identity tokens, to whom will be attached this Assume Role policy (trust policy) JSON 

    principals {
      type        = "Federated" # Specifies that the principal is a federated identity provider.
      identifiers = [data.aws_iam_openid_connect_provider.oidc.arn] # The OIDC provider ARN for authentication.
    }

    condition {
      test     = "StringEquals" # Ensures the condition must exactly match the provided values.
      variable = "oidc.eks.${data.aws_region.current.name}.${data.aws_caller_identity.current.account_id}:sub" # Specifies the subject claim from the OIDC token.
      values   = ["system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"] # A specific Kubernetes service account is allowed to assume the role to whom will be attached this Assume Role policy (trust policy) JSON 
    }
  }
}

/*
# Generating json of permissions for for self managed permissions policy, that lets to pull images from ECR Private Repository
data "aws_iam_policy_document" "ecr_pull_policy" {
  statement {
    sid    = "AllowECRPull"
    effect = "Allow"
    actions = ["ecr:GetDownloadUrlForLayer","ecr:BatchGetImage","ecr:BatchCheckLayerAvailability","ecr:DescribeRepositories","ecr:GetAuthorizationToken"]

    resources = ["*"]
    # resources = [
    #   "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${var.ecr_repo}" #${data.aws_caller_identity.current.account_id}: This fetches the AWS account ID dynamically, so you don’t need to hardcode it.
    # ]
  }
}

#Creating self managed permissions policy and adding generated json of permissions to it, that lets to pull images from ECR Private Repository
resource "aws_iam_policy" "ecr_pull_policy" {
  name        = "AllowECRPull"
  description = "A policy for ECR access"
  policy      = data.aws_iam_policy_document.ecr_pull_policy.json # Adding Generated json of permissions from above,that lets to pull images from ECR Private Repository
}
*/


/*
Using aws_iam_policy_document in Terraform is a best practice for generating IAM policies because it provides a structured and maintainable way to
define policies. Here’s why:

Advantages of aws_iam_policy_document:
  
  Readability & Maintainability
    Instead of writing JSON inline, Terraform allows you to use HCL (HashiCorp Configuration Language), which is more readable and structured.

  Built-in Validation
    Terraform ensures the policy is valid before applying it, reducing errors.

  Easier Interpolation & Referencing
    You can dynamically insert ARNs, resource names, and other Terraform variables.

  Reduces Errors
    Eliminates manual JSON formatting issues and reduces the chance of syntax mistakes.

  Reusable & Modular
    Can be used across multiple resources (e.g., IAM roles, policies, users) without needing to copy-paste JSON.


Conclusion
  For most Terraform projects, using aws_iam_policy_document is strongly recommended because it enhances readability, reduces errors, and simplifies 
  policy management.

*/