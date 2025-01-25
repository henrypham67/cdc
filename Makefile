# Define variables
CLUSTER_NAME ?= debezium-demo
DOCKER_REPO ?= hieupham0607

# Define paths
PLUGIN_URL = https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/3.0.6.Final/debezium-connector-postgres-3.0.6.Final-plugin.tar.gz
PLUGIN_FILE = debezium-connector-postgres-plugin.tar.gz

TIMECONVERTER_URL = https://github.com/oryanmoshe/debezium-timestamp-converter/releases/download/v1.2.4/TimestampConverter-1.2.4-SNAPSHOT.jar
# Phony targets (not associated with files or directories)
.PHONY: deploy kubeconfig download-plugin build-publisher-image build-consumer-image helm-install kafka-setup all clean

# Initialize and apply Terraform configuration
deploy:
	@echo "Applying Terraform configuration..."
	cd infra && \
	terraform init && \
	terraform apply --auto-approve

# Configure kubeconfig for EKS cluster
kubeconfig:
	@echo "Updating kubeconfig for cluster: $(CLUSTER_NAME)..."
	if [ -e ".kubeconfig" ]; then \
		rm .kubeconfig; \
	fi
	touch .kubeconfig
	aws eks update-kubeconfig --name $(CLUSTER_NAME) --kubeconfig .kubeconfig
	export KUBECONFIG=.kubeconfig

# Download and extract the Debezium PostgreSQL connector plugin
download-plugin:
	mkdir -p connector/plugins
	@echo "Downloading Debezium PostgreSQL connector plugin..."
	curl -L $(PLUGIN_URL) -o connector/$(PLUGIN_FILE)
	@echo "Extracting plugin..."
	tar -xzf connector/$(PLUGIN_FILE) -C connector/plugins/
	curl -L $(TIMECONVERTER_URL) -o connector/plugins/debezium-connector-postgres/TimestampConverter.jar

build-connect-image:
	@echo "Building and pushing connect Docker image..."
	docker build connector -t $(DOCKER_REPO)/debezium-postgres:4
	docker push $(DOCKER_REPO)/debezium-postgres:4

# Build and push publisher Docker image
build-publisher-image:
	@echo "Building and pushing publisher Docker image..."
	docker build publisher -t $(DOCKER_REPO)/debezium-publisher
	docker push $(DOCKER_REPO)/debezium-publisher

# Build and push consumer Docker image
build-consumer-image:
	@echo "Building and pushing consumer Docker image..."
	docker build consumer -t $(DOCKER_REPO)/debezium-consumer
	docker push $(DOCKER_REPO)/debezium-consumer

# Install Strimzi Kafka operator using Helm
helm-install:
	@echo "Installing Strimzi Kafka operator..."
	helm repo add strimzi https://strimzi.io/charts/
	helm repo update
	helm install strimzi-kafka-operator strimzi/strimzi-kafka-operator --namespace kafka --create-namespace

# Set up Kafka cluster
kafka-setup:
	@echo "Setting up Storage Class..."
	kubectl apply -f kafka/sc.yaml

	@echo "Setting up Kafka cluster..."
	kubectl apply -f kafka/kafka-cluster.yaml -n kafka
	kubectl apply -f kafka/pool.yaml -n kafka
	kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka
	
	@echo "Setting up ..."
	kubectl apply -f kafka/db-role.yaml -n kafka
	kubectl apply -f kafka/db-rolebinding.yaml -n kafka
	kubectl apply -f kafka/db-secret.yaml -n kafka
	
	@echo "Setting up ..."
	kubectl apply -f connector/debezium-connect.yaml -n kafka
	kubectl apply -f connector/postgres-connector.yaml -n kafka



# Convenience target to perform all actions
all: deploy kubeconfig download-plugin build-publisher-image build-consumer-image helm-install kafka-setup

# Clean up temporary files
clean:
	@echo "Cleaning up temporary files..."
	rm -f $(PLUGIN_FILE)
	rm -f .kubeconfig
