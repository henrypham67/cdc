# Define variables
CLUSTER_NAME ?= debezium-demo
DOCKER_REPO ?= hieupham0607

# Define paths
PLUGIN_URL = https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/3.0.6.Final/debezium-connector-postgres-3.0.6.Final-plugin.tar.gz
PLUGIN_FILE = debezium-connector-postgres-plugin.tar.gz

TIMECONVERTER_URL = https://github.com/oryanmoshe/debezium-timestamp-converter/releases/download/v1.2.4/TimestampConverter-1.2.4-SNAPSHOT.jar
KUBECONFIG_PATH=/tmp/.${CLUSTER_NAME}-kubeconfig

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
	@if [ -e "${KUBECONFIG_PATH}" ]; then \
		rm "${KUBECONFIG_PATH}"; \
	fi
	@touch "${KUBECONFIG_PATH}"
	@aws eks update-kubeconfig --name $(CLUSTER_NAME) --kubeconfig "${KUBECONFIG_PATH}"
	
	@echo "Run the bellow command in your current terminal"
	export KUBECONFIG="${KUBECONFIG_PATH}"

# Download and extract the Debezium PostgreSQL connector plugin
download-plugin:
	mkdir -p connector/plugins
	@echo "Downloading Debezium PostgreSQL connector plugin..."
	curl -L $(PLUGIN_URL) -o connector/$(PLUGIN_FILE)
	@echo "Extracting plugin..."
	tar -xzf connector/$(PLUGIN_FILE) -C connector/plugins/
	curl -L $(TIMECONVERTER_URL) -o connector/plugins/debezium-connector-postgres/TimestampConverter.jar

build-connect-image-for-pg:
	@echo "PostgreSQL"
	docker build infra/manifests/connectors/postgres -t $(DOCKER_REPO)/debezium-connect:postgres
	docker push $(DOCKER_REPO)/debezium-connect:postgres

build-connect-image-for-mysql:
	@echo "MySQL"
	docker build infra/manifests/connectors/mysql -t $(DOCKER_REPO)/debezium-connect:mysql
	docker push $(DOCKER_REPO)/debezium-connect:mysql

build-connect-image:
	@echo "Building and pushing connect Docker image..."
	${MAKE} build-connect-image-for-pg
	${MAKE} build-connect-image-for-mysql

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

EXEC_CMD=kubectl exec -it debezium-connect-cluster-connect-0 --

list-topics:
	${EXEC_CMD} bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --list

consume-topics:
	${EXEC_CMD} bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic my-topic --from-beginning

# Clean up temporary files
clean:
	@echo "Cleaning up temporary files..."
	rm -f $(PLUGIN_FILE)
	rm -f .kubeconfig
