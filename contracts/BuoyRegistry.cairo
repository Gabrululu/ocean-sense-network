// BuoyRegistry - Registro de boyas como NFTs en Starknet
// Ocean-Sense Network

use starknet::ContractAddress;
use starknet::get_caller_address;

#[starknet::interface]
trait IBuoyRegistry<TContractState> {
    fn register_buoy(
        ref self: TContractState,
        metadata_hash: felt252,
        location_hash: felt252,
        stake_amount: felt252
    ) -> u256;
    
    fn transfer_buoy(
        ref self: TContractState,
        buoy_id: u256,
        to: ContractAddress
    );
    
    fn get_buoy_owner(
        self: @TContractState,
        buoy_id: u256
    ) -> ContractAddress;
    
    fn get_total_buoys(
        self: @TContractState
    ) -> u256;
}

#[starknet::contract]
mod BuoyRegistry {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    
    #[storage]
    struct Storage {
        buoy_owner: Map<u256, ContractAddress>,
        buoy_metadata: Map<u256, felt252>,
        buoy_location: Map<u256, felt252>,
        total_buoys: u256,
        operator_stakes: Map<ContractAddress, felt252>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        BuoyRegistered: BuoyRegistered,
        BuoyTransferred: BuoyTransferred,
    }

    #[derive(Drop, starknet::Event)]
    struct BuoyRegistered {
        buoy_id: u256,
        owner: ContractAddress,
        location_hash: felt252,
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct BuoyTransferred {
        buoy_id: u256,
        from: ContractAddress,
        to: ContractAddress,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState
    ) {
        self.storage.total_buoys.write(0);
    }

    #[external(v0)]
    fn register_buoy(
        ref self: ContractState,
        metadata_hash: felt252,
        location_hash: felt252,
        stake_amount: felt252
    ) -> u256 {
        let caller = get_caller_address();
        
        // Requiere stake mínimo de 100 tokens (en wei equivalente)
        assert(stake_amount >= 100, 'Insufficient stake');
        
        let buoy_id = self.storage.total_buoys.read() + 1;
        
        self.storage.buoy_owner.write(buoy_id, caller);
        self.storage.buoy_metadata.write(buoy_id, metadata_hash);
        self.storage.buoy_location.write(buoy_id, location_hash);
        self.storage.total_buoys.write(buoy_id);
        self.storage.operator_stakes.write(caller, stake_amount);
        
        let block_timestamp = get_block_timestamp();
        
        self.emit(BuoyRegistered {
            buoy_id,
            owner: caller,
            location_hash,
            timestamp: block_timestamp,
        });
        
        buoy_id
    }

    #[external(v0)]
    fn transfer_buoy(
        ref self: ContractState,
        buoy_id: u256,
        to: ContractAddress
    ) {
        let caller = get_caller_address();
        let owner = self.storage.buoy_owner.read(buoy_id);
        
        assert(owner == caller, 'Not owner');
        
        self.storage.buoy_owner.write(buoy_id, to);
        
        self.emit(BuoyTransferred {
            buoy_id,
            from: caller,
            to
        });
    }
    
    #[external(v0)]
    fn get_buoy_owner(
        self: @ContractState,
        buoy_id: u256
    ) -> ContractAddress {
        self.storage.buoy_owner.read(buoy_id)
    }
    
    #[external(v0)]
    fn get_total_buoys(
        self: @ContractState
    ) -> u256 {
        self.storage.total_buoys.read()
    }
}

