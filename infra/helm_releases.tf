resource "helm_release" "strimzi-kafka-operator" {
  depends_on = [ module.eks ]
  
  name       = "strimzi-kafka-operator"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  namespace  = "kafka"
  create_namespace = true
}

resource "helm_release" "strimzi-kafka-operator" {
  depends_on = [ module.eks ]
  
  name       = "strimzi-kafka-operator"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  namespace  = "kafka"
  create_namespace = true
}