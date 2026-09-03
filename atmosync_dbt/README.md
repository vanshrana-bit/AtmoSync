@"
# AtmoSync
### Real-Time Micro-Climate Arbitrage Analytics for Smart Shipping Containers

AtmoSync is a real-time analytics platform that monitors IoT-enabled shipping containers and combines environmental telemetry with commodity-market information to identify spoilage risk, arbitrage opportunities, and recommended rerouting actions.

## Objective

AtmoSync analyzes:

- Temperature
- Humidity
- Vibration
- Container location
- Commodity
- Origin and destination
- Market pricing

The pipeline transforms raw telemetry into actionable insights for container health, spoilage prevention, and destination optimization.

## Architecture

Python IoT Simulator
        |
        v
Apache Kafka
        |
        v
Snowflake
        |
        v
dbt
        |
        v
Spoilage & Arbitrage Analytics
        |
        v
Apache Superset
        |
        v
AtmoSync Control Tower Dashboard

## Technology Stack

| Layer | Technology |
|---|---|
| Simulation | Python |
| Streaming | Apache Kafka |
| Data Warehouse | Snowflake |
| Transformation | dbt Core |
| BI / Dashboard | Apache Superset |
| Containers | Docker |
| Version Control | Git & GitHub |

## Main Components

### 1. IoT Simulator
Generates container telemetry including environmental and location data.

### 2. Kafka Streaming
Streams telemetry events through the `container-telemetry` topic.

### 3. Snowflake
Stores raw telemetry and analytical datasets.

### 4. dbt
Cleans, transforms, and models warehouse data for downstream analytics.

### 5. Spoilage & Arbitrage Analytics
Identifies:

- Spoilage risk
- Risk levels
- Arbitrage opportunities
- Potential gains
- Estimated losses
- Recommended reroutes

### 6. Superset Dashboard
The AtmoSync Control Tower provides:

- KPI monitoring
- Spoilage risk analysis
- Arbitrage analysis
- Temperature, humidity, and vibration trends
- Reroute recommendations
- Commodity, risk, container, and destination filters
- 60-second auto refresh

## Dashboard

The dashboard includes:

- Total Containers
- At Risk Containers
- Total Events
- Critical Spoilage
- Safe Arbitrage
- High Risk Arbitrage
- Potential Gain
- Estimated Loss
- Immediate Reroutes
- Consider Reroute
- Average Shelf Life
- Spoilage Risk Distribution
- Arbitrage Opportunities by Commodity
- Potential Gain by Risk Level
- Average Temperature
- Average Humidity
- Average Vibration
- Reroute Recommendations

## Project Structure

```text
AtmoSync/
|-- atmosync_dbt/
|-- data/
|-- scripts/
|-- simulator/
|-- docker-compose.yml
|-- .env.example
|-- .gitignore
`-- README.md