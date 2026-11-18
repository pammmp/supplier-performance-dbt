-- One row per delivery, joined to its order and inspection.
-- This is the ONLY place where on-time and in-full are defined.
select
    d.delivery_id,
    o.po_id,
    o.supplier_id,
    o.ordered_at,
    o.promised_date,
    d.delivered_at,
    o.quantity_ordered,
    d.quantity_delivered,
    coalesce(i.quantity_rejected, 0)                          as quantity_rejected,
    o.quantity_ordered * o.unit_price                         as order_value,
    date_diff('day', o.ordered_at, d.delivered_at)            as lead_time_days,
    date_diff('day', o.promised_date, d.delivered_at)         as days_late,
    d.delivered_at <= o.promised_date                         as is_on_time,
    d.quantity_delivered is not null
        and d.quantity_delivered >= o.quantity_ordered        as is_in_full,
    d.quantity_delivered is null                              as has_missing_quantity
from {{ ref('stg_deliveries') }} d
join {{ ref('stg_purchase_orders') }} o using (po_id)
left join {{ ref('stg_inspections') }} i using (delivery_id)
