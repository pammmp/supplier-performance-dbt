select
    po_id,
    supplier_id,
    {{ parse_date('ordered_at') }}        as ordered_at,
    {{ parse_date('promised_date') }}     as promised_date,
    cast(quantity_ordered as integer)     as quantity_ordered,
    cast(unit_price as decimal(12, 2))    as unit_price
from {{ ref('raw_purchase_orders') }}
