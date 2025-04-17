{% macro create_hub_model(source_model, hub_name, src_pk, src_nk, src_ldts, src_source) %}

{{ config(
    materialized='incremental',
    unique_key='hub_key',
    tags=['hub']
) }}

{%- set source_model = source_model -%}
{%- set src_pk = src_pk -%}
{%- set src_nk = src_nk -%}
{%- set src_ldts = src_ldts -%}
{%- set src_source = src_source -%}

with source_data as (
    select
        {{ src_nk }} as business_key,
        {{ src_ldts }} as load_date,
        {{ src_source }} as record_source
    from {{ ref(source_model) }}
    where {{ src_nk }} is not null
      and trim({{ src_nk }}) != ''
),

deduplicated as (
    select
        {{ hash_key(['business_key']) }} as hub_key,
        business_key,
        load_date,
        record_source
    from source_data
)

select distinct
    hub_key,
    business_key,
    load_date,
    record_source
from deduplicated

{% if is_incremental() %}
    where hub_key not in (select hub_key from {{ this }})
{% endif %}

{% endmacro %}
