#! /bin/bash

mkdir -p kafka-connect/plugins && cd kafka-connect/plugins

wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/3.0.6.Final/debezium-connector-postgres-3.0.6.Final-plugin.tar.gz
tar -xzf debezium-connector-postgres-3.0.6.Final-plugin.tar.gz
wget https://github.com/oryanmoshe/debezium-timestamp-converter/releases/download/v1.2.4/TimestampConverter-1.2.4-SNAPSHOT.jar
mv TimestampConverter-1.2.4-SNAPSHOT.jar debezium-connector-postgres

wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-mongodb/3.0.7.Final/debezium-connector-mongodb-3.0.7.Final-plugin.tar.gz
tar zxvf debezium-connector-mongodb-3.0.7.Final-plugin.tar.gz

wget https://hub-downloads.confluent.io/api/plugins/tabular/iceberg-kafka-connect/versions/0.6.19/tabular-iceberg-kafka-connect-0.6.19.zip
unzip tabular-iceberg-kafka-connect-0.6.19.zip

wget https://d2p6pa21dvn84.cloudfront.net/api/plugins/confluentinc/kafka-connect-datagen/versions/0.6.6/confluentinc-kafka-connect-datagen-0.6.6.zip
unzip confluentinc-kafka-connect-datagen-0.6.6.zip
rm -rf __MACOSX



cd ..

cat <<EOF > Dockerfile
FROM quay.io/strimzi/kafka:0.40.0-kafka-3.7.0
USER root:root
COPY plugins /opt/kafka/plugins
USER 1001
EOF

docker build -t hieupham0607/debezium-connect:iceberg --platform linux/amd64 .

docker push hieupham0607/debezium-connect:iceberg

