select
    inspection_id,
    delivery_id,
    cast(quantity_rejected as integer)    as quantity_rejected,
    {{ parse_date('inspected_at') }}      as inspected_at
from {{ ref('raw_inspections') }}
