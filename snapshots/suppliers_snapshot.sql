{% snapshot suppliers_snapshot %}
{{ config(
    target_schema='snapshots',
    unique_key='supplier_id',
    strategy='check',
    check_cols=['status', 'category', 'onboarding_program']
) }}
-- SCD type 2: keeps the history of supplier status changes over time.
select * from {{ ref('stg_suppliers') }}
{% endsnapshot %}
