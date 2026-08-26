{{ config(
    materialized='table'
) }}

WITH opportunities AS (

    SELECT
        event_id,
        container_id,
        event_timestamp,
        commodity,
        origin,
        destination,
        origin_price,
        destination_price,
        price_difference_per_kg,
        temperature,
        humidity,
        vibration,
        risk_score,
        risk_level,
        potential_gain_per_kg,
        estimated_loss_per_kg,
        arbitrage_status,
        spoilage_risk_status,
        recommended_action
    FROM {{ ref('spoilage_arbitrage') }}

),

market_prices AS (

    SELECT
        commodity,
        market,
        price_per_kg
    FROM {{ ref('stg_commodity_prices') }}

),

ranked_markets AS (

    SELECT
        o.event_id,
        o.container_id,
        o.commodity,
        o.origin,
        o.destination,

        mp.market AS alternative_market,
        mp.price_per_kg AS alternative_price,

        o.destination_price AS current_destination_price,

        mp.price_per_kg - o.destination_price
            AS additional_gain_vs_current_destination,

        ROW_NUMBER() OVER (
            PARTITION BY o.event_id
            ORDER BY mp.price_per_kg DESC
        ) AS market_rank

    FROM opportunities o

    INNER JOIN market_prices mp
        ON o.commodity = mp.commodity

    WHERE mp.market NOT IN (
        o.origin,
        o.destination
    )

)

SELECT
    o.event_id,
    o.container_id,
    o.event_timestamp,
    o.commodity,
    o.origin,
    o.destination,

    o.origin_price,
    o.destination_price,

    r.alternative_market AS recommended_destination,
    r.alternative_price AS recommended_market_price,

    o.price_difference_per_kg,

    ROUND(
        r.additional_gain_vs_current_destination,
        2
    ) AS additional_gain_vs_current_destination,

    o.temperature,
    o.humidity,
    o.vibration,

    o.risk_score,
    o.risk_level,
    o.arbitrage_status,
    o.spoilage_risk_status,

    CASE
        WHEN o.risk_level = 'HIGH'
             AND r.additional_gain_vs_current_destination > 0
            THEN 'REROUTE_TO_BEST_MARKET'

        WHEN o.arbitrage_status = 'HIGH_RISK_OPPORTUNITY'
             AND r.additional_gain_vs_current_destination > 0
            THEN 'REROUTE_TO_BEST_MARKET'

        WHEN o.arbitrage_status = 'SAFE_OPPORTUNITY'
             AND r.additional_gain_vs_current_destination > 0
            THEN 'CONSIDER_REROUTE'

        ELSE 'KEEP_CURRENT_DESTINATION'
    END AS reroute_recommendation

FROM opportunities o

LEFT JOIN ranked_markets r
    ON o.event_id = r.event_id
    AND r.market_rank = 1