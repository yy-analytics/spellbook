{{
    config(
        schema = 'dyorswap_ink',
        alias = 'base_trades',
        materialized = 'incremental',
        file_format = 'delta',
        incremental_strategy = 'merge',
        unique_key = ['tx_hash', 'evt_index'],
        incremental_predicates = [incremental_predicate('DBT_INTERNAL_DEST.block_time')]
    )
}}

{{
    uniswap_compatible_v2_trades(
        blockchain = 'ink',
        project = 'dyorswap',
        version = '1',
        Pair_evt_Swap = source('dyorswap_ink', 'uniswapv2pair_evt_swap'),
        Factory_evt_PairCreated = source('dyorswap_ink', 'uniswapv2factory_evt_paircreated')
    )
}}
