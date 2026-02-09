resource "kubernetes_namespace" "retail_app" {
  metadata {
    name = "retail-app"
  }
}

resource "helm_release" "retail_store" {
  name       = "retail-store"
  repository = "oci://public.ecr.aws/aws-containers"
  chart      = "retail-store-sample-chart"
  namespace  = kubernetes_namespace.retail_app.metadata[0].name
  
  # --- THE FIX ---
  # Don't fail if pods take too long to start on tiny nodes
  wait       = false 
  timeout    = 900 # Increase timeout to 15 minutes just in case
  # ---------------

  depends_on = [module.eks]
}
