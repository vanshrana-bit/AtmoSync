# AtmoSync

## Micro-Climate Arbitrage Analytics

AtmoSync is a real-time analytics platform designed to monitor IoT-enabled shipping containers and identify potential spoilage risks and market arbitrage opportunities.

## Project Objective

The system processes high-frequency container telemetry such as:

- Temperature
- Humidity
- Vibration
- Container location
- Commodity information

The data is streamed through Apache Kafka, stored in Snowflake, transformed using dbt, and visualized through Apache Superset.

## Architecture

Python IoT Simulator
        ↓
Apache Kafka
        ↓
Snowflake
        ↓
dbt
        ↓
Spoilage Arbitrage Analytics
        ↓
Apache Superset
        ↓
Real-Time Dashboard

## Technology Stack

- Python
- Apache Kafka
- Snowflake
- dbt Core
- Apache Superset
- Docker
- Git & GitHub

## Main Components

### 1. IoT Simulator
Generates realistic container telemetry continuously.

### 2. Kafka
Handles high-frequency IoT event streaming.

### 3. Snowflake
Stores raw and transformed analytical data.

### 4. dbt
Performs data cleaning, transformation, testing, and analytical modeling.

### 5. Spoilage Arbitrage Analytics
Identifies at-risk containers and evaluates potential market rerouting opportunities.

### 6. Superset
Provides interactive dashboards for container health and arbitrage analysis.

## Project Structure

```text
AtmoSync/
├── simulator/
├── kafka/
├── snowflake/
├── dbt/
├── superset/
├── data/
│   └── mock/
├── scripts/
├── docs/
├── .env.example
├── .gitignore
├── docker-compose.yml
└── README.md