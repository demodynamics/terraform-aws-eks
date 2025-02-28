/*
# Fetching data from our EKS cluster's default OIDC provider
data "aws_iam_openid_connect_provider" "oidc" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}


resource "aws_iam_role" "ecr_image_pull_irsa" {
  name = "eks-irsa-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${data.aws_iam_openid_connect_provider.oidc.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:default:${kubernetes_service_account.sa.namespace}:${kubernetes_service_account.sa.name}"
        }
      }
    }
  ]
}
EOF
}

# ---------------------- Creating permissions policy for IRSA, that lets to pull images from any ECR Private Repository ----------------------

resource "aws_iam_policy" "all_ecr_pull_policy" {
  name        = "AllECRPullPolicy"
  description = "Allows EKS to pull images from any ECR repository"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:DescribeRepositories",
        "ecr:GetAuthorizationToken"
      ],
      Resource =["*"]
    }]
  })
}

# Attaching this policy to the IRSA
resource "aws_iam_role_policy_attachment" "ecr_pull_irsa_attachment" {
  policy_arn = aws_iam_policy.all_ecr_pull_policy.arn
  role       = aws_iam_role.ecr_image_pull_irsa.name
}



# ----------------------  Creating  permissions policy for IRSA, that lets to pull images from Specific ECR Private Repository ----------------------
resource "aws_iam_policy" "specific_ecr_pull_policy" {
  name        = "SpecificECRPullPolicy"
  description = "Allows EKS to pull images from specific ECR repository"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:DescribeRepositories",
        "ecr:GetAuthorizationToken"
      ],
      resources = [
      "arn:aws:ecr:us-east-1:${data.aws_caller_identity.current.account_id}:repository/repository-name" #${data.aws_caller_identity.current.account_id}: This fetches the AWS account ID dynamically, so you don’t need to hardcode it.

    ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_pull_irsa_attachment" {
  policy_arn = aws_iam_policy.specific_ecr_pull_policy.arn
  role       = aws_iam_role.ecr_image_pull_irsa.name
}


*/