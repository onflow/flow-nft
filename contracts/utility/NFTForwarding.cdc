/// ## Non-Fungible Token Forwarding Contract
///
/// This contract enables a user to designate a recipient so NFTs could be forwarded
///
/// The NFTForwarder resource can be referenced just like any NonFungibleToken Collection,
/// allowing a sender to deposit NFTs as they usually would
///
/// However, in this implementation, any time a deposit is made, the deposited NFT is
/// additionally deposited to a predefined recipient Collection.
///
/// To create an NFTForwarder resource, an account calls the createNewNFTForwarder()
/// function, passing the Collection Capability to which NFTs will be forwarded.
///
import "NonFungibleToken"

access(all) contract NFTForwarding {

    access(all) entitlement Mutable

    access(all) event ForwardedNFTDeposit(id: UInt64, uuid: UInt64, from: Address?, fromUUID: UInt64, to: Address?, toUUID: UInt64)
    access(all) event UpdatedNFTForwarderRecipient(forwarderAddress: Address?, forwarderUUID: UInt64, newRecipientAddress: Address?, newRecipientUUID: UInt64)

    /// Canonical Storage and Public paths
    ///
    access(all) let StoragePath: StoragePath

    /// Resource that forwards deposited NFTs to a designated recipient's Collection
    ///
    access(all) resource NFTForwarder: NonFungibleToken.Receiver {

        /// Recipient to which NFTs will be forwarded
        ///
        access(self) var recipient: Capability<&{NonFungibleToken.Collection}>

        /// getSupportedNFTTypes returns a list of NFT types that this receiver accepts
        access(all) view fun getSupportedNFTTypes(): {Type: Bool} {
            let recipientRef = self.borrowRecipientCollection()
                ?? panic("Could not borrow reference to recipient's Collection!")
            return recipientRef.getSupportedNFTTypes()
        }

        /// Returns whether or not the given type is accepted by the collection
        /// A collection that can accept any type should just return true by default
        access(all) view fun isSupportedNFTType(type: Type): Bool {
           let types = self.getSupportedNFTTypes()
           if let supported = types[type] {
                return supported
           }
           return false
        }

        /// Allows for deposits of NFT resources, forwarding
        /// passed deposits to the designated recipient
        ///
        /// @param token: NFT to be deposited
        ///
        access(all) fun deposit(token: @{NonFungibleToken.NFT}) {
            post {
                recipientRef.getIDs().contains(id): "Could not forward deposited NFT!"
            }

            let recipientRef = self.borrowRecipientCollection()
                ?? panic("Could not borrow reference to recipient's Collection!")
            let id = token.id
            let uuid = token.uuid

            recipientRef.deposit(token: <-token)

            emit ForwardedNFTDeposit(id: id, uuid: uuid, from: self.owner?.address, fromUUID: self.uuid, to: recipientRef.owner?.address, toUUID: recipientRef.uuid)
        }

        /// Enables reference retrieval of the recipient's Collection or nil
        ///
        /// @return a reference to the recipient's Collection or nil if the Capability is no longer valid
        ///
        access(all) view fun borrowRecipientCollection(): &{NonFungibleToken.Collection}? {
            return self.recipient.borrow() ?? nil
        }

        /// Function that allows resource owner to change the recipient of
        /// forwarded NFTs
        ///
        /// @param newRecipient: NonFungibleToken.Collection Capability
        ///
        access(Mutable) fun changeRecipient(_ newRecipient: Capability<&{NonFungibleToken.Collection}>) {
            pre {
                newRecipient.check(): "Could not borrow Collection reference from the given Capability"
            }

            self.recipient = newRecipient
            let recipientRef = self.recipient.borrow()!
            emit UpdatedNFTForwarderRecipient(forwarderAddress: self.owner?.address, forwarderUUID: self.uuid, newRecipientAddress: recipientRef.owner?.address, newRecipientUUID: recipientRef.uuid)
        }

        init(_ recipient: Capability<&{NonFungibleToken.Collection}>) {
            pre {
                recipient.check(): "Could not borrow Collection reference from the given Capability"
            }
            self.recipient = recipient
            let recipientRef = self.recipient.borrow()!
            emit UpdatedNFTForwarderRecipient(forwarderAddress: self.owner?.address, forwarderUUID: self.uuid, newRecipientAddress: recipientRef.owner?.address, newRecipientUUID: recipientRef.uuid)
        }
    }

    /// Creates a new NFTForwarder with the passed recipient capability
    ///
    /// @param recipient: NonFungibleToken.Collection Capability
    /// @return a new NFTForwarder resource
    ///
    access(all) fun createNewNFTForwarder(recipient: Capability<&{NonFungibleToken.Collection}>): @NFTForwarder {
        return <- create NFTForwarder(recipient)
    }

    init() {
        self.StoragePath = /storage/ExampleNFTForwarder
    }

}
