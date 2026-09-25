# CDC on EKS — Kafka + Debezium (outbox pattern)

Change Data Capture demo on AWS. Terraform provisions the VPC, an EKS cluster and RDS;
Strimzi runs Kafka in KRaft mode on the cluster; Debezium connectors on Kafka Connect
stream row-level changes from PostgreSQL, MySQL and MongoDB into topics; an OpenSearch
sink connector indexes them. A small Python publisher writes to the source database and
a Python consumer reads the change events. Monitoring is kube-prometheus-stack with a
Strimzi KRaft Grafana dashboard.

## Layout

| Path | What it holds |
| --- | --- |
| `infra/` | Terraform: VPC, EKS, RDS, security groups, Helm releases (Strimzi, MongoDB, OpenSearch, kube-prometheus-stack) |
| `infra/manifests/kafka/` | Strimzi Kafka cluster, KRaft controllers, brokers, storage class |
| `infra/manifests/connectors/` | Kafka Connect plus source (postgres, mysql, mongo) and sink (opensearch) connectors |
| `infra/manifests/monitoring/` | PodMonitors and Grafana dashboard for Strimzi |
| `publisher/` | Python app that writes rows to the source database |
| `consumer/` | Python app that consumes change events |

## Usage

```bash
make deploy                 # terraform init + apply in infra/
make kubeconfig             # write kubeconfig for the EKS cluster
make download-plugin        # fetch the Debezium Postgres connector plugin
make build-publisher-image  # build and push the publisher image
make build-consumer-image   # build and push the consumer image
make helm-install           # install Helm releases
make kafka-setup            # apply Kafka, Connect and connector manifests
make clean                  # tear everything down
```

Set `CLUSTER_NAME` and `DOCKER_REPO` to override the defaults in the Makefile.
