-- Macro for generating hash keys
{% macro hash_key(columns, alias=none) %}
    {% if alias %}
        md5(concat_ws('||', {{ columns|join(', ') }})) as {{ alias }}
    {% else %}
        md5(concat_ws('||', {{ columns|join(', ') }}))
    {% endif %}
{% endmacro %}

-- Macro for generating hash diffs for satellites
{% macro hash_diff(columns) %}
    md5(concat_ws('||', {{ columns|join(', ') }}))
{% endmacro %}
