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
import NonFungibleToken from "NonFungibleToken"

access(all) contract NFTForwarding {

    access(all) entitlement Mutable

    access(all) event ForwardedNFTDeposit(id: UInt64, from: Address?)
    access(all) event UpdatedNFTForwarderRecipient(forwarder: Address?)

    /// Canonical Storage and Public paths
    ///
    access(all) let StoragePath: StoragePath

    /// Resource that forwards deposited NFTs to a designated recipient's Collection
    ///
    access(all) resource NFTForwarder : NonFungibleToken.Collection {

        /// Recipient to which NFTs will be forwarded
        ///
        access(self) var recipient: Capability<&{NonFungibleToken.Collection}>

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
            let id = token.getID()

            recipientRef.deposit(token: <-token)

            emit ForwardedNFTDeposit(id: id, from: self.owner?.address)

        }

        /// Enables reference retrieval of the recipient's Collection or nil
        ///
        /// @return a reference to the recipient's Collection or nil if the Capability is no longer valid
        ///
        access(all) fun borrowRecipientCollection(): &{NonFungibleToken.Collection}? {
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
            emit NFTForwarderRecipientChanged(forwarder: self.owner?.address)
        }

        init(_ recipient: Capability<&{NonFungibleToken.Collection}>) {
            pre {
                recipient.check(): "Could not borrow Collection reference from the given Capability"
            }
            self.recipient = recipient
            emit NFTForwarderRecipientChanged(forwarder: self.owner?.address)
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
