{{ config(
        schema = 'beethoven_x_fantom',
        alias = 'token_balance_changes',
        materialized = 'table',
        file_format = 'delta'
    )
}}

{{ 
    balancer_v2_compatible_token_balance_changes_macro(
        blockchain = 'fantom',
        version = '2',
        project_decoded_as = 'beethoven_x',
        base_spells_namespace = 'beethoven_x_fantom',
        pool_labels_model = 'beethoven_x_pools_fantom'
    )
}}