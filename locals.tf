# Creating a Map of Cluster Role Permissions Policy
locals {
 cluster_role_permissions_policy =  {for idx, policy in var.cluster_role_permissions_policy: idx => policy}
}

# Creating a Map of Node group Role Permissions Policy
locals {
 node_group_role_permissions_policy =  {for idx, policy in var.node_group_role_permissions_policy: idx => policy}
}

/*
  The type of brackets around the for expression ([for] and {for}) decide what type of result it produces:
   [for] produces a list: a sequence of values, like ["us-west-1a", "us-west-1c"]. Identify elements in a list with 
      consecutive whole numbers, starting with zero.
   {for} produces a map: A group of key-value pairs (key = value format), like {0="us-west-1a ", 1="us-west-1c"} or 
      {0:"us-west-1a ", 1:"us-west-1c"}` 0:"us-west-1a " and 0="us-west-1a" is the same,  we can use bots methods to set 
      key-value pairs inside a map. Identify elements in a map with their keys` (0 is a key, "us-west-1a" is a value)
 
  In 
  locals {
  cluster_role_permissions_policy =  {for idx, policy in var.cluster_role_permissions_policy: idx => policy}
  }, The idx (index) provides a unique key to each element from the list var.cluster_role_permissions_policy.
  In our case var.cluster_role_permissions_policy is list of string ` ["AmazonEKSClusterPolicy", "AmazonEKSVPCResourceController", "AmazonEKSServicePolicy"]
    cluster_role_permissions_policy = {0 => "AmazonEKSClusterPolicy", 1 => "AmazonEKSVPC ResourceController", 2 => "AmazonEKSServicePolicy"}
    
  As we see Keys are numbers (0, 1, 2) – Even though they look like numbers, Terraform automatically converts them into strings in
  a map (because map keys must be strings).

    So:
    cluster_role_permissions_policy = {
      "0" = "AmazonEKSClusterPolicy"
      "1" = "AmazonEKSVPCResourceController"
      "2" = "AmazonEKSServicePolicy"
     }

   The idx used in {for} expression that generate a map, to set a unique key to a value.

   Limitations of for Expressions
    It can only return lists or maps.
    It cannot produce sets, tuples, or objects directly.
    You may need to use toset(), tolist(), or tomap() to convert the result.
*/