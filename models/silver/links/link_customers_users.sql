-- Link model for customer-user relationships
-- Standardized implementation using Data Vault macros

{% set source_model_query %}
SELECT
    {{ hash_key(['so.salesorderid']) }} as link_key,
    hc.hub_key as customer_hashkey,
    hu.hub_key as user_hashkey,
    CURRENT_TIMESTAMP() AS load_date,
    'SALES_ORDERS' AS record_source
FROM {{ ref('stg_sales_orders') }} so
INNER JOIN {{ ref('hub_customers') }} hc ON so.customerid = hc.business_key
INNER JOIN {{ ref('hub_users') }} hu ON so.salespersonid = hu.business_key
WHERE so.salesorderid IS NOT NULL
{% endset %}

{{ datavault.create_link_model(
    source_model=none,
    link_name='link_customers_users',
    src_pk='salesorderid',
    src_fk=['customer_hashkey', 'user_hashkey'],
    src_ldts="current_timestamp()",
    src_source="'SALES_ORDERS'",
    source_model_query=source_model_query
) }}
