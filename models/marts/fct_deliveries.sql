select
    delivery_id,
    po_id,
    supplier_id,
    date_trunc('month', delivered_at)::date            as delivery_month,
    promised_date,
    delivered_at,
    quantity_ordered,
    quantity_delivered,
    quantity_rejected,
    order_value,
    lead_time_days,
    greatest(days_late, 0)                             as days_late,
    is_on_time,
    is_in_full,
    is_on_time and is_in_full                          as is_otif,
    has_missing_quantity
from {{ ref('int_deliveries_enriched') }}
