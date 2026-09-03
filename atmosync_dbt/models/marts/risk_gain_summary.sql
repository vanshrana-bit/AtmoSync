{{ config(
    materialized='table'
) }}

SELECT
    risk_level,

    COUNT(*) AS total_events,

    ROUND(
        SUM(potential_gain_per_kg),
        2
    ) AS total_potential_gain_per_kg,

    ROUND(
        AVG(potential_gain_per_kg),
        2
    ) AS avg_potential_gain_per_kg

FROM {{ ref('spoilage_arbitrage') }}

GROUP BY risk_level

ORDER BY
    total_potential_gain_per_kg DESC