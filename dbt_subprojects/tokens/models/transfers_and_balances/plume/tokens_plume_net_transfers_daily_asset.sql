{% set blockchain = 'plume' %}

{{ config(
        schema = 'tokens_' + blockchain
        , alias = 'net_transfers_daily_asset'
        , materialized = 'incremental'
        , file_format = 'delta'
        , incremental_strategy = 'merge'
        , unique_key = ['blockchain', 'block_date', 'contract_address']
        , incremental_predicates = [incremental_predicate('DBT_INTERNAL_DEST.block_date')]
        )
}}


{{ evm_net_transfers_daily_asset(
        blockchain=blockchain,
        native_contract_address='0x0000000000000000000000000000000000000000'
) 
}}