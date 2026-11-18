-- Question: did the new onboarding program improve first-90-day OTIF?
-- Compile with `dbt compile` and run the SQL in DuckDB (or paste the result into a notebook).
with first_90_days as (
    select
        s.onboarding_program,
        f.supplier_id,
        f.is_otif
    from {{ ref('fct_deliveries') }} f
    join {{ ref('dim_suppliers') }} s using (supplier_id)
    where f.delivered_at < s.onboarded_at + interval 90 day
      and f.delivered_at >= s.onboarded_at
),

by_group as (
    select
        onboarding_program,
        count(*)                                        as n,
        avg(case when is_otif then 1 else 0 end)        as otif_rate
    from first_90_days
    group by 1
)

-- two-proportion z-test
select
    n.otif_rate                                         as otif_new,
    l.otif_rate                                         as otif_legacy,
    n.otif_rate - l.otif_rate                           as lift,
    (n.otif_rate - l.otif_rate) / sqrt(
        p.pooled * (1 - p.pooled) * (1.0 / n.n + 1.0 / l.n)
    )                                                   as z_score
from by_group n
cross join by_group l
cross join (
    select sum(otif_rate * n) / sum(n) as pooled from by_group
) p
where n.onboarding_program = 'new'
  and l.onboarding_program = 'legacy'
-- |z| > 1.96  ->  difference is significant at 95%.
-- Caveat: this is observational (suppliers were not randomized), so treat it as a signal, not proof.
