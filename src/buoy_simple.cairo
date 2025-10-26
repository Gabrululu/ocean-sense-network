// Archivo: src/buoy_simple.cairo
#[starknet::contract]
mod buoy_simple {    
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use starknet::storage::Map;
    use core::serde::Serde;
    use core::num::traits::Zero;

    #[starknet::interface]
    trait IBuoySimple<TContractState> {
        fn register_buoy(
            ref self: TContractState,
            buoy_id: u256,
            lat: felt252,
            lon: felt252
        );
        fn submit_data(ref self: TContractState, buoy_id: u256, timestamp: u64);
        fn get_buoy_info(self: @TContractState, buoy_id: u256) -> BuoyInfo;
        fn get_total_buoys(self: @TContractState) -> u256;
    }

    #[storage]
    struct Storage {
        buoys: Map<u256, BuoyInfo>,
        buoy_count: u256,
    }

    #[derive(Serde, starknet::Store, Drop, Copy)] 
    struct BuoyInfo {
        owner: ContractAddress,
        latitude: felt252,
        longitude: felt252,
        is_active: bool,
        total_readings: u32,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        BuoyRegistered: BuoyRegistered,
        DataSubmitted: DataSubmitted,
    }

    #[derive(Drop, starknet::Event)]
    struct BuoyRegistered {
        buoy_id: u256,
        owner: ContractAddress,
        latitude: felt252,
        longitude: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct DataSubmitted {
        buoy_id: u256,
        timestamp: u64,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.buoy_count.write(0_u256);
    }

    #[abi(embed_v0)] 
    impl BuoySimpleImpl of IBuoySimple<ContractState> {
        fn register_buoy(
            ref self: ContractState,
            buoy_id: u256,
            lat: felt252,
            lon: felt252
        ) {
            let caller = get_caller_address();
            
            assert(self.buoys.read(buoy_id).owner.is_zero(), 'Buoy ID already registered');
            
            let buoy = BuoyInfo {
                owner: caller,
                latitude: lat,
                longitude: lon,
                is_active: true,
                total_readings: 0,
            };

            self.buoys.write(buoy_id, buoy);
            let count = self.buoy_count.read();
            self.buoy_count.write(count + 1_u256);

            self.emit(Event::BuoyRegistered(BuoyRegistered {
                buoy_id,
                owner: caller,
                latitude: lat,
                longitude: lon,
            }));
        }

        fn submit_data(ref self: ContractState, buoy_id: u256, timestamp: u64) {
            let mut buoy = self.buoys.read(buoy_id);
            let caller = get_caller_address();
            
            assert(buoy.owner == caller, 'Not buoy owner');
            assert(buoy.is_active, 'Buoy not active');
            
            buoy.total_readings += 1;
            self.buoys.write(buoy_id, buoy);

            self.emit(Event::DataSubmitted(DataSubmitted { buoy_id, timestamp }));
        }

        fn get_buoy_info(self: @ContractState, buoy_id: u256) -> BuoyInfo {
            self.buoys.read(buoy_id)
        }

        fn get_total_buoys(self: @ContractState) -> u256 {
            self.buoy_count.read()
        }
    }
}
