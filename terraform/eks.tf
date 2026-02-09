module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "project-bedrock-cluster"
  cluster_version = "1.29" 

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Requirement 4.4: Control Plane Logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  eks_managed_node_groups = {
    initial = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.medium"]
      
      # Tagging requirement
      tags = {
        "Project" = "Bedrock"
      }
    }
  }

  # Grant the creator (you/Terraform) admin permissions
  enable_cluster_creator_admin_permissions = true

  tags = {
    "Project" = "Bedrock"
  }
}

# Requirement 4.4: Application Logging (CloudWatch Addon)
resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name = module.eks.cluster_name
  addon_name   = "amazon-cloudwatch-observability"
  depends_on   = [module.eks]
}
