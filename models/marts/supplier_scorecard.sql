-- Monthly scorecard per supplier: the single source of truth for supplier OTIF.
select
    f.supplier_id,
    s.supplier_name,
    s.category,
    s.onboarding_program,
    f.delivery_month,
    count(*)                                                     as deliveries,
    avg(case when f.is_on_time then 1 else 0 end)                as on_time_rate,
    avg(case when f.is_in_full then 1 else 0 end)                as in_full_rate,
    avg(case when f.is_otif then 1 else 0 end)                   as otif_rate,
    avg(f.lead_time_days)                                        as avg_lead_time_days,
    sum(f.quantity_rejected) * 1.0
        / nullif(sum(f.quantity_delivered), 0)                   as defect_rate,
    sum(f.order_value)                                           as spend
from {{ ref('fct_deliveries') }} f
join {{ ref('dim_suppliers') }} s using (supplier_id)
group by all
