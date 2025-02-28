/*

data "tls_certificate" "eks_oidc" {
# url: It points to the URL of the OIDC provider, which, in this case, is the OIDC issuer URL from your EKS cluster.
# This URL is the source of the identity information that AWS will trust (e.g., service account identities from your Kubernetes cluster).
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer 
}


resource "aws_iam_openid_connect_provider" "eks_oidc" {
# client_id_list: This is a list of valid client IDs that AWS trusts for the OIDC provider. sts.amazonaws.com is typically used here to allow AWS Security Token Service(STS) to issue temporary credentials.
  client_id_list  = ["sts.amazonaws.com"]
# thumbprint_list: This is a list of SHA1 fingerprints for the OIDC provider’s SSL/TLS certificate. AWS uses this to validate the authenticity of the OIDC issuer’s certificate.
# In our code, we're using the tls_certificate data source to fetch the certificate and generate its fingerprint (sha1_fingerprint). 
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
# url: It points to the URL of the OIDC provider, which, in this case, is the OIDC issuer URL from your EKS cluster.
# This URL is the source of the identity information that AWS will trust (e.g., service account identities from your Kubernetes cluster).
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

# ---------------------- Creating IRSA (IAM Role fro Service Accounts) (with assume role policy inside) ----------------------

resource "aws_iam_role" "ecr_image_pull_irsa" {
  name = "ecr_image_pull_irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
       #Federated = "${aws_iam_openid_connect_provider.eks_oidc.arn}" # This syntax (with ${}) was necessary in older versions of Terraform (before 0.12) for string interpolation.
        Federated = aws_iam_openid_connect_provider.eks_oidc.arn
        #This syntax (without ${}) is preferred in newer versions of Terraform (0.12+), where string interpolation is automatic for resource references.
        # In Terraform 0.12 and later,This syntax form is cleaner and works as expected, so there's no need for ${} around resource references. 
        # Both versions will resolve correctly, but using This syntax form is more idiomatic and recommended.
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "oidc.eks.us-east-1.${data.aws_caller_identity.current.account_id}:sub" = "system:serviceaccount:${kubernetes_service_account.sa.namespace}:${kubernetes_service_account.sa.name}"
        }
      }
    }]
  })
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
      Resource = ["*"]
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

# Attaching this policy to the IRSA
resource "aws_iam_role_policy_attachment" "ecr_pull_irsa_attachment" {
  policy_arn = aws_iam_policy.specific_ecr_pull_policy.arn
  role       = aws_iam_role.ecr_image_pull_irsa.name
}


*/