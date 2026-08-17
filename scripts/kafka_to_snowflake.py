import json
import os

import snowflake.connector
from dotenv import load_dotenv
from kafka import KafkaConsumer


load_dotenv()

KAFKA_TOPIC = "container-telemetry"
KAFKA_BOOTSTRAP_SERVERS = "localhost:9092"


def create_snowflake_connection():
    return snowflake.connector.connect(
        account=os.getenv("SNOWFLAKE_ACCOUNT"),
        user=os.getenv("SNOWFLAKE_USER"),
        password=os.getenv("SNOWFLAKE_PASSWORD"),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
        database=os.getenv("SNOWFLAKE_DATABASE"),
        schema=os.getenv("SNOWFLAKE_SCHEMA"),
    )


def create_consumer():
    return KafkaConsumer(
        KAFKA_TOPIC,
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
        auto_offset_reset="latest",
        enable_auto_commit=True,
        group_id="atmosync-snowflake-consumer",
        value_deserializer=lambda value: json.loads(value.decode("utf-8")),
    )


def insert_event(cursor, event):
    query = """
        INSERT INTO CONTAINER_TELEMETRY (
            EVENT_ID,
            CONTAINER_ID,
            EVENT_TIMESTAMP,
            COMMODITY,
            ORIGIN,
            DESTINATION,
            TEMPERATURE,
            HUMIDITY,
            VIBRATION,
            LATITUDE,
            LONGITUDE
        )
        VALUES (
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
        )
    """

    cursor.execute(
        query,
        (
            event["event_id"],
            event["container_id"],
            event["timestamp"],
            event["commodity"],
            event["origin"],
            event["destination"],
            event["temperature"],
            event["humidity"],
            event["vibration"],
            event["latitude"],
            event["longitude"],
        ),
    )


def main():
    print("Connecting to Snowflake...")

    conn = create_snowflake_connection()
    cursor = conn.cursor()

    print("Snowflake connection successful!")
    print(f"Listening to Kafka topic: {KAFKA_TOPIC}")

    consumer = create_consumer()

    try:
        for message in consumer:
            event = message.value

            insert_event(cursor, event)
            conn.commit()

            print(
                f"Inserted event {event['event_id']} "
                f"| Container: {event['container_id']} "
                f"| Commodity: {event['commodity']}"
            )

    except KeyboardInterrupt:
        print("\nPipeline stopped.")

    finally:
        consumer.close()
        cursor.close()
        conn.close()
        print("Connections closed.")


if __name__ == "__main__":
    main()