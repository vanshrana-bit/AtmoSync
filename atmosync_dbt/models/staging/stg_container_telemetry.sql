{{ config(
    materialized='view'
) }}

select
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
from {{ source('raw', 'container_telemetry') }}