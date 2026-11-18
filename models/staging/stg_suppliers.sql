select
    supplier_id,
    upper(left(trim(supplier_name), 1)) || substr(trim(supplier_name), 2) as supplier_name,
    category,
    region,
    {{ parse_date('onboarded_at') }}      as onboarded_at,
    onboarding_program,
    status
from {{ ref('raw_suppliers') }}
