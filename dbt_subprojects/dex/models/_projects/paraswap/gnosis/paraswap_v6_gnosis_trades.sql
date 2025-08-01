{{ config(
    schema = 'paraswap_v6_gnosis',
    alias = 'trades',

    partition_by = ['block_month'],
    materialized = 'incremental',
    file_format = 'delta',
    incremental_strategy = 'merge',
    incremental_predicates = [incremental_predicate('DBT_INTERNAL_DEST.block_time')],
    unique_key = ['block_date', 'blockchain', 'project', 'version', 'tx_hash', 'method', 'trace_address'],
    post_hook='{{ expose_spells(\'["gnosis"]\',
                                "project",
                                "paraswap_v6",
                                \'["eptighte"]\') }}'
    )
}}

{% set project_start_date = '2024-03-01' %}

with dexs AS (
        SELECT
            blockTime AS block_time,
            blockNumber AS block_number,
            from_hex(beneficiary) AS taker,
            null AS maker,  -- TODO: can parse from traces
            receivedAmount AS token_bought_amount_raw,
            fromAmount AS token_sold_amount_raw,
            CAST(NULL AS double) AS amount_usd,
            method,
            {{ to_wrapped_native_token('gnosis', 'from_hex(destToken)', 'token_bought_address')   }},
            {{ to_wrapped_native_token('gnosis', 'from_hex(srcToken)', 'token_sold_address')   }},            
            projectContractAddress as project_contract_address,
            call_tx_hash as tx_hash,
            call_trace_address AS trace_address,
            CAST(-1 as integer) AS evt_index
        FROM {{ ref('paraswap_v6_gnosis_trades_decoded') }}
        {% if is_incremental() %}
        WHERE {{ incremental_predicate('blockTime') }}
        {% endif %}
)

SELECT 'gnosis' AS blockchain,
    'paraswap' AS project,
    '6' AS version,
    cast(date_trunc('day', d.block_time) as date) as block_date,
    cast(date_trunc('month', d.block_time) as date) as block_month,
    d.block_time,
    method,
    e1.symbol AS token_bought_symbol,
    e2.symbol AS token_sold_symbol,
    CASE
        WHEN lower(e1.symbol) > lower(e2.symbol) THEN concat(e2.symbol, '-', e1.symbol)
        ELSE concat(e1.symbol, '-', e2.symbol)
    END AS token_pair,
    d.token_bought_amount_raw / power(10, e1.decimals) AS token_bought_amount,
    d.token_sold_amount_raw / power(10, e2.decimals) AS token_sold_amount,
    d.token_bought_amount_raw,
    d.token_sold_amount_raw,
    coalesce(
        d.amount_usd
        ,(d.token_bought_amount_raw / power(10, p1.decimals)) * p1.price
        ,(d.token_sold_amount_raw / power(10, p2.decimals)) * p2.price
    ) AS amount_usd,
    d.token_bought_address,
    d.token_sold_address,
    coalesce(d.taker, tx."from") AS taker,
    coalesce(d.maker, tx."from") as maker,
    d.project_contract_address,
    d.tx_hash,
    tx."from" AS tx_from,
    tx.to AS tx_to,
    d.trace_address,
    d.evt_index
FROM dexs d
INNER JOIN {{ source('gnosis', 'transactions') }} tx ON d.tx_hash = tx.hash
    AND d.block_number = tx.block_number
    {% if not is_incremental() %}
    AND tx.block_time >= TIMESTAMP '{{project_start_date}}'
    {% endif %}
    {% if is_incremental() %}
    AND {{ incremental_predicate('tx.block_time') }}
    {% endif %}
LEFT JOIN {{ source('tokens', 'erc20') }} e1 ON e1.contract_address = d.token_bought_address
    AND e1.blockchain = 'gnosis'
LEFT JOIN {{ source('tokens', 'erc20') }} e2 on e2.contract_address = d.token_sold_address
    AND e2.blockchain = 'gnosis'
LEFT JOIN {{ source('prices', 'usd') }} p1 ON p1.minute = date_trunc('minute', d.block_time)
    AND p1.contract_address = d.token_bought_address
    AND p1.blockchain = 'gnosis'
    {% if not is_incremental() %}
    AND p1.minute >= TIMESTAMP '{{project_start_date}}'
    {% endif %}
    {% if is_incremental() %}
    AND {{ incremental_predicate('p1.minute') }}
    {% endif %}
LEFT JOIN {{ source('prices', 'usd') }} p2 ON p2.minute = date_trunc('minute', d.block_time)
    AND p2.contract_address = d.token_sold_address
    AND p2.blockchain = 'gnosis'
    {% if not is_incremental() %}
    AND p2.minute >= TIMESTAMP '{{project_start_date}}'
{% endif %}
    {% if is_incremental() %}
    AND {{ incremental_predicate('p2.minute') }}
    {% endif %}
