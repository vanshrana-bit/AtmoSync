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

),

scored_data AS (

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
            WHEN h.temperature_status != 'NORMAL' THEN 40
            ELSE 0
        END
        +
        CASE
            WHEN h.humidity_status != 'NORMAL' THEN 25
            ELSE 0
        END
        +
        CASE
            WHEN h.vibration_status = 'HIGH' THEN 35
            WHEN h.vibration_status = 'MEDIUM' THEN 20
            ELSE 0
        END
        AS risk_score

    FROM market_data m

    LEFT JOIN health_data h
        ON m.event_id = h.event_id
)

SELECT
    *,

    CASE
        WHEN risk_score >= 70 THEN 'HIGH'
        WHEN risk_score >= 40 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_level,

    GREATEST(price_difference_per_kg, 0) AS potential_gain_per_kg,

    CASE
        WHEN price_difference_per_kg > 0
         AND risk_score >= 70
            THEN price_difference_per_kg
        ELSE 0
    END AS estimated_loss_per_kg,

    CASE
        WHEN price_difference_per_kg > 0
         AND risk_score >= 70
            THEN 'REROUTE_IMMEDIATELY'

        WHEN price_difference_per_kg > 0
         AND risk_score >= 40
            THEN 'MONITOR_AND_CONSIDER_REROUTE'

        WHEN price_difference_per_kg > 0
            THEN 'PROCEED_TO_DESTINATION'

        ELSE 'NO_ARBITRAGE'
    END AS recommended_action,

    CASE
        WHEN price_difference_per_kg > 0
         AND risk_score >= 70
            THEN 'HIGH_RISK_OPPORTUNITY'

        WHEN price_difference_per_kg > 0
         AND risk_score < 70
            THEN 'SAFE_OPPORTUNITY'

        ELSE 'NO_OPPORTUNITY'
    END AS arbitrage_status,

    CASE
        WHEN risk_score >= 70 THEN 'AT_RISK'
        ELSE 'HEALTHY'
    END AS spoilage_risk_status

FROM scored_data