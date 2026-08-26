{{ config(
    materialized='table'
) }}

WITH telemetry AS (

    SELECT
        event_id,
        container_id,
        event_timestamp,
        commodity,
        origin,
        destination,
        temperature,
        humidity,
        vibration
    FROM {{ ref('fct_container_telemetry') }}

),

risk_calculation AS (

    SELECT
        *,

        CASE commodity
            WHEN 'Avocado' THEN 5
            WHEN 'Banana' THEN 4
            WHEN 'Mango' THEN 6
            WHEN 'Apple' THEN 8
            ELSE 7
        END AS base_shelf_life_hours,

        CASE commodity
            WHEN 'Avocado' THEN 5
            WHEN 'Banana' THEN 8
            WHEN 'Mango' THEN 10
            WHEN 'Apple' THEN 12
            ELSE 8
        END AS ideal_temperature_max,

        CASE
            WHEN temperature <=
                CASE commodity
                    WHEN 'Avocado' THEN 5
                    WHEN 'Banana' THEN 8
                    WHEN 'Mango' THEN 10
                    WHEN 'Apple' THEN 12
                    ELSE 8
                END
            THEN 0

            WHEN temperature <=
                CASE commodity
                    WHEN 'Avocado' THEN 5
                    WHEN 'Banana' THEN 8
                    WHEN 'Mango' THEN 10
                    WHEN 'Apple' THEN 12
                    ELSE 8
                END + 5
            THEN 1

            ELSE 2
        END AS temperature_penalty,

        CASE
            WHEN humidity <= 80 THEN 0
            WHEN humidity <= 90 THEN 1
            ELSE 2
        END AS humidity_penalty,

        CASE
            WHEN vibration <= 0.40 THEN 0
            WHEN vibration <= 0.70 THEN 1
            ELSE 2
        END AS vibration_penalty

    FROM telemetry

)

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

    base_shelf_life_hours,

    temperature_penalty,
    humidity_penalty,
    vibration_penalty,

    (
        temperature_penalty
        + humidity_penalty
        + vibration_penalty
    ) AS spoilage_penalty,

    GREATEST(
        base_shelf_life_hours
        -
        (
            temperature_penalty * 1.5
            + humidity_penalty * 1.0
            + vibration_penalty * 1.5
        ),
        0.5
    ) AS estimated_remaining_hours,

    CASE
        WHEN (
            temperature_penalty
            + humidity_penalty
            + vibration_penalty
        ) >= 4
            THEN 'CRITICAL'

        WHEN (
            temperature_penalty
            + humidity_penalty
            + vibration_penalty
        ) >= 2
            THEN 'HIGH'

        WHEN (
            temperature_penalty
            + humidity_penalty
            + vibration_penalty
        ) >= 1
            THEN 'MEDIUM'

        ELSE 'LOW'
    END AS spoilage_severity

FROM risk_calculation