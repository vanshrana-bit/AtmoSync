import json
import random
import time
import uuid
from datetime import datetime, timezone

from kafka import KafkaProducer


KAFKA_BOOTSTRAP_SERVERS = "localhost:9092"
KAFKA_TOPIC = "container-telemetry"

CONTAINERS = [
    {
        "container_id": "C001",
        "commodity": "Avocado",
        "origin": "Delhi",
        "destination": "Jaipur",
        "latitude": 28.6139,
        "longitude": 77.2090,
        "base_temperature": 7.0,
        "base_humidity": 70.0,
    },
    {
        "container_id": "C002",
        "commodity": "Banana",
        "origin": "Agra",
        "destination": "Delhi",
        "latitude": 27.1767,
        "longitude": 78.0081,
        "base_temperature": 13.0,
        "base_humidity": 78.0,
    },
    {
        "container_id": "C003",
        "commodity": "Mango",
        "origin": "Lucknow",
        "destination": "Noida",
        "latitude": 26.8467,
        "longitude": 80.9462,
        "base_temperature": 12.0,
        "base_humidity": 75.0,
    },
    {
        "container_id": "C004",
        "commodity": "Apple",
        "origin": "Delhi",
        "destination": "Agra",
        "latitude": 28.6139,
        "longitude": 77.2090,
        "base_temperature": 4.0,
        "base_humidity": 65.0,
    },
]


def create_producer():
    return KafkaProducer(
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
        value_serializer=lambda value: json.dumps(value).encode("utf-8"),
    )


def generate_event(container):
    temperature = round(
        container["base_temperature"] + random.uniform(-2.0, 5.0),
        2,
    )

    humidity = round(
        container["base_humidity"] + random.uniform(-8.0, 10.0),
        2,
    )

    vibration = round(random.uniform(0.05, 0.50), 3)

    # Occasionally generate abnormal conditions
    if random.random() < 0.10:
        temperature = round(temperature + random.uniform(5.0, 10.0), 2)
        humidity = round(humidity + random.uniform(5.0, 12.0), 2)
        vibration = round(vibration + random.uniform(0.20, 0.50), 3)

    return {
        "event_id": f"EVT-{uuid.uuid4().hex[:10].upper()}",
        "container_id": container["container_id"],
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "commodity": container["commodity"],
        "origin": container["origin"],
        "destination": container["destination"],
        "temperature": temperature,
        "humidity": humidity,
        "vibration": vibration,
        "latitude": container["latitude"],
        "longitude": container["longitude"],
    }


def main():
    print("Starting AtmoSync IoT Simulator...")
    print(f"Kafka: {KAFKA_BOOTSTRAP_SERVERS}")
    print(f"Topic: {KAFKA_TOPIC}")
    print("Press Ctrl+C to stop.\n")

    producer = create_producer()

    try:
        while True:
            for container in CONTAINERS:
                event = generate_event(container)

                producer.send(KAFKA_TOPIC, value=event)
                producer.flush()

                print(json.dumps(event))

                time.sleep(2)

    except KeyboardInterrupt:
        print("\nStopping AtmoSync IoT Simulator...")

    finally:
        producer.close()


if __name__ == "__main__":
    main()