resource "helm_release" "strimzi-kafka-operator" {
  depends_on = [module.eks]

  name             = "strimzi-kafka-operator"
  repository       = "https://strimzi.io/charts/"
  chart            = "strimzi-kafka-operator"
  namespace        = "kafka"
  create_namespace = true
}

resource "helm_release" "opensearch" {
  depends_on = [module.eks]

  name             = "opensearch"
  repository       = "https://opensearch-project.github.io/helm-charts/"
  chart            = "opensearch"
  namespace        = "opensearch"
  create_namespace = true

  values = [
    file("${path.module}/values/opensearch.yaml")
  ]
}

resource "helm_release" "kube-prometheus-stack" {
  depends_on = [module.eks]

  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "68.3.3"
  namespace        = "observability"
  create_namespace = true

  values = [
    file("${path.module}/values/kube-prometheus-stack.yaml")
  ]
}

locals {
  mongo = {
    USER = local.name
    PWD  = var.db_password
    DB   = local.name
  }
}

resource "helm_release" "mongodb" {
  depends_on = [module.eks]

  name             = "mongodb"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "mongodb"
  version          = "16.4.3"
  namespace        = "mongodb"
  create_namespace = true

  values = [
    templatefile("${path.module}/values/mongodb.yaml", local.mongo)
  ]
}