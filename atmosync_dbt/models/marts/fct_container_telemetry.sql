{{ config(
    materialized='table'
) }}

SELECT
    event_id,
    container_id,
    event_timestamp,
    commodity,
    origin,
    destination,

    temperature,
    humidity,
    vibration,

    latitude,
    longitude,

    ingested_at,

    -- Temperature status
    CASE
        WHEN temperature < 5 THEN 'LOW'
        WHEN temperature > 20 THEN 'HIGH'
        ELSE 'NORMAL'
    END AS temperature_status,

    -- Humidity status
    CASE
        WHEN humidity < 40 THEN 'LOW'
        WHEN humidity > 80 THEN 'HIGH'
        ELSE 'NORMAL'
    END AS humidity_status,

    -- Vibration status
    CASE
        WHEN vibration > 0.70 THEN 'HIGH'
        WHEN vibration > 0.40 THEN 'MEDIUM'
        ELSE 'NORMAL'
    END AS vibration_status,

    -- Overall alert
    CASE
        WHEN temperature < 5
          OR temperature > 20
          OR humidity < 40
          OR humidity > 80
          OR vibration > 0.70
        THEN 'ALERT'
        ELSE 'NORMAL'
    END AS alert_status

FROM {{ ref('stg_container_telemetry') }}