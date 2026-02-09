resource "kubernetes_namespace" "retail_app" {
  metadata {
    name = "retail-app"
  }
}

resource "helm_release" "retail_store" {
  name       = "retail-store"
  # FIX: Point to the parent registry, not the full chart path. 
  # Terraform appends the chart name automatically.
  repository = "oci://public.ecr.aws/aws-containers"
  chart      = "retail-store-sample-chart"
  namespace  = kubernetes_namespace.retail_app.metadata[0].name
  
  depends_on = [module.eks]
}
