resource "kubernetes_namespace" "retail_app" {
  metadata {
    name = "retail-app"
  }
}

resource "helm_release" "retail_store" {
  name       = "retail-store"
  repository = "oci://public.ecr.aws/aws-containers/retail-store-sample-chart"
  chart      = "retail-store-sample-chart"
  namespace  = kubernetes_namespace.retail_app.metadata[0].name
  
  # Wait for the cluster to be ready
  depends_on = [module.eks]
}
