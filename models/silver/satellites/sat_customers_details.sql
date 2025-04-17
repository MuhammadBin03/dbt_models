-- Satellite model for customer details
-- Standardized implementation using Data Vault macros

{{ datavault.create_satellite_model(
    source_model='stg_customers',
    sat_name='sat_customers_details',
    src_pk='hub_key',
    src_hashdiff=['CUSTOMERNAME', 'CUSTOMERTYPE', 'EMAIL', 'ADDRESS'],
    src_payload=['CUSTOMERNAME as CustomerName', 'CUSTOMERTYPE as CustomerType', 'EMAIL as ContactInformation', 'ADDRESS as Address'],
    src_ldts="current_timestamp()",
    src_source="'CUSTOMERS'"
) }}
