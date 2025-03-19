{{
    config(
        materialized='incremental',
        on_schema_change='fail'
    )
}}


WITH src_reviews AS (
    SELECT
        *
    FROM
        {{ ref('src_reviews') }}
)
SELECT 
{{ dbt_utils.generate_surrogate_key(['listing_id', 'review_date', 'reviewer_name', 'review_text']) }}
    AS review_id,
*
 FROM src_reviews
where review_text is not null
{% if is_incremental() %}
    and review_date > (select max(review_date) from {{ this }}) --here this refers to the current model
{% endif %}