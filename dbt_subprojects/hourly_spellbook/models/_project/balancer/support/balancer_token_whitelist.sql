{{ config(
    schema = 'balancer',
    alias = 'token_whitelist'
    )
}}

    --These tokens are whitelisted to be used as pricing assets on liquidity calculations for weighted pools, due to the trustability of their data.

WITH whitelist_token as (
    SELECT * FROM (values
    (0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8, 'USDC', 'arbitrum'),
    (0xaf88d065e77c8cc2239327c5edb3a432268e5831, 'USDC', 'arbitrum'),
    (0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1, 'DAI', 'arbitrum'),
    (0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9, 'USDT', 'arbitrum'),
    (0x82aF49447D8a07e3bd95BD0d56f35241523fBab1, 'WETH', 'arbitrum'),
    (0x0fBcbaEA96Ce0cF7Ee00A8c19c3ab6f5Dc8E1921, 'WSTETH', 'arbitrum'),
    (0x5979d7b546e38e414f7e9822514be443a4800529, 'WSTETH', 'arbitrum'),
    (0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E, 'USDC', 'avalanche_c'),
    (0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7, 'USDT', 'avalanche_c'),
    (0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB, 'WETH', 'avalanche_c'),
    (0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7, 'wAVAX', 'avalanche_c'),
    (0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA, 'USDC', 'base'),
    (0x833589fcd6edb6e08f4c7c32d4f71b54bda02913, 'USDC', 'base'),
    (0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb, 'DAI', 'base'),
    (0x4200000000000000000000000000000000000006, 'WETH', 'base'),
    (0x21be370d5312f44cb42ce377bc9b8a0cef1a4c83, 'WFTM', 'fantom'),  
    (0xddafbb505ad214d7b80b1f830fccc89b60fb7a83, 'USDC', 'gnosis'),
    (0x4ecaba5870353805a9f068101a40e0f32ed605c6, 'USDT', 'gnosis'),
    (0xe91d153e0b41518a2ce8dd3d7944fa863463a97d, 'WXDAI', 'gnosis'),
    (0x6a023ccd1ff6f2045c3309768ead9e68f978f6e1, 'WETH', 'gnosis'),    
    (0x6c76971f98945ae98dd7d4dfca8711ebea946ea6, 'WSTETH', 'gnosis'),
    (0xaf204776c7245bf4147c2612bf6e5972ee483701, 'SDAI', 'gnosis'),    
    (0x9c58bacc331c9aa871afd802db6379a98e80cedb, 'GNO', 'gnosis'),        
    (0xdAC17F958D2ee523a2206206994597C13D831ec7, 'USDT', 'ethereum'),
    (0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 'USDC', 'ethereum'),
    (0x6B175474E89094C44Da98b954EedeAC495271d0F, 'DAI', 'ethereum'),
    (0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2, 'WETH', 'ethereum'),
    (0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0, 'WSTETH', 'ethereum'),
    (0x7F5c764cBc14f9669B88837ca1490cCa17c31607, 'USDC', 'optimism'),
    (0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1, 'USDT', 'optimism'),
    (0x94b008aA00579c1307B0EF2c499aD98a8ce58e58, 'DAI', 'optimism'),
    (0x4200000000000000000000000000000000000006, 'WETH', 'optimism'),
    (0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb, 'WSTETH', 'optimism'),
    (0x2791bca1f2de4661ed88a30c99a7a9449aa84174, 'USDC', 'polygon'),
    (0x8f3cf7ad23cd3cadbd9735aff958023239c6a063, 'DAI', 'polygon'),
    (0xc2132d05d31c914a87c6611c10748aeb04b58e8f, 'USDT', 'polygon'),
    (0x039e2fB66102314Ce7b64Ce5Ce3E5183bc94aD38, 'wS', 'sonic'),
    (0xe5da20f15420ad15de0fa650600afc998bbe3955, 'stS', 'sonic'),
    (0x1e5fe95fb90ac0530f581c617272cd0864626795, 'BEETS', 'sonic'),    
    (0xd3DCe716f3eF535C5Ff8d041c1A41C3bd89b97aE, 'scUSD', 'sonic'),    
    (0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, 'WMATIC', 'polygon'),
    (0x7ceb23fd6bc0add59e62ac25578270cff1b9f619, 'WETH', 'polygon'),
    (0x37eaa0ef3549a5bb7d431be78a3d99bd360d19e5, 'USDC', 'zkevm'),
    (0x744c5860ba161b5316f7e80d9ec415e2727e5bd5, 'DAI', 'zkevm'),
    (0x4f9a0e7fd2bf6067db6994cf12e4495df938e6e9, 'WETH', 'zkevm')
    )
        as t (address, name, chain))
    
SELECT * FROM whitelist_token
