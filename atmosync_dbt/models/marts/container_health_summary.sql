{{ config(
    materialized='table'
) }}

WITH container_metrics AS (

    SELECT
        container_id,
        commodity,
        origin,
        destination,

        COUNT(*) AS total_events,

        ROUND(AVG(temperature), 2) AS avg_temperature,
        ROUND(MIN(temperature), 2) AS min_temperature,
        ROUND(MAX(temperature), 2) AS max_temperature,

        ROUND(AVG(humidity), 2) AS avg_humidity,

        ROUND(AVG(vibration), 3) AS avg_vibration,
        ROUND(MAX(vibration), 3) AS max_vibration,

        SUM(
            CASE
                WHEN alert_status = 'ALERT' THEN 1
                ELSE 0
            END
        ) AS alert_count,

        MAX(event_timestamp) AS last_event_timestamp

    FROM {{ ref('fct_container_telemetry') }}

    GROUP BY
        container_id,
        commodity,
        origin,
        destination
)

SELECT
    *,
    
    CASE
        WHEN alert_count > 0 THEN 'AT_RISK'
        ELSE 'HEALTHY'
    END AS container_status

FROM container_metrics