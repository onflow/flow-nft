import "ViewResolver"
import "EVM"

/// This contract implements views originally proposed in FLIP-318 supporting NFT collections
/// with project-defined implementations across both Cadence & EVM.
/// The View structs in this contract should be implemented in the same way that views from `MetadataViews` are implemented
/// 
access(all) contract CrossVMMetadataViews {

    /// An enum denoting a VM. For now, there are only two VMs on Flow, but this enum could be
    /// expanded in the event other VMs are supported on the network.
    ///
    access(all) enum VM : UInt8 {
        access(all) case Cadence
        access(all) case EVM
    }

    /// View resolved at contract & resource level pointing to the associated EVM implementation.
    /// NOTE: This view alone is not sufficient to validate an association across Cadence & EVM!
    /// Both the Cadence Type/contract *and* the EVM contract should point to each other, with the
    /// EVM pointer being facilitated by ICrossVM.sol contract interface methods. For more
    /// information and context, see FLIP-318: https://github.com/onflow/flips/issues/318
    ///
    access(all) struct EVMPointer {
        /// The associated Cadence Type defined in the contract that this view is returned from
        access(all) let cadenceType: Type
        /// The defining Cadence contract address
        access(all) let cadenceContractAddress: Address
        /// The associated EVM contract address that the Cadence contract will bridge to
        access(all) let evmContractAddress: EVM.EVMAddress
        /// Whether the asset is Cadence- or EVM-native. Native here meaning the VM in which the
        /// asset is originally distributed.
        access(all) let nativeVM: VM

        init(
            cadenceType: Type,
            cadenceContractAddress: Address,
            evmContractAddress: EVM.EVMAddress,
            nativeVM: VM
        ) {
            self.cadenceType = cadenceType
            self.cadenceContractAddress = cadenceContractAddress
            self.evmContractAddress = evmContractAddress
            self.nativeVM = nativeVM
        }
    }

    access(all) fun getEVMPointer(_ viewResolver: &{ViewResolver.Resolver}): EVMPointer? {
        if let view = viewResolver.resolveView(Type<EVMPointer>()) {
            if let v = view as? EVMPointer {
                return v
            }
        }
        return nil
    }

    /// View resolved at resource level denoting any metadata to be passed to the associated EVM
    /// contract at the time of bridging. This optional view would allow EVM side metadata to be
    /// updated based on current Cadence state. If the view is not supported, no bytes will be
    /// passed into EVM when bridging.
    ///
    access(all) struct EVMBytesMetadata {
        /// Returns the bytes to be passed to the EVM contract on `fulfillToEVM` call, allowing the
        /// EVM contract to update the metadata associated with the NFT. The corresponding Solidity
        /// `bytes` type allows the implementer greater flexibility by enabling them to pass
        /// arbitrary data between VMs.
        access(all) let bytes: EVM.EVMBytes

        init(bytes: EVM.EVMBytes) {
            self.bytes = bytes
        }
    }

    access(all) fun getEVMBytesMetadata(_ viewResolver: &{ViewResolver.Resolver}): EVMBytesMetadata? {
        if let view = viewResolver.resolveView(Type<EVMBytesMetadata>()) {
            if let v = view as? EVMBytesMetadata {
                return v
            }
        }
        return nil
    }

}
