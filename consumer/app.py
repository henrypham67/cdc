from confluent_kafka import Consumer, KafkaException, KafkaError
import os

# Kafka configuration from environment variables
KAFKA_BROKERS = os.getenv("KAFKA_BROKERS", "localhost:9092")  # Default to localhost:9092
KAFKA_TOPIC = os.getenv("KAFKA_TOPIC", "test_topic")          # Default topic name
KAFKA_GROUP = os.getenv("KAFKA_GROUP", "test_group")          # Default consumer group

def create_consumer():
    """
    Create and configure a Kafka consumer.
    """
    consumer_config = {
        "bootstrap.servers": KAFKA_BROKERS,
        "group.id": KAFKA_GROUP,
        "auto.offset.reset": "earliest",  # Start reading from the beginning if no offset is stored
        "enable.auto.commit": False      # Disable auto-commit for more control over processing
    }
    return Consumer(consumer_config)

def consume_messages():
    """
    Consume messages from the specified Kafka topic.
    """
    consumer = create_consumer()
    try:
        # Subscribe to the topic
        consumer.subscribe([KAFKA_TOPIC])

        print(f"Subscribed to Kafka topic: {KAFKA_TOPIC}")

        while True:
            # Poll for new messages
            message = consumer.poll(timeout=1.0)  # Timeout in seconds
            if message is None:
                continue  # No new messages

            if message.error():
                if message.error().code() == KafkaError._PARTITION_EOF:
                    # End of partition event
                    print(f"End of partition reached {message.topic()} [{message.partition()}] at offset {message.offset()}")
                elif message.error():
                    raise KafkaException(message.error())
            else:
                # Successfully received a message
                print(f"Received message: {message.value().decode('utf-8')} (key: {message.key()})")
                # Commit the message's offset manually
                consumer.commit(asynchronous=False)

    except KeyboardInterrupt:
        print("Consumer interrupted by user.")
    except KafkaException as e:
        print(f"Kafka error: {e}")
    finally:
        # Close the consumer to release resources
        consumer.close()
        print("Consumer closed.")

if __name__ == "__main__":
    consume_messages()
