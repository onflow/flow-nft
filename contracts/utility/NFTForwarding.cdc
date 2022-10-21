/// ## Non-Fungible Token Forwarding Contract
///
/// This contract enables a user to designate a recipient so NFTs could be forwarded
///
/// The NFTForwarder resource can be referenced just like any NonFungibleToken Receiver,
/// allowing a sender to deposit NFTs as they usually would
///
/// However, in this implementation, any time a deposit is made, the deposited NFT is
/// additionally deposited to a predefined recipient.
///
/// To create an NFTForwarder resource, an account calls the createNewNFTForwarder
/// function, passing the Receiver Capability to which NFTs will be forwarded.

import NonFungibleToken from "../NonFungibleToken.cdc"

pub contract NFTForwarding {

    pub event ForwardedNFTDeposit(id: UInt64, from: Address?)
    pub event NFTForwarderRecipientChanged(forwarder: Address?)

    /// Canonical Storage and Public paths
    ///
    pub let StoragePath: StoragePath

    /// Resource that forwards deposited NFTs to a designated
    /// recipient's collection
    ///
    pub resource NFTForwarder: NonFungibleToken.Receiver {

        /// Recipient to which NFTs will be forwarded
        ///
        access(self) var recipient: Capability<&{NonFungibleToken.CollectionPublic}>

        /// Allows for deposits of NFT resources, forwarding
        /// passed deposits to the designated recipient
        /// @param token: NFT to be deposited
        ///
        pub fun deposit(token: @NonFungibleToken.NFT) {
            post {
                recipientRef.getIDs().contains(id): "Could not forward deposited NFT!"
            }

            let recipientRef = self.recipient
                .borrow()
                ?? panic("Could not borrow reference to recipient's Collection!")
            let id = token.id

            recipientRef.deposit(token: <-token)

            emit ForwardedNFTDeposit(id: id, from: self.owner?.address)

        }

        /// Function that allows resource owner to change the recipient of
        /// forwarded NFTs
        /// @param newRecipient: NonFungibleToken.CollectionPublic Capability
        ///
        pub fun changeRecipient(newRecipient: Capability<&{NonFungibleToken.CollectionPublic}>) {
            pre {
                newRecipient.check(): "Could not borrow CollectionPublic reference from the given Capability"
            }

            self.recipient = newRecipient
            emit NFTForwarderRecipientChanged(forwarder: self.owner?.address)
        }

        init(_ recipient: Capability<&{NonFungibleToken.CollectionPublic}>) {
            pre {
                recipient.check(): "Could not borrow CollectionPublic reference from the given Capability"
            }
            self.recipient = recipient
            emit NFTForwarderRecipientChanged(forwarder: self.owner?.address)
        }
    }

    /// Creates a new NFTForwarder with the passed recipient capability
    /// @param recipient: NonFungibleToken.CollectionPublic Capability
    /// @return a new NFTForwarder resource
    ///
    pub fun createNewNFTForwarder(
        recipient: Capability<&{NonFungibleToken.CollectionPublic}>
    ): @NFTForwarder {
        return <- create NFTForwarder(recipient)
    }

    init() {
        self.StoragePath = /storage/ExampleNFTForwarder
    }

}
 