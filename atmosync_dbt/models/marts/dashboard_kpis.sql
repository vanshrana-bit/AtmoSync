{{ config(
    materialized='table'
) }}

WITH latest_events AS (

    SELECT
        *
    FROM {{ ref('spoilage_arbitrage') }}

),

reroutes AS (

    SELECT
        event_id,
        reroute_recommendation,
        recommended_destination,
        additional_gain_vs_current_destination
    FROM {{ ref('reroute_recommendation') }}

),

spoilage AS (

    SELECT
        event_id,
        spoilage_severity,
        estimated_remaining_hours
    FROM {{ ref('spoilage_risk_analysis') }}

)

SELECT
    COUNT(DISTINCT e.container_id) AS total_containers,

    COUNT(*) AS total_events,

    COUNT(DISTINCT CASE
        WHEN e.spoilage_risk_status = 'HEALTHY'
        THEN e.container_id
    END) AS healthy_containers,

    COUNT(DISTINCT CASE
        WHEN e.spoilage_risk_status = 'AT_RISK'
        THEN e.container_id
    END) AS at_risk_containers,

    COUNT(CASE
        WHEN s.spoilage_severity = 'CRITICAL'
        THEN 1
    END) AS critical_spoilage_events,

    COUNT(CASE
        WHEN e.arbitrage_status = 'SAFE_OPPORTUNITY'
        THEN 1
    END) AS safe_arbitrage_events,

    COUNT(CASE
        WHEN e.arbitrage_status = 'HIGH_RISK_OPPORTUNITY'
        THEN 1
    END) AS high_risk_arbitrage_events,

    ROUND(
        SUM(
            CASE
                WHEN e.price_difference_per_kg > 0
                THEN e.price_difference_per_kg
                ELSE 0
            END
        ),
        2
    ) AS total_potential_gain_per_kg,

    ROUND(
        SUM(e.estimated_loss_per_kg),
        2
    ) AS total_estimated_loss_per_kg,

    COUNT(CASE
        WHEN r.reroute_recommendation = 'REROUTE_TO_BEST_MARKET'
        THEN 1
    END) AS immediate_reroute_recommendations,

    COUNT(CASE
        WHEN r.reroute_recommendation = 'CONSIDER_REROUTE'
        THEN 1
    END) AS consider_reroute_recommendations,

    ROUND(
        AVG(s.estimated_remaining_hours),
        2
    ) AS avg_remaining_shelf_life_hours

FROM latest_events e

LEFT JOIN reroutes r
    ON e.event_id = r.event_id

LEFT JOIN spoilage s
    ON e.event_id = s.event_id