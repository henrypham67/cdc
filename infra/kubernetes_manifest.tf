# resource "kubernetes_manifest" "manifests" {
#   depends_on = [ module.eks, helm_release.strimzi-kafka-operator ]

#   for_each = {
#     sc        = file("${path.module}/../kafka/sc.yaml")
#     cluster   = file("${path.module}/../kafka/kafka-cluster.yaml")
#     pool   = file("${path.module}/../kafka/pool.yaml")
#     secret    = templatefile("${path.module}/../kafka/db-secret.yaml", { DB_HOST = module.db.db_instance_address })
#     role      = file("${path.module}/../kafka/db-role.yaml")
#     rolebinding      = file("${path.module}/../kafka/db-rolebinding.yaml")
#     connect   = file("${path.module}/../connector/debezium-connect.yaml")
#     connector = file("${path.module}/../connector/postgres-connector.yaml")
#   }

#   manifest = yamldecode(each.value)
# }
