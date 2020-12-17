
with base as (

    select * 
    from {{ ref('stg_netsuite__transactions_tmp') }}

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_salesforce_source/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_salesforce_source/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */

        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_netsuite__transactions_tmp')),
                staging_columns=get_transactions_columns()
            )
        }}

        --The below script allows for pass through columns.
        {% if var('transactions_pass_through_columns') %}
        ,
        {{ var('transactions_pass_through_columns') | join (", ")}}

        {% endif %}
        
    from base
),

final as (
    
    select 
        transaction_id,
        status,
        trandate as transaction_date,
        currency_id,
        accounting_period_id,
        due_date,
        transaction_type,
        is_intercompany,
        is_advanced_intercompany,
        _fivetran_deleted

        --The below script allows for pass through columns.
        {% if var('transactions_pass_through_columns') %}
        ,
        {{ var('transactions_pass_through_columns') | join (", ")}}

        {% endif %}

    from fields
)

select * 
from final
