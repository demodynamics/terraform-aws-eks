project = "alco24"
policy_type = ["sts:AssumeRole"]
role_assumer_type = "Service"
cluster_role_assumer = ["eks.amazonaws.com"]
cluster_role_permissions_policy = ["AmazonEKSClusterPolicy", "AmazonEKSVPCResourceController", "AmazonEKSServicePolicy"]
node_group_role_assumer =  ["ec2.amazonaws.com"]
node_group_role_permissions_policy = ["AmazonEKSWorkerNodePolicy", "AmazonEKS_CNI_Policy", "AmazonEC2ContainerRegistryReadOnly", "AmazonEC2ReadOnlyAccess"]
subnet_ids = [""]