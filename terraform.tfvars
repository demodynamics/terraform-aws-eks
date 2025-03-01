ecr_pull_permissions_policy = "AmazonEC2ContainerRegistryReadOnly"
cluster_role_permissions_policy = ["AmazonEKSClusterPolicy", "AmazonEKSVPCResourceController", "AmazonEKSServicePolicy"]
node_group_role_permissions_policy = ["AmazonEKSWorkerNodePolicy", "AmazonEKS_CNI_Policy", "AmazonEC2ContainerRegistryReadOnly", "AmazonEC2ReadOnlyAccess"]
subnet_ids = [""]
node_scale_desired_size = 1
node_scale_max_size = 2
node_scale_min_size = 1
node_capacity_type = "ON_DEMAND"
node_instance_type = ["t2.micro"]
service_account_name = "ecr-access"
service_account_namespace = "default"

default_tags = {
  Owner = "Demo Dynamics"
  Environment = "Dev"
  Project = "Alco24"
}
