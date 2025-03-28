# resource "helm_release" "lakekeeper" {
#   depends_on = [module.eks, aws_s3_bucket.iceberg_bucket]

#   name             = "lakekeeper"
#   repository       = "https://lakekeeper.github.io/lakekeeper-charts/"
#   chart            = "lakekeeper"
#   namespace        = "kafka"
#   create_namespace = true
# }

data "kubectl_path_documents" "iceberg_rest" {
  pattern = "${path.module}/manifests/iceberg-rest/deployment.yaml"
  
  vars = {
    AWS_ACCESS_KEY_ID = "" # in case you dont have pod identity or IRSA
    AWS_SECRET_ACCESS_KEY = ""
    AWS_S3_BUCKET = "s3://${local.bucket_name}"
  }
}

resource "kubectl_manifest" "iceberg_rest" {
  for_each  = data.kubectl_path_documents.iceberg_rest.manifests
  yaml_body = each.value
}