select
    s.supplier_id,
    s.supplier_name,
    s.category,
    s.region,
    s.onboarded_at,
    s.onboarding_program,
    s.status
from {{ ref('stg_suppliers') }} s
