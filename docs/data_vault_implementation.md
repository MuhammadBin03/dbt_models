# Data Vault Implementation Guide

## Overview

This document outlines the standardized approach to implementing Data Vault 2.0 in our dbt project. Data Vault is a database modeling methodology designed for enterprise data warehousing that provides historical storage of data from multiple operational systems.

## Key Components

### 1. Hubs

Hubs store business keys and their source. They represent core business entities.

**Naming Convention**: `hub_<entity_name>`

**Structure**:
- `hub_key`: Hash of the business key
- `business_key`: The natural key from the source system
- `load_date`: Timestamp when the record was loaded
- `record_source`: Source system of the record

### 2. Links

Links represent relationships between business entities.

**Naming Convention**: `link_<entity1>_<entity2>_[<entity3>]`

**Structure**:
- `link_key`: Hash of the foreign keys
- `<entity1>_key`: Foreign key to the first hub
- `<entity2>_key`: Foreign key to the second hub
- `[<entity3>_key]`: Optional foreign key to additional hubs
- `load_date`: Timestamp when the record was loaded
- `record_source`: Source system of the record

### 3. Satellites

Satellites store descriptive attributes related to hubs or links.

**Naming Convention**: `sat_<entity_name>_<descriptor>`

**Structure**:
- `sat_key`: Foreign key to the hub or link
- `hashdiff`: Hash of all payload attributes
- `<payload_attributes>`: Descriptive attributes
- `load_date`: Timestamp when the record was loaded
- `record_source`: Source system of the record

## Implementation with Macros

We've created standardized macros to ensure consistent implementation across the project:

### Hub Macro

```sql
{{ datavault.create_hub_model(
    source_model='stg_customers',
    hub_name='hub_customers',
    src_pk='CUSTOMERID',
    src_nk='CUSTOMERID',
    src_ldts="current_timestamp()",
    src_source="'CUSTOMERS'"
) }}
```

### Link Macro

```sql
{{ datavault.create_link_model(
    source_model='stg_sales_orders',
    link_name='link_customers_users',
    src_pk='SALESORDERID',
    src_fk=['customer_hashkey', 'user_hashkey'],
    src_ldts="current_timestamp()",
    src_source="'SALES_ORDERS'"
) }}
```

### Satellite Macro

```sql
{{ datavault.create_satellite_model(
    source_model='stg_customers',
    sat_name='sat_customers_details',
    src_pk='customer_hashkey',
    src_hashdiff=['CUSTOMERNAME', 'CUSTOMERTYPE', 'EMAIL', 'ADDRESS'],
    src_payload=['CUSTOMERNAME', 'CUSTOMERTYPE', 'EMAIL', 'ADDRESS'],
    src_ldts="current_timestamp()",
    src_source="'CUSTOMERS'"
) }}
```

## Best Practices

1. **Consistent Naming**: Follow the naming conventions for all Data Vault objects.
2. **Use Macros**: Always use the provided macros for creating Data Vault objects.
3. **Documentation**: Document all models in schema.yml files.
4. **Testing**: Add appropriate tests for data quality.
5. **Incremental Loading**: Use incremental loading for efficiency.
6. **Hash Keys**: Use consistent hashing for keys and diffs.
7. **Source Tracking**: Always include record source information.
8. **Load Dates**: Include load dates for all records.

## Data Flow

The typical data flow in our Data Vault implementation is:

1. **Source Systems** → Raw data loaded into the data warehouse
2. **Staging Layer** → Basic transformations and data quality checks
3. **Data Vault Layer** → Structured according to Data Vault methodology
4. **Business Vault** → Business rules applied to Data Vault structures
5. **Information Marts** → Dimensional models for reporting and analytics

## Migration Strategy

When migrating existing models to the standardized Data Vault implementation:

1. Create a new model using the appropriate macro
2. Test the new model against the existing one
3. Replace the existing model with the new one
4. Update any dependencies

## References

- [Data Vault 2.0 Methodology](https://www.data-vault.co.uk/)
- [dbt Documentation](https://docs.getdbt.com/)
- [Data Vault Alliance](https://datavaultalliance.com/)
