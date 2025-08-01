{{ config(
    schema = 'paraswap_v6_gnosis',
    alias = 'trades_decoded',
    partition_by = ['block_month'],
    materialized = 'incremental',
    file_format = 'delta',
    incremental_strategy = 'merge',
    incremental_predicates = [incremental_predicate('DBT_INTERNAL_DEST.blockTime')],
    unique_key = ['call_tx_hash', 'method', 'call_trace_address'],    
    post_hook='{{ expose_spells(blockchains = \'["gnosis"]\',
	                                spell_type = "project",
	                                spell_name = "paraswap_v6",
	                                contributors = \'["eptighte"]\') }}'
    )
}}

{{ paraswap_v6_trades_master('gnosis', 'paraswap') }}
