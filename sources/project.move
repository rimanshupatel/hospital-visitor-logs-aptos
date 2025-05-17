module HospitalLogs::VisitorRegistry {
    use std::signer;
    use std::vector;
    use aptos_framework::timestamp;
    
    /// Error codes
    const ENO_ADMIN_PRIVILEGE: u64 = 1;
    const EREGISTRY_ALREADY_EXISTS: u64 = 2;
    const EREGISTRY_NOT_INITIALIZED: u64 = 3;

    /// Struct representing a visitor entry
    struct VisitorLog has store, drop {
        visitor_address: address,
        patient_id: vector<u8>,
        timestamp: u64,
    }

    /// Struct representing the visitor registry
    struct VisitorRegistry has key {
        admin: address,
        logs: vector<VisitorLog>,
    }

    /// Function to initialize the visitor registry
    /// Only hospital admin can initialize this
    public fun initialize_registry(admin: &signer) {
        let admin_addr = signer::address_of(admin);
        
        // Ensure registry doesn't already exist
        assert!(!exists<VisitorRegistry>(admin_addr), EREGISTRY_ALREADY_EXISTS);
        
        // Create and move the registry resource to the admin's account
        let registry = VisitorRegistry {
            admin: admin_addr,
            logs: vector::empty<VisitorLog>(),
        };
        
        move_to(admin, registry);
    }

    /// Function to record a visitor log
    /// Anyone can call this function to register their visit
    public fun record_visit(visitor: &signer, hospital_admin: address, patient_id: vector<u8>) 
        acquires VisitorRegistry 
    {
        // Ensure registry exists
        assert!(exists<VisitorRegistry>(hospital_admin), EREGISTRY_NOT_INITIALIZED);
        
        let visitor_addr = signer::address_of(visitor);
        let registry = borrow_global_mut<VisitorRegistry>(hospital_admin);
        
        // Create visitor log entry
        let log = VisitorLog {
            visitor_address: visitor_addr,
            patient_id,
            timestamp: timestamp::now_seconds(),
        };
        
        // Add log to registry
        vector::push_back(&mut registry.logs, log);
    }
}