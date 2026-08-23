{{ config(
    materialized='view'
) }}

SELECT
    commodity,
    market,
    price_per_kg,
    price_date
FROM {{ source('raw', 'commodity_prices') }}