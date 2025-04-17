{% macro create_satellite_model(source_model, sat_name, src_pk, src_hashdiff, src_payload, src_ldts, src_source, source_model_query=none) %}

{{ config(
    materialized='incremental',
    unique_key=['sat_key', 'load_date'],
    tags=['satellite']
) }}

{%- set source_model = source_model -%}
{%- set src_pk = src_pk -%}
{%- set src_hashdiff = src_hashdiff -%}
{%- set src_payload = src_payload -%}
{%- set src_ldts = src_ldts -%}
{%- set src_source = src_source -%}

{%- set source_cols = [src_pk, 'hashdiff'] -%}
{%- set source_cols = source_cols + src_payload -%}
{%- set source_cols = source_cols + [src_ldts, src_source] -%}

with source_data as (
    {% if source_model_query %}
        {{ source_model_query }}
    {% else %}
        select
            {{ src_pk }} as sat_key,
            {{ hash_diff(src_hashdiff) }} as hashdiff,
            {% for payload_column in src_payload %}
                {{ payload_column }},
            {% endfor %}
            {{ src_ldts }} as load_date,
            {{ src_source }} as record_source
        from {{ ref(source_model) }}
        where {{ src_pk }} is not null
    {% endif %}
),

latest_records as (
    select
        sat_key,
        hashdiff,
        load_date,
        record_source,
        {% for payload_column in src_payload %}
            {{ payload_column }},
        {% endfor %}
        row_number() over (
            partition by sat_key
            order by load_date desc
        ) as row_num
    from source_data
)

select
    sat_key,
    hashdiff,
    {% for payload_column in src_payload %}
        {{ payload_column }},
    {% endfor %}
    load_date,
    record_source
from latest_records
where row_num = 1

{% if is_incremental() %}
    and (
        sat_key not in (select sat_key from {{ this }})
        or hashdiff not in (
            select hashdiff 
            from {{ this }}
            where sat_key = latest_records.sat_key
        )
    )
{% endif %}

{% endmacro %}
