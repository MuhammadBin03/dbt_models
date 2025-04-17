# Data Vault Implementation with dbt

This project implements a Data Vault 2.0 architecture using dbt (data build tool).

## Data Vault Structure

The Data Vault model consists of three main components:

1. **Hubs**: Contain business keys and their source
2. **Links**: Represent relationships between business entities
3. **Satellites**: Store descriptive attributes related to hubs or links

## Project Structure

```
models/
├── staging/          # Staging models that clean and prepare source data
├── silver/           # Data Vault models
│   ├── hubs/         # Business entity hubs
│   ├── links/        # Relationship links
│   ├── satellites/   # Descriptive attributes
└── sources/          # Source definitions
macros/
└── datavault/        # Data Vault macros
    ├── hash.sql      # Hashing functions
    ├── hub.sql       # Hub model template
    ├── link.sql      # Link model template
    └── satellite.sql # Satellite model template
```

## Standardized Naming Conventions

- **Hubs**: `hub_<entity_name>`
- **Links**: `link_<entity1>_<entity2>_[<entity3>]`
- **Satellites**: `sat_<entity_name>_<descriptor>`

## Usage

### Creating a Hub

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

### Creating a Link

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

### Creating a Satellite

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

1. Always use the provided macros for consistency
2. Follow the naming conventions
3. Document all models in schema.yml files
4. Add appropriate tests for data quality
5. Use incremental loading for efficiency
