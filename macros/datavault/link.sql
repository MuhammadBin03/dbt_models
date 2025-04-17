{% macro create_link_model(source_model, link_name, src_pk, src_fk, src_ldts, src_source, source_model_query=none) %}

{{ config(
    materialized='incremental',
    unique_key='link_key',
    tags=['link']
) }}

{%- set source_model = source_model -%}
{%- set src_pk = src_pk -%}
{%- set src_fk = src_fk -%}
{%- set src_ldts = src_ldts -%}
{%- set src_source = src_source -%}

{%- set source_cols = ['link_key'] -%}
{%- set source_cols = source_cols + src_fk -%}
{%- set source_cols = source_cols + [src_ldts, src_source] -%}

with source_data as (
    {% if source_model_query %}
        {{ source_model_query }}
    {% else %}
        select
            {{ hash_key(src_fk, 'link_key') }},
            {% for src_fk_item in src_fk %}
                {{ src_fk_item }},
            {% endfor %}
            {{ src_ldts }} as load_date,
            {{ src_source }} as record_source
        from {{ ref(source_model) }}
        where {{ src_fk[0] }} is not null
        {% for src_fk_item in src_fk[1:] %}
            and {{ src_fk_item }} is not null
        {% endfor %}
    {% endif %}
)

select distinct
    link_key,
    {% for src_fk_item in src_fk %}
        {{ src_fk_item }},
    {% endfor %}
    load_date,
    record_source
from source_data

{% if is_incremental() %}
    where link_key not in (select link_key from {{ this }})
{% endif %}

{% endmacro %}
