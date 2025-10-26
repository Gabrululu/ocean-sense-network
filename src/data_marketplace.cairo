// DataMarketplace - Marketplace de datos agregados
// Ocean-Sense Network

use starknet::ContractAddress;
use starknet::get_caller_address;
use starknet::storage::LegacyMap;

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
        package_id: u256
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

#[starknet::contract]
mod DataMarketplace {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    
    #[derive(Serde, starknet::Store)]
    struct DataPackage {
        seller: ContractAddress,
        price: u256,
        data_hash: felt252,  // IPFS hash del dataset
        time_range_start: u64,
        time_range_end: u64,
        area_code: felt252,  // Zona geográfica (e.g., "CALLAO_NORTH")
        is_active: bool,
    }
    
    #[storage]
    struct Storage {
        data_packages: LegacyMap<u256, DataPackage>,
        package_count: u256,
        purchases: LegacyMap<(ContractAddress, u256), bool>, // (buyer, package_id) -> has_access
        purchases_count: LegacyMap<u256, u256>, // Cuántas veces se ha comprado
    }

    #[event]
    #[derive(starknet::Event)]
    enum Event {
        PackageListed: PackageListed,
        PackagePurchased: PackagePurchased,
    }

    #[derive(starknet::Event)]
    struct PackageListed {
        package_id: u256,
        seller: ContractAddress,
        price: u256,
        area: felt252,
    }

    #[derive(starknet::Event)]
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

    #[external(v0)]
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
        self.emit(PackageListed {
            package_id,
            seller: caller,
            price,
            area: area_copy,
        });
        
        package_id
    }

    #[external(v0)]
    fn purchase_data_package(
        ref self: ContractState,
        package_id: u256
    ) {
        let caller = get_caller_address();
    let package = self.data_packages.read(package_id);
        
        assert(package.is_active, 'Package not active');
        
        // Transfer payment to seller
        // TODO: Implementar transfer de tokens ERC20
        // IERC20Dispatcher { contract_address: payment_token }.transfer_from(caller, package.seller, package.price);
        
        // Dar acceso al comprador
    self.purchases.write((caller, package_id), true);

    // Incrementar contador de compras
    let current_count = self.purchases_count.read(package_id);
    self.purchases_count.write(package_id, current_count + 1_u256);
        
        self.emit(PackagePurchased {
            package_id,
            buyer: caller,
            price: package.price,
        });
    }
    
    #[external(v0)]
    fn has_access(
        self: @ContractState,
        buyer: ContractAddress,
        package_id: u256
    ) -> bool {
    self.purchases.read((buyer, package_id))
    }
    
    #[external(v0)]
    fn get_package(
        self: @ContractState,
        package_id: u256
    ) -> DataPackage {
    self.data_packages.read(package_id)
    }
}

