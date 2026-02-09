module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "project-bedrock-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  create_kms_key            = false
  cluster_encryption_config = {}

  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.private_subnets

  # Requirement 4.4: Control Plane Logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  eks_managed_node_groups = {
    initial = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      # Keeping t3.micro for Free Tier
      instance_types = ["t3.micro"]

      subnet_ids = module.vpc.private_subnets
      
      tags = {
        "Project" = "Bedrock"
      }
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    "Project" = "Bedrock"
  }
}

# REMOVED: aws_eks_addon resource to prevent timeouts on t3.micro nodes
