// Archivo: src/reward_distributor.cairo
#[starknet::contract]
mod reward_distributor {    
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use starknet::storage::Map; 
    use core::traits::{TryInto, Into}; 

    
    //    use crate::buoy_registry::{IBuoyRegistryDispatcher, IBuoyRegistryDispatcherTrait};

    #[starknet::interface]
    trait IERC20<TContractState> {
        fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    }

    #[starknet::interface]
    trait IRewardDistributor<TContractState> {
        fn update_buoy_metrics(
            ref self: TContractState,
            buoy_id: u256,
            uptime_seconds: u64,
            quality_score: u8
        );
        
        fn claim_rewards(
            ref self: TContractState,
            buoy_id: u256
        );
        
        fn get_accumulated_rewards(
            self: @TContractState,
            buoy_id: u256
        ) -> u256;
    }
    
    #[storage]
    struct Storage {
        buoy_registry: ContractAddress, 
        reward_token: ContractAddress,
        total_rewards_pool: u256,
        buoy_uptime: Map<u256, u64>,
        buoy_last_ping: Map<u256, u64>,
        data_quality_score: Map<u256, u8>,
        accumulated_rewards: Map<u256, u256>,
        oracle_address: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        RewardCalculated: RewardCalculated,
        RewardClaimed: RewardClaimed,
        MetricsUpdated: MetricsUpdated,
    }

    #[derive(Drop, starknet::Event)]
    struct RewardCalculated {
        buoy_id: u256,
        amount: u256,
        uptime_score: u8,
        quality_score: u8,
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct RewardClaimed {
        buoy_id: u256,
        operator: ContractAddress,
        amount: u256,
    }
    
    #[derive(Drop, starknet::Event)]
    struct MetricsUpdated {
        buoy_id: u256,
        uptime_seconds: u64,
        quality_score: u8,
        new_reward: u256,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        buoy_registry: ContractAddress,
        reward_token: ContractAddress,
        oracle_address: ContractAddress
    ) {
        self.buoy_registry.write(buoy_registry);
        self.reward_token.write(reward_token);
        self.oracle_address.write(oracle_address);
        self.total_rewards_pool.write(0_u256);
    }
    
    fn calculate_reward(
        self: @ContractState, 
        buoy_id: u256,
        uptime_seconds: u64,
        quality_score: u8
    ) -> u256 {
        let base_rate = 10_u256; 
        let uptime_hours = uptime_seconds / 3600;
        
        let uptime_factor: u256 = if uptime_hours >= 168 {
            100_u256
        } else {
            (uptime_hours * 100 / 168).into()
        };
        
        let quality_factor: u256 = quality_score.into();

        let uptime_weighted = (uptime_factor * 60_u256);
        let quality_weighted = (quality_factor * 40_u256);
        let total_score = (uptime_weighted + quality_weighted) / 100_u256; 

        let reward = (base_rate * total_score) / 100_u256;
        reward
    }

    #[abi(embed_v0)]
    impl RewardDistributorImpl of IRewardDistributor<ContractState> {
        fn update_buoy_metrics(
            ref self: ContractState,
            buoy_id: u256,
            uptime_seconds: u64,
            quality_score: u8
        ) {
            let caller = get_caller_address();
            let oracle = self.oracle_address.read();
            assert(caller == oracle, 'Only oracle can update');

            self.buoy_uptime.write(buoy_id, uptime_seconds);
            self.data_quality_score.write(buoy_id, quality_score);

            let block_timestamp = get_block_timestamp();
            self.buoy_last_ping.write(buoy_id, block_timestamp);
            
            let reward = calculate_reward(
                @self, buoy_id, uptime_seconds, quality_score
            );

            let current_rewards = self.accumulated_rewards.read(buoy_id);
            let new_total = current_rewards + reward;
            self.accumulated_rewards.write(buoy_id, new_total);

            let current_pool = self.total_rewards_pool.read();
            self.total_rewards_pool.write(current_pool + reward);
            
            let uptime_hours = uptime_seconds / 3600;

            self.emit(Event::RewardCalculated(RewardCalculated {
                buoy_id,
                amount: reward,
                uptime_score: uptime_hours.try_into().unwrap_or(255_u8),
                quality_score,
                timestamp: block_timestamp,
            }));
            
            self.emit(Event::MetricsUpdated(MetricsUpdated {
                buoy_id,
                uptime_seconds,
                quality_score,
                new_reward: reward,
            }));
        }

        fn claim_rewards(
            ref self: ContractState,
            buoy_id: u256
        ) {
            let caller = get_caller_address();
            
            // let buoy_registry_addr = self.buoy_registry.read();
            // let buoy_registry = IBuoyRegistryDispatcher { contract_address: buoy_registry_addr };
            // let owner = buoy_registry.get_buoy_owner(buoy_id);
            // assert(owner == caller, 'Not buoy owner');
            
            let rewards = self.accumulated_rewards.read(buoy_id);
            assert(rewards > 0_u256, 'No rewards available');
            
            // let token_dispatcher = IERC20Dispatcher { contract_address: self.reward_token.read() };
            // token_dispatcher.transfer(caller, rewards);
            
            self.accumulated_rewards.write(buoy_id, 0_u256);
            
            self.emit(Event::RewardClaimed(RewardClaimed {
                buoy_id,
                operator: caller,
                amount: rewards,
            }));
        }
        
        fn get_accumulated_rewards(
            self: @ContractState,
            buoy_id: u256
        ) -> u256 {
            self.accumulated_rewards.read(buoy_id)
        }
    }
}