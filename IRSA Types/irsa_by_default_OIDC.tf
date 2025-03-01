/*
# Fetching data from our EKS cluster's default OIDC provider
  data "aws_iam_openid_connect_provider" "oidc" {
    url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  }

# ---------------------- Creating IRSA (IAM Role fro Service Accounts) (with assume role policy inside) ----------------------

resource "aws_iam_role" "ecr_image_pull_irsa" {
  name = "ecr_image_pull_irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.oidc.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "oidc.eks.us-east-1.${data.aws_caller_identity.current.account_id}:sub" = "system:serviceaccount:${var.service_account_name}:${var.service_account_namespace}"
          #The IAM role (IRSA in this case) is created first using static values from variables (var.service_account_namespace and var.service_account_name)
          #The Kubernetes service account is then created with the same values, avoiding dependency loops.
          #Terraform can now resolve resource creation in the correct order.
        
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

# Attaching this self-managed permissions policy to the IRSA
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
# Attaching this self-managed permissions policy to the IRSA
resource "aws_iam_role_policy_attachment" "ecr_pull_irsa_attachment" {
  policy_arn = aws_iam_policy.specific_ecr_pull_policy.arn
  role       = aws_iam_role.ecr_image_pull_irsa.name
}



# Create Kubernetes Service Account with IRSA annotation
resource "kubernetes_service_account" "ecr_pull_sa" {
  metadata {
    name      = var.service_account_name
    namespace = var.service_account_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.ecr_image_pull_irsa.arn # IRSA Arn
    }
  }
}

# The Service Account(s) in Kubernetes (EKS) cluster also coud be created by Deployment YAML File.

(ex.`service-account.yaml`):
apiVersion: v1
kind: ServiceAccount
metadata:
  name: <Service Account Name> - # name ofthe service account
  namespace: <Service Account Namespace>  # namespace in cluster in which the service account is created. We can use any custom namespace as needed.

#The service account(s) attached to pods in Kuberntes Deployment YAML file through `spec.serviceAccount` field.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      serviceAccountName: <Service Account Name>  # Using the service account here
      containers:
      - name: my-container
        image: <aws-account-id>.dkr.ecr.<region>.amazonaws.com/my-repository:latest
        ports:
        - containerPort: 8080
*/


/*
# -------------------------  aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer -------------------------

    This is a list with one item (identity is a block in aws_eks_cluster).
    [0] ensures we access the first (and only) item.

identity[0].oidc
    The oidc field inside identity is also a list with one item.
[   0] ensures we access the first (and only) OIDC provider.


oidc[0].issuer
    This retrieves the OIDC issuer URL, which is needed for IRSA.

Why Is [0] Required?
    Terraform treats these attributes as lists, even though there is usually only one item.
    Omitting [0] would cause an error because Terraform expects an index when dealing with lists.

Final Answer:
✅ The [0] is required because identity and oidc are lists with a single element, and we must explicitly select the first item. 🚀
*/

#************************************************************ IRSA ******************************************************************************

/*Creating IRSA (an IAM Role For Service Accounts) for EKS: 
IRSA is an IAM Role with a trust policy (Assume Role Policy), which allows Kubernetes (EKS) cluster's'service account(s) to assume that IAM Role 
    using (as Principal) the OIDC Identity Provider (IdP) of that Kubernetes (EKS) cluster, which (the OIDC Identity Provider (IdP)) is automatically 
    created along with  Kubernetes (EKS) cluster creation. This allows the service accounts to access AWS resources described in permissions policy 
    attached to that IAM Role. Therfore, the pod(s) inside that kubernetes (EKS) cluster that will use that service account(s) also will get access to 
    AWS resources described in permissions policy attached to that IAM Role.
So, IRSA is used to give access the pod(s) inside kubernetes cluster to AWS resources using that cluster's OIDC Identity Provider (IdP).
So, instead of using AWS IAM Role and give Node(s) (Node Group) inside EKS Cluster access to AWS resources (ex.`to pull image from ECR), we use IRSA 
  (an IAM Role For Service Accounts) and give pod(s) inside that Node(s) of EKS Cluster access to AWS resources (ex.`to pull image from ECR.
So IAM Role give Node level access to AWS resources (ex.`pull images from ECR ito EKS cluster), IRSA pod level access to AWS resources (ex.`pull images 
   from ECR ito EKS cluster).

So IRSA is the most secure way to access to AWS resources from cluster and give AWS resources access to cluster.


In simple terms:
IRSA (IAM Role for Service Accounts) is the IAM Role that links a Kubernetes (EKS Cluser) service account to an IAM role via an OIDC Identity 
Provider of the Kubernetes (EKS) cluster.
The IAM Role defines the permissions (e.g., to pull images from ECR) and the OIDC trust relationship allows the service account to asume that IAM 
Role and authenticate to AWS, and then authenticate (give accesss) the pod that connected with that service account  and pull images from ECR.
     Key Parts:
        1.IAM Role: The role that defines the AWS permissions (e.g., access to ECR).
        2.Trust Relationship: The trust policy (Assume Role Policy) that specifies that only the Kubernetes cluster service account(s) (authenticated 
        using OIDC Identity Provider (IdP)) can assume the role.
        3.Kubernetes Service Account: The service account that pod use. pod can use the service account to get access to AWS resources 
        (e.g., ECR - and pull images from ECR.) 

        Pods do not assume roles directly—they just use the service account, which using OIDC Trust Relationship assumes the IAM role and the permissions
        poilicy attached to it.

The trust policy is the assume_role_policy inside the IAM role definition. Specifically, it is the jsonencode({ ... }) block, which defines which 
entities are allowed to assume the role.


    Breakdown of the Trust Policy (Trust Relationship):
       Key Components of the Trust Policy:

                1.Principal
                    Principal = {
                    Federated = data.aws_iam_openid_connect_provider.oidc.arn
                    }
                    
                    Federated - This specifies who can assume the role.
                    aws_iam_openid_connect_provider.eks.arn - The Identity of assumer` The OIDC Identity Provider (IdP) of EKS Cluster
                        The OIDC Identity Provider (IdP) is automatically created and registered in AWS IAM when we create an EKS cluster.
                        The OIDC Identity Provider (IdP) itself does not assume the role, it only acts as an authentication mechanism.
                        The OIDC identity provider is authenticate the EKS Cluster for which it is cretaed, and the service account(s) iside that 
                        EKS cluster can assume the role using that OIDC identity provider.
                        Kubernetes (EKS Cluster) service account (SA) is mapped to an IAM role via the OIDC provider.

                    So, The OIDC identity provider is an authentication provider that lets EKS cluster service accounts assume IAM roles and the 
                    permissions poilicy attached to it.

                   
                    In Kubernetes (EKS Cluster), pods do not have direct IAM identities. 
                    Service accounts are identities for pods.
                    Instead, they use service accounts that assume IAM role and the permissions poilicy attached to it through OIDC identity provider.
                    Kubernetes (EKS Cluster) Service Account asuming IAM Role and the permissions poilicy attached to it through The OIDC identity 
                    provider, which allows that Kubernetes (EKS Cluster) workload (pod), which using that Service Account, authenticate to AWS 
                    services described in the permissions poilicy attached to IAM Role and access that AWS resources.
                        Example: A pod using the service account that assume the IAM role with ECR access permissions policy through The OIDC 
                        identity provider, also gets ECR access.

                    Summary:
                    The OIDC provider represents the entire EKS cluster’s authentication system.
                    Pods indirectly assume IAM roles via service accounts.
                    The actual IAM identity is granted to Kubernetes (EKS Cluster) service accounts, which pods use.

                 2.Action
                    Action = "sts:AssumeRoleWithWebIdentity"
                    This allows the role to be assumed using web identity federation (OIDC authentication).

                3.Condition
                    Condition = {
                    StringEquals = {
                        "oidc.eks.us-east-1.amazonaws.com/id/<EKS_OIDC_ID>:sub" = "system:serviceaccount:${var.service_account_name}:${var.service_account_namespace}"
                    }
                    }
                    This ensures that only the specific Kubernetes (EKS Cluster) service account (var.service_account_name) in the (var.service_account_namespace) namespace can 
                    assume the role.
Summary
The entire assume_role_policy block is the OIDC Trust Relationship (trust policy) because it defines who is allowed to assume the IAM role. It ensures 
that only the specific Kubernetes (EKS) Cluster service(s) account can use the role via that Kubernetes (EKS) cluster’s OIDC provider.

Final Key Understanding
🚀 OIDC provider = Authenticator (verifies identities, does NOT assume roles)
🚀 Service Account = Identity (gets verified and can assume the role)
🚀 IAM Role = Permission Set (trusted service accounts can assume it)
🚀 Pod = Workload (uses the service account to access AWS resources)
     
*/

