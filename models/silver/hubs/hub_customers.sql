-- Hub model for customers
-- Standardized implementation using Data Vault macros

{{ datavault.create_hub_model(
    source_model='stg_customers',
    hub_name='hub_customers',
    src_pk='CUSTOMERID',
    src_nk='CUSTOMERID',
    src_ldts="current_timestamp()",
    src_source="'CUSTOMERS'"
) }}
