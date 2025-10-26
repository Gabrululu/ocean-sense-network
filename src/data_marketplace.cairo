// Archivo: src/data_marketplace.cairo
#[starknet::contract]
mod data_marketplace {    
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::Map;
    use core::serde::Serde;

    #[derive(Serde, starknet::Store, Drop, Copy)] 
    struct DataPackage {
        seller: ContractAddress,
        price: u256,
        data_hash: felt252, 
        time_range_start: u64,
        time_range_end: u64,
        area_code: felt252, 
        is_active: bool,
    }

    #[starknet::interface]
    trait IERC20<TContractState> {
        fn transfer_from(
            ref self: TContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool;
    }

    #[starknet::interface]
    trait IDataMarketplace<TContractState> {
        fn list_data_package(
            ref self: TContractState,
            price: u256,
            data_hash: felt252,
            time_start: u64,
            time_end: u64,
            area: felt252
        ) -> u256;
        
        fn purchase_data_package(
            ref self: TContractState,
            package_id: u256,
            payment_token: ContractAddress
        );
        
        fn has_access(
            self: @TContractState,
            buyer: ContractAddress,
            package_id: u256
        ) -> bool;
        
        fn get_package(
            self: @TContractState,
            package_id: u256
        ) -> DataPackage;
    }

    #[storage]
    struct Storage {
        data_packages: Map<u256, DataPackage>,
        package_count: u256,
        purchases: Map<(ContractAddress, u256), bool>,
        purchases_count: Map<u256, u256>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        PackageListed: PackageListed,
        PackagePurchased: PackagePurchased,
    }

    #[derive(Drop, starknet::Event)] 
    struct PackageListed {
        package_id: u256,
        seller: ContractAddress,
        price: u256,
        area: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct PackagePurchased {
        package_id: u256,
        buyer: ContractAddress,
        price: u256,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState
    ) {
        self.package_count.write(0_u256);
    }

    #[abi(embed_v0)] 
    impl DataMarketplaceImpl of IDataMarketplace<ContractState> {
        fn list_data_package(
            ref self: ContractState,
            price: u256,
            data_hash: felt252,
            time_start: u64,
            time_end: u64,
            area: felt252
        ) -> u256 {
            let caller = get_caller_address();
            let package_id = self.package_count.read() + 1_u256;
            
            let package = DataPackage {
                seller: caller,
                price,
                data_hash,
                time_range_start: time_start,
                time_range_end: time_end,
                area_code: area,
                is_active: true,
            };
            
            self.data_packages.write(package_id, package);
            self.package_count.write(package_id);
            
            let area_copy = area;
            self.emit(Event::PackageListed(PackageListed {
                package_id,
                seller: caller,
                price,
                area: area_copy,
            }));
            
            package_id
        }

        fn purchase_data_package(
            ref self: ContractState,
            package_id: u256,
            payment_token: ContractAddress
        ) {
            let caller = get_caller_address();
            let package = self.data_packages.read(package_id);
            
            assert(package.is_active, 'Package not active');
            
            // let token_dispatcher = IERC20Dispatcher { contract_address: payment_token };
            // token_dispatcher.transfer_from(caller, package.seller, package.price);
            
            self.purchases.write((caller, package_id), true);

            let current_count = self.purchases_count.read(package_id);
            self.purchases_count.write(package_id, current_count + 1_u256);
            
            self.emit(Event::PackagePurchased(PackagePurchased {
                package_id,
                buyer: caller,
                price: package.price,
            }));
        }
        
        fn has_access(
            self: @ContractState,
            buyer: ContractAddress,
            package_id: u256
        ) -> bool {
            self.purchases.read((buyer, package_id))
        }
        
        fn get_package(
            self: @ContractState,
            package_id: u256
        ) -> DataPackage {
            self.data_packages.read(package_id)
        }
    }
}
