// RewardDistributor - Sistema de recompensas por uptime y calidad de datos
// Ocean-Sense Network

use starknet::ContractAddress;
use starknet::get_caller_address;
use starknet::get_block_timestamp;
use starknet::storage::LegacyMap;

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

#[starknet::contract]
mod RewardDistributor {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    
    #[storage]
    struct Storage {
        buoy_registry: ContractAddress, // Referencia a BuoyRegistry
        reward_token: ContractAddress,  // Token ERC20 para recompensas
        total_rewards_pool: u256,
        buoy_uptime: LegacyMap<u256, u64>,     // Segundos activos
        buoy_last_ping: LegacyMap<u256, u64>,   // Timestamp del último ping
        data_quality_score: LegacyMap<u256, u8>, // Score 0-100
        accumulated_rewards: LegacyMap<u256, u256>, // Recompensas acumuladas
        oracle_address: ContractAddress, // Solo oracle puede actualizar métricas
    }

    #[event]
    #[derive(starknet::Event)]
    enum Event {
        RewardCalculated: RewardCalculated,
        RewardClaimed: RewardClaimed,
        MetricsUpdated: MetricsUpdated,
    }

    #[derive(starknet::Event)]
    struct RewardCalculated {
        buoy_id: u256,
        amount: u256,
        uptime_score: u8,
        quality_score: u8,
        timestamp: u64,
    }

    #[derive(starknet::Event)]
    struct RewardClaimed {
        buoy_id: u256,
        operator: ContractAddress,
        amount: u256,
    }
    
    #[derive(starknet::Event)]
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

    // Oracle actualiza métricas cada hora con datos del backend
    #[external(v0)]
    fn update_buoy_metrics(
        ref self: ContractState,
        buoy_id: u256,
        uptime_seconds: u64,
        quality_score: u8
    ) {
    let caller = get_caller_address();

    // Verificar que solo el oracle puede actualizar
    let oracle = self.oracle_address.read();
    assert(caller == oracle, 'Unauthorized: Only oracle can update');

    self.buoy_uptime.write(buoy_id, uptime_seconds);
    self.data_quality_score.write(buoy_id, quality_score);

    let block_timestamp = get_block_timestamp();
    self.buoy_last_ping.write(buoy_id, block_timestamp);
        
        // Calcular recompensa
        let reward = calculate_reward(
            @self, buoy_id, uptime_seconds, quality_score
        );

        let current_rewards = self.accumulated_rewards.read(buoy_id);
        let new_total = current_rewards + reward;

        self.accumulated_rewards.write(buoy_id, new_total);

        // Actualizar pool total
        let current_pool = self.total_rewards_pool.read();
        self.total_rewards_pool.write(current_pool + reward);
        
        let uptime_hours = uptime_seconds / 3600;

        self.emit(RewardCalculated {
            buoy_id,
            amount: reward,
            uptime_score: uptime_hours as u8,
            quality_score,
            timestamp: block_timestamp,
        });
        
        self.emit(MetricsUpdated {
            buoy_id,
            uptime_seconds,
            quality_score,
            new_reward: reward,
        });
    }

    #[external(v0)]
    fn claim_rewards(
        ref self: ContractState,
        buoy_id: u256
    ) {
        let caller = get_caller_address();
        
        // Verificar ownership en BuoyRegistry
        // TODO: Implementar llamada cross-contract
        // let buoy_registry = self.storage.buoy_registry.read();
        // let owner = IBuoyRegistryDispatcher { contract_address: buoy_registry }.get_buoy_owner(buoy_id);
        // assert(owner == caller, 'Not buoy owner');
        
    let rewards = self.accumulated_rewards.read(buoy_id);
        assert(rewards > 0, 'No rewards available');
        
        // Transfer tokens (requiere ERC20 interface)
        // TODO: Implementar transfer de tokens
        // IERC20Dispatcher { contract_address: self.storage.reward_token.read() }.transfer(caller, rewards);
        
    self.accumulated_rewards.write(buoy_id, 0_u256);
        
        self.emit(RewardClaimed {
            buoy_id,
            operator: caller,
            amount: rewards,
        });
    }
    
    #[external(v0)]
    fn get_accumulated_rewards(
        self: @ContractState,
        buoy_id: u256
    ) -> u256 {
    self.accumulated_rewards.read(buoy_id)
    }
    
    // Función interna para calcular recompensas
    fn calculate_reward(
        self: @ContractState,
        buoy_id: u256,
        uptime_seconds: u64,
        quality_score: u8
    ) -> u256 {
        // Fórmula: Reward = base_rate * (uptime_factor * 0.6 + quality_factor * 0.4)
        let base_rate = 10_u256; // 10 tokens por hora base

        // Uptime como % de semana activa (168 horas)
        let uptime_hours = uptime_seconds / 3600;
        let uptime_factor = ((uptime_hours * 100) / 168).into(); // convert to u256
        let quality_factor: u256 = quality_score.into();

        // Weighted average (all u256)
        let uptime_weighted = (uptime_factor * 60_u256) / 100_u256;
        let quality_weighted = (quality_factor * 40_u256) / 100_u256;
        let total_score = (uptime_weighted + quality_weighted) / 100_u256;

        let reward = (base_rate * total_score) / 100_u256;

        reward
    }
}

