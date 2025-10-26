// Ocean-Sense Network - Simple Buoy Registry for Demo
#[starknet::contract]
mod BuoyRegistry {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    
    #[storage]
    struct Storage {
        buoys: Map<felt252, BuoyInfo>,
        buoy_count: u32,
    }

    #[derive(Drop, Serde, starknet::Store)]
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
        buoy_id: felt252,
        owner: ContractAddress,
        latitude: felt252,
        longitude: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct DataSubmitted {
        buoy_id: felt252,
        timestamp: u64,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.storage.buoy_count.write(0);
    }

    #[external(v0)]
    fn register_buoy(
        ref self: ContractState,
        buoy_id: felt252,
        lat: felt252,
        lon: felt252
    ) {
        let caller = get_caller_address();
        
        let buoy = BuoyInfo {
            owner: caller,
            latitude: lat,
            longitude: lon,
            is_active: true,
            total_readings: 0,
        };

        self.storage.buoys.write(buoy_id, buoy);
        let count = self.storage.buoy_count.read();
        self.storage.buoy_count.write(count + 1);

        self.emit(BuoyRegistered {
            buoy_id,
            owner: caller,
            latitude: lat,
            longitude: lon,
        });
    }

    #[external(v0)]
    fn submit_data(ref self: ContractState, buoy_id: felt252, timestamp: u64) {
        let mut buoy = self.storage.buoys.read(buoy_id);
        let caller = get_caller_address();
        
        assert(buoy.owner == caller, 'Not buoy owner');
        
        buoy.total_readings += 1;
        self.storage.buoys.write(buoy_id, buoy);

        self.emit(DataSubmitted { buoy_id, timestamp });
    }

    #[external(v0)]
    fn get_buoy_info(self: @ContractState, buoy_id: felt252) -> BuoyInfo {
        self.storage.buoys.read(buoy_id)
    }

    #[external(v0)]
    fn get_total_buoys(self: @ContractState) -> u32 {
        self.storage.buoy_count.read()
    }
}

