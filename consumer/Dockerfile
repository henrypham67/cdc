# Use a lightweight Python image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy application files
COPY app.py .
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Environment variables (can be overridden in Kubernetes)
ENV KAFKA_BROKERS=localhost:9092
ENV KAFKA_TOPIC=test_topic
ENV KAFKA_GROUP=test_group

# Start the consumer app
CMD ["python", "app.py"]
