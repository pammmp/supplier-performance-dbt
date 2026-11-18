-- A delivery cannot happen before its purchase order. Returns the rows that fail.
select *
from {{ ref('int_deliveries_enriched') }}
where delivered_at < ordered_at
