{{ config(
        schema = 'cow_protocol_arbitrum',
        alias='solvers',
        post_hook='{{ expose_spells(blockchains = \'["arbitrum"]\',
                                    spell_type = "project",
                                    spell_name = "cow_protocol",
                                    contributors = \'["olgafetisova"]\') }}'
)}}

-- Find the PoC Query here: https://dune.com/queries/3840597
WITH
-- Aggregate the solver added and removed events into a single table
-- with true/false for adds/removes respectively
solver_activation_events as (
    select solver, evt_block_number, evt_index, True as activated
    from {{ source('gnosis_protocol_v2_arbitrum', 'GPv2AllowListAuthentication_evt_SolverAdded') }}
    union
    select solver, evt_block_number, evt_index, False as activated
    from {{ source('gnosis_protocol_v2_arbitrum', 'GPv2AllowListAuthentication_evt_SolverRemoved') }}
),
-- Sorting by (evt_block_number, evt_index) allows us to pick the most recent activation status of each unique solver
ranked_solver_events as (
    select
        rank() over (partition by solver order by evt_block_number desc, evt_index desc) as rk,
        solver,
        evt_block_number,
        evt_index,
        activated as active
    from solver_activation_events
),
registered_solvers as (
    select solver, active
    from ranked_solver_events
    where rk = 1
),
-- Manually inserting environment and name for each "known" solver
known_solver_metadata (address, environment, name) as (
    SELECT *
    FROM (
      VALUES
                (0xA70892d1Af41aBD2F648FEC74Ea2c17e56Ac3B9A, 'prod', 'Naive'),
                (0xba36CEfb45d1CdD2Ae30a899C432c5081E095Ff8, 'prod', 'Baseline'),
                (0xF017C6F66D68d11AF00FD243494E3fa0EBf44C66, 'prod', 'Quasimodo'),
                (0x001088C88be46346ED99856dcfA3a00Da7AAf212, 'prod', 'Gnosis_1inch'),
                (0xc46Ac109FDe084192BE59C24C3680D818763b0fd, 'prod', 'Gnosis_ParaSwap'),
                (0xD31E0CE8154Da6b8086d961eB3068Ef74C4322b6, 'prod', 'Gnosis_0x'),
                (0xAa224676d096B6Fc257F8C386C67d9e96e53AD59, 'prod', 'Gnosis_BalancerSOR'),
                (0x5932b2c05172aAfE097CE0Fbd27d18a7d5A45eE1, 'prod', 'Portus'),
                (0x3A485742Bd85e660e72dE0f49cC27AD7a62911B5, 'prod', 'Seasolver'),
                (0x059aefdF9d9F47def37cF7066DA83fEB91fDd089, 'prod', 'Barter'),
                (0x40798d2261f8b7F11BFa73623c99C876844dD05A, 'prod', 'OpenOcean_Aggregator'),
                (0x0648548f891E1356f197070D009704e574182bfB, 'prod', 'Rizzolver'),
                (0x23e868881dfe0531358B8FE0cbec43FD860cbF33, 'prod', 'Rizzolver'),
                (0x2692F7bFCB2e1a8575434b9511804266D9aeb628, 'prod', 'Velvet'),
                (0x1FA2FF499b327f53cD9a82BcAFE36093563E32e4, 'prod', 'Apollo'),
                (0x0148538e6cA813D41eA5988008Cdc9B72d4e65A7, 'prod', 'Laita'),
                (0x9C75aae1Bd2f96D7B4E67e8C5344f3304382276E, 'prod', 'Enso'),
                (0x5156808c3f9440191ef600587a73c87bb23c92b2, 'barn', 'Enso'),
                (0x034F6Aca83F1900b0157b0123F514A29456eeA59, 'barn', 'Laita'),
                (0x6bf97aFe2D2C790999cDEd2a8523009eB8a0823f, 'prod', 'Portus'),
                (0xBB765c920f86e2A2654c4B82deB5BC2E092fF93b, 'barn', 'Portus'),
                (0x5E06F88D28603f5bB106bD5C8AD93ce2E902d24b, 'barn', 'Apollo'),
                (0x669Be18D403Be353C1B9EBC87225313Ec2560BF5, 'barn', 'Velvet'),
                (0x20dC1014E946Cf511Ee535D908eC9a1d75Dd66ce, 'barn', 'Naive'),
                (0x2e6822f4Ab355E386d1A4fd34947ACE0F6f344a7, 'barn', 'Baseline'),
                (0x03a65D265E0613326ca23f5E6A1a99Ab2F12600B, 'barn', 'Quasimodo'),
                (0xee10E8D38150BEe3b0B32c41b74821d6e7Da485A, 'barn', 'Gnosis_ParaSwap'),
                (0x9C803d345615aDe1e5ae07A789968403fAc9171a, 'barn', 'Gnosis_ParaSwap'),
                (0x69433b336952e84Db44EF40b16B338F139B8baA1, 'barn', 'Gnosis_0x'),
                (0xCED55FC88186f672105712fe177374cce4861FDF, 'barn', 'Gnosis_BalancerSOR'),
                (0xE376a730037D8B495864FD5ed6373BE89643cD06, 'barn', 'Portus'),
                (0x2633bd8e5FDf7C72Aca1d291CA11bdB717A6aa3d, 'barn', 'Seasolver'),
                (0x7B0211286d8Dfdb717f4A2E5Fa5131eD911097e1, 'barn', 'Barter'),
                (0xc8371B2898FBaEeAe658f9FaeE8ddeDA24e37012, 'barn', 'OpenOcean_Aggregator'),
                (0x2aeC288B42C99D2e8e984c5C324FB069f7705186, 'barn', 'Rizzolver'),
                (0x26B5e3bF135D3Dd05A220508dD61f25BF1A47cBD, 'barn', 'Rizzolver'),
                (0x8C3f83f6A489cCbA2E3df304034F8C120cEb3527, 'barn', 'GlueX_Protocol'),
                (0x49E1F55D4a695291533BB0A993aca5D58E90C613, 'prod', 'GlueX_Protocol'),
                (0x3144a51a7699c629070d6aAEf68256c2d07a6334, 'barn', 'OKX'),
                (0x7F636D152AB0Cfc68A899d4dF441F2322cd78C6B, 'prod', 'OKX'),
                (0x7199cF10CF16b85fb59170d5c83d114Ac11d3afA, 'barn', 'ApeOut_1inch'),
                (0xDd8a1F39fFBFB77c488054CB18f53aa9A3c4bD9D, 'prod', 'ApeOut_1inch'),
                (0x312B5D8AbC6b7C8355B86f5F7803E9cD97AE8D75, 'barn', 'Helixbox'),
                (0x4CdbA844CEB949567eA18b9EF185515fA626c69D, 'prod', 'Helixbox'),
                (0x9CF49541f8b94DA501Cd16B60Fa176D856fB1e75, 'prod', 'Sector_Finance'),
                (0xaf888d387adceed01a736aa3deae75dcf3edd8c1, 'prod', 'Copium_Capital'),
                (0xD5a9FAE900C3FfF4145753F47Eb2E9d573b107D7, 'barn', 'Piggy'),
                (0xFE082A5784cA28F67D1E6aB04EAe7c313c210229, 'prod', 'Piggy'),
                (0x550EC8e3944E9aF8411f32273555656977D884Ac, 'barn', 'Apollo'),
                (0x65E80731F97b8361E77670357d287266dD0d93b6, 'prod', 'Apollo'),
                (0xEa77cB08FBf7ef0CaF615dcE37A159D56B2B867f, 'barn', 'Wraxyn'),
                (0x09498CF3414616c1d58979FCE65438473C998c47, 'prod', 'Wraxyn'),
                (0x301994d1A89578e9933E44982eb969B9f38d7097, 'barn', 'Unizen'),
                (0x4D72B179b7706A768C0bA378D78E1dD2d5c618a2, 'prod', 'Unizen'),
                (0xe52b4918554f9dDcAC10BE388aeA3a53aB3d33f3, 'barn', 'Horadrim'),
                (0xfFF90c451ba1Cb6A1B8b950DA4aa9c3f82270Ac3, 'prod', 'Horadrim'),
                (0xcf6fda0b383ef980aacbc56d9d0be14931ffe576, 'barn', 'ExtQuasimodo'),
                (0xADF619eB586e7b3586BA5f45A6086D64b8F1dcAa, 'prod', 'ExtQuasimodo'),
                (0x7b0DF3Cd3bFf32f6545A4491cD414152D7d29E3c, 'barn', 'Arctic'),
                (0xA8d8613ec7cbE23c506ef5F293d570945b988Cb9, 'prod', 'Arctic'),
                (0xA14b145eb2f3010e1021514a5B6d8570aBD60C68, 'barn', 'Bebop'),
                (0x6566692e5e7fC9A3559D539488C55C1570a6bd2F, 'prod', 'Bebop'),
                (0x90Cf61BE4f7A8A47B638200e5434B1D895F8D710, 'barn', 'Tsolver'),
                (0x76EF27384f6aE6f58499C2eCC2273DC4bB2D9B91, 'prod', 'Tsolver'),
                (0x4dd1be0Cd607E5382Dd2844fA61D3a17e3e83D56, 'prod', 'Rizzolver'),
                (0x95238c3Bf936424f4B34Ebf8B1e6C1577A6B3406, 'barn', 'Overnight Finance'),
                (0xcEbd13eE45671CBA34B3424Cd1CD616FAc780EA9, 'prod', 'Overnight Finance'),
                (0x9702Add8e0943Ec9a6e1e87FC612537E78d7194E, 'barn', 'MX Trading'),
                (0x859A672a564A99CDA9BfB2c39ca80Dd9256B94d3, 'prod', 'MX Trading'),
                (0x96B8F359f0b2067D7F7C84F55f172FF1A70ee0F4, 'barn', 'Trusted Volumes'),
                (0xE6094DFE442F44df4cfAa21dCC054dC85Fc299DB, 'prod', 'Trusted Volumes')
    ) as _
)
-- Combining the metadata with current activation status for final table
select solver as address,
       case when environment is not null then environment else 'new' end as environment,
       case when name is not null then name else 'Uncatalogued'      end as name,
      active
from registered_solvers
left outer join known_solver_metadata on solver = address

