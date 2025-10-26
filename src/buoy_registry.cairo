// Archivo: src/buoy_registry.cairo
#[starknet::contract]
mod buoy_registry {    
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use starknet::storage::Map;

    #[starknet::interface]
    trait IBuoyRegistry<TContractState> {
        fn register_buoy(
            ref self: TContractState,
            metadata_hash: felt252,
            location_hash: felt252,
            stake_amount: u256
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

    #[storage]
    struct Storage {
        buoy_owner: Map<u256, ContractAddress>,
        buoy_metadata: Map<u256, felt252>,
        buoy_location: Map<u256, felt252>,
        total_buoys: u256,
        operator_stakes: Map<ContractAddress, u256>,
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
        self.total_buoys.write(0_u256);
    }

    #[abi(embed_v0)] 
    impl BuoyRegistryImpl of IBuoyRegistry<ContractState> { // <<< No se necesita `super::`
        fn register_buoy(
            ref self: ContractState,
            metadata_hash: felt252,
            location_hash: felt252,
            stake_amount: u256
        ) -> u256 {
            let caller = get_caller_address();
            assert(stake_amount >= 100_u256, 'Insufficient stake');
            let buoy_id = self.total_buoys.read() + 1_u256;

            self.buoy_owner.write(buoy_id, caller);
            self.buoy_metadata.write(buoy_id, metadata_hash);
            self.buoy_location.write(buoy_id, location_hash);
            self.total_buoys.write(buoy_id);
            self.operator_stakes.write(caller, stake_amount);
            
            let block_timestamp = get_block_timestamp();
            
            self.emit(Event::BuoyRegistered(BuoyRegistered {
                buoy_id,
                owner: caller,
                location_hash,
                timestamp: block_timestamp,
            }));
            
            buoy_id
        }

        fn transfer_buoy(
            ref self: ContractState,
            buoy_id: u256,
            to: ContractAddress
        ) {
            let caller = get_caller_address();
            let owner = self.buoy_owner.read(buoy_id);
            assert(owner == caller, 'Not owner');
            
            self.buoy_owner.write(buoy_id, to);
            
            self.emit(Event::BuoyTransferred(BuoyTransferred {
                buoy_id,
                from: caller,
                to
            }));
        }
        
        fn get_buoy_owner(
            self: @ContractState,
            buoy_id: u256
        ) -> ContractAddress {
            self.buoy_owner.read(buoy_id)
        }
        
        fn get_total_buoys(
            self: @ContractState
        ) -> u256 {
            self.total_buoys.read()
        }
    }
}