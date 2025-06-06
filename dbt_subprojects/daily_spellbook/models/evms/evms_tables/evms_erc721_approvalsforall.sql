{{ config(
        schema='evms',
        alias = 'erc721_approvalsforall',
        materialized = 'view',
        post_hook='{{ expose_spells(evms_structured_blockchains_list() | tojson, "sector", "evms", \'[]\') }}'
        )
}}

{% set structured_blockchains = evms_structured_blockchains_list() %}

SELECT *
FROM (
        {% for blockchain in structured_blockchains %}
        SELECT
        '{{ blockchain }}' AS blockchain
        , contract_address
        , evt_tx_hash
        , evt_index
        , evt_block_time
        , evt_block_number
        , approved
        , owner
        , operator
        FROM {{ source('erc721_' + blockchain, 'evt_ApprovalForAll') }}
        {% if not loop.last %}
        UNION ALL
        {% endif %}
        {% endfor %}
        );