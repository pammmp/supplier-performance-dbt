with source as (
    select * from {{ ref('raw_deliveries') }}
),

deduplicated as (
    -- the source sends some deliveries twice; keep one row per delivery_id
    select *,
        row_number() over (partition by delivery_id order by delivered_at) as rn
    from source
)

select
    delivery_id,
    po_id,
    {{ parse_date('delivered_at') }}               as delivered_at,
    try_cast(quantity_delivered as integer)        as quantity_delivered
from deduplicated
where rn = 1
