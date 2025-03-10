{{ config(
        schema='gmx_v2',
        alias = 'withdrawal_created',
        post_hook='{{ expose_spells(\'["arbitrum", "avalanche_c"]\',
                                    "project",
                                    "gmx",
                                    \'["ai_data_master","gmx-io"]\') }}'
        )
}}

{%- set chains = [
    'arbitrum',
    'avalanche_c',
] -%}

{%- for chain in chains -%}
SELECT 
    blockchain,
    block_time,
    block_date,
    block_number,
    tx_hash,
    index,
    contract_address,
    tx_from,
    tx_to,
    event_name,
    msg_sender,

    account,
    receiver,
    callback_contract,
    market,
    long_token_swap_path,
    short_token_swap_path,
    market_token_amount,
    min_long_token_amount,
    min_short_token_amount,
    updated_at_time,
    execution_fee,
    callback_gas_limit,
    withdrawal_type,
    should_unwrap_native_token,
    "key"

FROM {{ ref('gmx_v2_' ~ chain ~ '_withdrawal_created') }}
{% if not loop.last %}
UNION ALL
{% endif %}
{%- endfor -%}


