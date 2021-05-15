/**

# Non-Fungible Token Forwarding Contract

*/

import NonFungibleToken from 0x02

pub contract NFTForwarding {

    // Event that is emitted when NFTs are forwarded to the target receiver
    pub event ForwardedToken(id: UInt64, from: Address?)

    pub resource Forwarder: NonFungibleToken.Receiver {

        // define where the NFT will be forwarded to
        access(self) var recipient: Capability

        // implement deposit function for Receiver interface
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let receiverRef = self.recipient.borrow<&{NonFungibleToken.Receiver}>()!
            let tokenId = token.id
            receiverRef.deposit(token: <- token)

            emit ForwardedToken(id: tokenId, from: self.owner?.address)
        }

        // changeRecipient allows the forwarding target to be updated
        pub fun changeRecipient(_ newRecipient: Capability) {
            pre {
                newRecipient.borrow<&{NonFungibleToken.Receiver}>() != nil: "Could not borrow Receiver interface from the Capability"
            }
            self.recipient = newRecipient
        }

        init(recipient: Capability) {
            pre {
                recipient.borrow<&{NonFungibleToken.Receiver}>() != nil: "Could not borrow Receiver reference from the Capability"
            }
            self.recipient = recipient
        }
    }

    // createNewForwarder creates a new Forwarder reference with the provided recipient
    pub fun createNewForwarder(recipient: Capability): @Forwarder {
        return <-create Forwarder(recipient: recipient)
    }
}

