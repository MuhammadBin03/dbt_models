-- Data Vault macros package initialization
-- This file makes the macros accessible as a package

{% macro create_hub_model() %}
    {{ return(datavault.create_hub_model(*varargs, **kwargs)) }}
{% endmacro %}

{% macro create_link_model() %}
    {{ return(datavault.create_link_model(*varargs, **kwargs)) }}
{% endmacro %}

{% macro create_satellite_model() %}
    {{ return(datavault.create_satellite_model(*varargs, **kwargs)) }}
{% endmacro %}

{% macro hash_key() %}
    {{ return(datavault.hash_key(*varargs, **kwargs)) }}
{% endmacro %}

{% macro hash_diff() %}
    {{ return(datavault.hash_diff(*varargs, **kwargs)) }}
{% endmacro %}
