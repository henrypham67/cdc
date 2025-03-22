resource "helm_release" "strimzi-kafka-operator" {
  depends_on = [module.eks]

  name             = "strimzi-kafka-operator"
  repository       = "https://strimzi.io/charts/"
  chart            = "strimzi-kafka-operator"
  namespace        = "kafka"
  create_namespace = true
}

locals {
  mongo = {
    USER = local.name
    PWD  = var.db_password
    DB   = local.name
  }
}
