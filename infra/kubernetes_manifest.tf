locals {
  db_name = replace(local.name, "-", "_")
}

resource "kubectl_manifest" "secrets" {
  depends_on = [module.eks, module.mysql_db, module.postgres_db]

  for_each = {
    # This is used to push newly created KafkaConnect Docker image
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
    mysql-secret = templatefile("${path.module}/manifests/secrets/sql.yaml", {
      name    = "mysql-secret"
      DB_HOST = module.mysql_db.db_instance_address
      DB_USER = module.mysql_db.db_instance_username
      DB_PWD  = base64encode(var.db_password)
      DB_NAME = local.db_name
      DB_PORT = module.mysql_db.db_instance_port
    })
    mongo-secret = templatefile("${path.module}/manifests/secrets/mongo.yaml", {
      name = "mongo-secret"
      DB_HOST = local.mongo.HOST
      DB_USER = local.mongo.USER
      DB_PWD  = base64encode(local.mongo.PWD)
      DB_AUTH = "admin"
    })
    opensearch-secret = templatefile("${path.module}/manifests/secrets/opensearch.yaml", {
      DB_HOST = local.opensearch.HOST
      DB_USER = local.opensearch.USER
      DB_PWD  = base64encode(local.opensearch.PWD)
    })
  }
  yaml_body = each.value
}

data "kubectl_path_documents" "kafka-connects" {
  pattern = "${path.module}/manifests/connectors/**/*.yaml"
  vars = {
    cluster_name = module.eks.cluster_name
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
