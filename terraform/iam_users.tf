# 1. Create the IAM User
resource "aws_iam_user" "dev_view" {
  name = "bedrock-dev-view"
  tags = { "Project" = "Bedrock" }
}

# 2. Generate Access Keys (Required for Deliverable)
resource "aws_iam_access_key" "dev_view_key" {
  user = aws_iam_user.dev_view.name
}

# 3. Attach ReadOnlyAccess (AWS Console Access)
resource "aws_iam_user_policy_attachment" "console_read_only" {
  user       = aws_iam_user.dev_view.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# 4. Map User to EKS for Cluster Access
# This uses the new EKS Access Entry API (replaces aws-auth configmap)
resource "aws_eks_access_entry" "dev_view_access" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = aws_iam_user.dev_view.arn
  kubernetes_groups = ["bedrock-viewers"] # We map them to this internal k8s group
  type              = "STANDARD"
}

# 5. Define Kubernetes RBAC (The ClusterRole and Binding)
resource "kubernetes_cluster_role" "view_role" {
  metadata {
    name = "bedrock-view-role"
  }
  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources  = ["pods", "deployments", "services", "configmaps", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "view_binding" {
  metadata {
    name = "bedrock-view-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.view_role.metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "bedrock-viewers" # Must match kubernetes_groups in aws_eks_access_entry
    api_group = "rbac.authorization.k8s.io"
  }
}
