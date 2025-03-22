locals {
  db_name     = replace(local.name, "-", "_")
  bucket_name = "${local.name}-${data.aws_caller_identity.current.account_id}"
}

resource "kubectl_manifest" "secrets" {
  depends_on = [module.eks, module.postgres_db]

  for_each = {
    docker-hub = templatefile("${path.module}/manifests/secrets/docker-hub.yaml", {
      DOCKER_SECRET = var.docker_hub
    })
    pg-secret = templatefile("${path.module}/manifests/secrets/sql.yaml", {
      name    = "postgres-secret"
      DB_HOST = module.postgres_db.db_instance_address
      DB_USER = module.postgres_db.db_instance_username
      DB_PWD  = base64encode(var.db_password)
      DB_NAME = local.db_name
      DB_PORT = module.postgres_db.db_instance_port
    })
  }
  yaml_body = each.value
}

data "kubectl_path_documents" "kafka-connects" {
  pattern = "${path.module}/manifests/connectors/**/*.yaml"
  vars = {
    cluster_name  = module.eks.cluster_name
    AWS_S3_BUCKET = local.bucket_name
  }
}

data "kubectl_path_documents" "db" {
  pattern = "${path.module}/manifests/db/*.yaml"
  vars = {
    cluster_name = module.eks.cluster_name
  }
}

data "kubectl_path_documents" "kafka" {
  pattern = "${path.module}/manifests/kafka/*.yaml"
  vars = {
    cluster_name = module.eks.cluster_name
  }
}

resource "kubectl_manifest" "kafka" {
  depends_on = [module.eks, helm_release.strimzi-kafka-operator]

  for_each = merge(
    data.kubectl_path_documents.db.manifests,
    data.kubectl_path_documents.kafka.manifests,
    data.kubectl_path_documents.kafka-connects.manifests
  )
  yaml_body = each.value
}
