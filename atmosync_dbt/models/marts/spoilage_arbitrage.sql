{{ config(
    materialized='table'
) }}

WITH market_data AS (

    SELECT
        *
    FROM {{ ref('container_market_opportunities') }}

),

health_data AS (

    SELECT
        container_id,
        event_id,
        alert_status,
        temperature_status,
        humidity_status,
        vibration_status
    FROM {{ ref('fct_container_telemetry') }}

)

SELECT
    m.event_id,
    m.container_id,
    m.event_timestamp,
    m.commodity,
    m.origin,
    m.destination,

    m.origin_price,
    m.destination_price,
    m.price_difference_per_kg,

    m.temperature,
    m.humidity,
    m.vibration,

    h.temperature_status,
    h.humidity_status,
    h.vibration_status,
    h.alert_status,

    CASE
        WHEN h.alert_status = 'ALERT'
             AND m.price_difference_per_kg > 0
            THEN 'HIGH_RISK_OPPORTUNITY'

        WHEN h.alert_status = 'NORMAL'
             AND m.price_difference_per_kg > 0
            THEN 'SAFE_OPPORTUNITY'

        ELSE 'NO_OPPORTUNITY'
    END AS arbitrage_status,

    CASE
        WHEN h.alert_status = 'ALERT'
            THEN 'AT_RISK'
        ELSE 'HEALTHY'
    END AS spoilage_risk_status

FROM market_data m

LEFT JOIN health_data h
    ON m.event_id = h.event_id