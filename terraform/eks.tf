module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "project-bedrock-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  # KMS Disabled to prevent permission errors
  create_kms_key            = false
  cluster_encryption_config = {}

  # Subnets for Control Plane
  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.private_subnets

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  eks_managed_node_groups = {
    initial = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      
      # CHANGED: t3.medium -> t3.micro (Free Tier Eligible)
      instance_types = ["t3.micro"]

      # Subnets for Worker Nodes
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

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name = module.eks.cluster_name
  addon_name   = "amazon-cloudwatch-observability"
  depends_on   = [module.eks]
}
