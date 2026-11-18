-- Data-quality guardrail: fail if more than 2% of deliveries have no quantity.
select share_missing
from (
    select avg(case when has_missing_quantity then 1 else 0 end) as share_missing
    from {{ ref('fct_deliveries') }}
)
where share_missing > 0.02
