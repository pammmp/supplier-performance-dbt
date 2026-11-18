{# Accepts YYYY-MM-DD or DD/MM/YYYY and returns a DATE. Unparseable values become NULL. #}
{% macro parse_date(column) %}
    coalesce(
        try_strptime(cast({{ column }} as varchar), '%Y-%m-%d'),
        try_strptime(cast({{ column }} as varchar), '%d/%m/%Y')
    )::date
{% endmacro %}
