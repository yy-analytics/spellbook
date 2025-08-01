{{ config(
        alias='solvers',
        
        post_hook='{{ expose_spells(\'["gnosis"]\',
                                    "project",
                                    "cow_protocol",
                                    \'["bh2smith", "gentrexha"]\') }}'
)}}

-- Find the PoC Query here: https://dune.com/queries/1399494
WITH
-- Aggregate the solver added and removed events into a single table
-- with true/false for adds/removes respectively
solver_activation_events as (
    select solver, evt_block_number, evt_index, True as activated
    from {{ source('gnosis_protocol_v2_gnosis', 'GPv2AllowListAuthentication_evt_SolverAdded') }}
    union
    select solver, evt_block_number, evt_index, False as activated
    from {{ source('gnosis_protocol_v2_gnosis', 'GPv2AllowListAuthentication_evt_SolverRemoved') }}
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
    FROM (VALUES (0xd8da60bDe22461D7Aa11540C338dC56a0E546b0D, 'barn', 'Legacy'),
                 (0xe66EB17F8679f90cCc0ed9A05c23f267cAef421E, 'barn', 'Naive'),
                 (0x79f175703ECE2AbC7BE2e2a603eBBa319FB84Acc, 'barn', 'Baseline'),
                 (0x508bCC23C1a808A9c41D10E2FCB544Ffb76ae3E5, 'barn', 'MIP'),
                 (0x7942a2b3540d1eC40B2740896f87aEcB2a588731, 'barn', 'Quasimodo'),
                 (0x26029B63C7DBD0C4C04D7226C3e7de5EAb3DB3D8, 'barn', 'Gnosis_1inch'),
                 (0x52ac5B5e85De9aa72ef5925989Fc419AA04EB15b, 'barn', 'Seasolver'),
                 (0xf794f31976a9a1d866cadfecde8984e656395a70, 'barn', 'Quasilabs'),
                 (0x449944c987d622cd8db9c150fd4ecdfe4435b836, 'barn', 'Naive'),
                 (0x9aaceb30c5b0e676a6b20d0c6be68f58bc7d8659, 'barn', 'Baseline'),
                 (0xd474668a7a9daf34f37c54b22622106277c24166, 'barn', 'MIP'),
                 (0x97d69672e8fe5be64d7d5bbba438ae9b08187667, 'barn', 'MIP'),
                 (0x43e834BE774da64DDe12014e287539E910310255, 'barn', 'Legacy'),
                 (0x67F25791224f0132E6c5102D4b0B3Fbf9e8Aa69d, 'barn', 'Legacy'),
                 (0xc605D77C083FeD57EbC70D0B1d8E0F0fe6a39a8C, 'barn', 'Naive'),
                 (0x2Dd00F9f614E2D8E3AB14FBAe1FDA36395E76b85, 'barn', 'Baseline'),
                 (0xF9E47818698A0E2588848B8aB0E631D84B86B852, 'barn', 'Quasimodo'),
                 (0x2D9412AF54A8d3514B75163F3ACB27a3B996602F, 'barn', 'Gnosis_1inch'),
                 (0x5c3472c3F664B6EfA72BF39C5E04C71182483c90, 'barn', 'Naive'),
                 (0x46D5948B6d2dDD46138de1232738459AB77FD10e, 'barn', 'Baseline'),
                 (0x027aF765554bD4F768415e299EE610C90e9bED55, 'barn', 'Quasimodo'),
                 (0xC088aea818dE69CeC696054682098ABa804b4FC9, 'barn', 'Gnosis_1inch'),
                 (0x4930a9012e8677ae764e44f2b46af8087a1f9f8e, 'barn', 'Gnosis_BalancerSOR'),
                 (0x8e600b399Da9c46255ccac98764987cF81837a66, 'barn', 'Enso'),
                 (0xC8D2f12a9505a82C4f6994204f4BbF095183E63A, 'barn', 'Seasolver'),
                 (0x67be9614C4E0FCdA95AFC66a95B5BDAFb55fa362, 'barn', 'Portus'),
                 (0x53F5378A6f8bb24333aD8D68FD28816504a467b2, 'barn', 'Copium_Capital'),
                 (0xC4dd6355Fbc6Eb108FD1C100389789C5B1A9A980, 'barn', 'Barter'),
                 (0x4398129426Cb1377E9E10395b8dfBDa153c7Fe7D, 'barn', 'Fractal'),
                 (0xBB765c920f86e2A2654c4B82deB5BC2E092fF93b, 'barn', 'Portus'),
                 (0x01B278ab345Fc427B9Efd112928ACd6b7403c298, 'barn', 'GlueX_Protocol'),
                 (0x911D92D6c905b1DFf68A6De64b9058C941BEC6A1, 'barn', 'ApeOut_1inch'),
                 (0xB073F89C5BFDdD973b42A5629ab96891fAD74118, 'barn', 'Laita'),
                 (0xF2090280361Cc0571c2817Ca7f9F3C628D2bE180, 'barn', 'ExtQuasimodo'),
                 (0x700f0d287C8471057B7856AC7099343854a06b1D, 'barn', 'Wraxyn'),
                 (0xE17B48cC9c5330d04e08c54E40Ed8107D1E4783f, 'barn', 'Arctic'),
                 (0x7f200e278e5C4A9E7861d9D8c73E621Fa96d7E51, 'barn', 'Helixbox'),
                 (0x5fa8c6F28FC234D3b71f27913429b29091FE0f1D, 'prod', 'Helixbox'),
                 (0xaf5Baa0Ac599d2CCE7C7B7D1803AbAcBd8936598, 'prod', 'Arctic'),
                 (0x4799d639954Bf7A2c420C20a72eBd7caF900bfc4, 'prod', 'Wraxyn'),
                 (0x638D7114Ced5E17bE1a935EC80B20a0A4109360c, 'prod', 'ExtQuasimodo'),
                 (0x606Ce11E72BC77363cE0Dc74A2ed2b4244968143, 'prod', 'Laita'),
                 (0xE8b92BCd54DAb0c833Bd9ebEcd6770BAae075863, 'prod', 'ApeOut_1inch'),
                 (0x490F34C46cF271B288d1833571f5D47B7e068163, 'prod', 'GlueX_Protocol'),
                 (0x6bf97aFe2D2C790999cDEd2a8523009eB8a0823f, 'prod', 'Portus'),
                 (0x727EB77c6f84ef148403f641aA32d75b7f6902A7, 'prod', 'Fractal'),
                 (0x0a360134553feED49FE5eb273074d80B6e45941F, 'prod', 'Barter'),
                 (0xb4694FE6590acd1281Dc34a966bbAE224559BaD4, 'prod', 'Copium_Capital'),
                 (0x227FDA1D5970dF605D785Bf5F2F8899d5fdF8624, 'prod', 'Portus'),
                 (0xE3068acB5b5672408eADaD4417e7d3BA41D4FEBe, 'prod', 'Seasolver'),
                 (0x12c53cdD1ef150E1cd291DD210b761acFADA6B9C, 'prod', 'Enso'),
                 (0xf671d28fef15e5eafc21898c2814b1b4cd88bc9a, 'prod', 'Gnosis_BalancerSOR'),
                 (0x056545021B39790eFb0a074827e7FddCb751A179, 'prod', 'Gnosis_1inch'),
                 (0xfb88fC234278a2c9CCEFfbAcdb01B8A993307A22, 'prod', 'Quasimodo'),
                 (0x71B2EA049f4247bF0c0265dFc156483C0df58056, 'prod', 'Baseline'),
                 (0x20596Ff7dB7E391589c8EBD668F11C399EFbe7d9, 'prod', 'Naive'),
                 (0x14Cda0a87a3E98e704a40D586cc7cF0889523f31, 'prod', 'Legacy'),
                 (0x230FF84887616f29F5c55Ce68FF627a29f79D0cC, 'prod', 'Naive'),
                 (0xB4783aBc7B1e5FdAEb36F78eE585e03Ee6eBB718, 'prod', 'Baseline'),
                 (0x920c9D5ec65dAC83435e9aF378C0f6fac69b8B66, 'prod', 'MIP'),
                 (0x7938A4770953Ab0003bF1e1fC5fC7F769B57d525, 'prod', 'Quasilabs'),
                 (0xd2F50B092ec32623c4955cEF4AE30C4699353735, 'prod', 'Gnosis_1inch'),
                 (0x8E747b386DcF81e7Fc888E1dDc2D3C1401bd34A3, 'prod', 'Naive'),
                 (0x5D665472e2026C405aAc65cC652470a1B8FCff08, 'prod', 'Baseline'),
                 (0xe71D3324E17E99B56c294067370D45111bc968D6, 'prod', 'Quasimodo'),
                 (0xa7c4C18106e92Cea479627D02FAb583D987f17d9, 'prod', 'Gnosis_1inch'),
                 (0xfaBBDf8a77005C00edBe0000bDC000644c024322, 'prod', 'Copium_Capital'),
                 (0x68dEE65bB88d919463495E5CeA9870a81f1e9413, 'service', 'Withdraw'),
                 (0xa03be496e67ec29bc62f01a428683d7f9c204930, 'service', 'Withdraw'),
                 (0x7524942F9283FBFa8F17b05CC0a9cBde397d25b3, 'test', 'Test 1')
         ) as _
)
-- Combining the metadata with current activation status for final table
select solver as address,
      case when environment is not null then environment else 'new' end as environment,
      case when name is not null then name else 'Uncatalogued' end      as name,
      active
from registered_solvers
    left outer join known_solver_metadata on solver = address;
