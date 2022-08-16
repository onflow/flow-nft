/**

## Non-Fungible Token Forwarding Contract

This contract enables a user to designate a recipient to NFTs could be forwarded

The NFTForwarder resource can be referenced just like any NonFungibleToken Receiver,
allowing a sender to deposit NFTs as they usually would

However, in this implementation, any time a deposit is made, the deposited NFT is
additionally deposited to a predefined recipient.

To create an NFTForwarder resource, an account calls the createNewNFTForwarder
function, passing the Receiver Capability to which NFTs will be forwarded. 
 
*/

import FungibleToken from "./FungibleToken.cdc"
import NonFungibleToken from "../NonFungibleToken.cdc"

pub contract NFTForwarding {

    pub event ForwardedNFTDeposit(id: UInt64, from: Address?)
    pub event NFTForwarderRecipientChanged(forwarder: Address?)

    // Canonical Storage and Public paths
    pub let NFTForwarderStoragePath: StoragePath

    pub resource NFTForwarder: NonFungibleToken.Receiver {

        // Recipient to which NFTs will be forwarded
        // 
        access(self) var recipient: Capability

        // deposit
        // 
        // Function that takes NFT resource as argument and deposits it to
        // the designated
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let receiverRef = self.recipient.borrow<&{NonFungibleToken.Receiver}>()!
            let id = token.id

            receiverRef.deposit(token: <-token)

            emit ForwardedNFTDeposit(id: id, from: self.owner?.address)
        }

        // changeRecipient
        // 
        // Function that allows resource owner to change the recipient of
        // forwarded NFTs
        // 
        pub fun changeRecipient(newRecipient: Capability) {
            pre {
                newRecipient.borrow<&{NonFungibleToken.Receiver}>() != nil: "Could not borrow Receiver reference from the given Capability"
            }
            self.recipient = newRecipient
        }

        init(_recipient: Capability) {
            pre {
                _recipient.borrow<&{NonFungibleToken.Receiver}>() != nil: "Could not borrow Receiver reference from the given Capability"
            }
            self.recipient = _recipient
            emit NFTForwarderRecipientChanged(forwarder: self.owner?.address)
        }
    }

    // Creates a new NFTForwarder with the passed recipient capability
    // 
    pub fun createNewNFTForwarder(recipient: Capability): @NFTForwarder {
        return <- create NFTForwarder(_recipient: recipient)
    }

    init() {
        self.NFTForwarderStoragePath = /storage/NFTForwarder
    }

}
