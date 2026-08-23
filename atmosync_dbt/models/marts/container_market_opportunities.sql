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
        vibration,
        latitude,
        longitude,
        ingested_at
    FROM {{ ref('fct_container_telemetry') }}

),

origin_prices AS (

    SELECT
        commodity,
        market,
        price_per_kg AS origin_price
    FROM {{ ref('stg_commodity_prices') }}

),

destination_prices AS (

    SELECT
        commodity,
        market,
        price_per_kg AS destination_price
    FROM {{ ref('stg_commodity_prices') }}

)

SELECT
    t.event_id,
    t.container_id,
    t.event_timestamp,
    t.commodity,
    t.origin,
    t.destination,

    op.origin_price,
    dp.destination_price,

    ROUND(
        dp.destination_price - op.origin_price,
        2
    ) AS price_difference_per_kg,

    CASE
        WHEN dp.destination_price > op.origin_price
        THEN 'OPPORTUNITY'
        ELSE 'NO_OPPORTUNITY'
    END AS market_opportunity,

    t.temperature,
    t.humidity,
    t.vibration,
    t.latitude,
    t.longitude,
    t.ingested_at

FROM telemetry t

LEFT JOIN origin_prices op
    ON t.commodity = op.commodity
    AND t.origin = op.market

LEFT JOIN destination_prices dp
    ON t.commodity = dp.commodity
    AND t.destination = dp.market