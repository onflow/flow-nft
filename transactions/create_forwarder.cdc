import NonFungibleToken from 0xNFTADDRESS
import ExampleNFT from 0xNFTCONTRACTADDRESS
import NFTForwarding from 0xNFTFORWARDERADDRESS

// This transaction creates an NFT forwarder that is saved to the transaction signer's
// account storage. It links the forwarder's public NFTCollection to the forwarder, so
// any future NFTs are sent to the receiver address, the single argument to the 
// transaction.

transaction(receiver: Address) {

    prepare(acct: AuthAccount) {
        let recipient = getAccount(receiver)
            .getCapability<&{NonFungibleToken.CollectionPublic}>(/public/NFTCollection)

        let forwarder <- NFTForwarding.createNewForwarder(recipient: recipient)
        acct.save(<-forwarder, to: /storage/NFTForwarder)

        if acct.getCapability(/public/NFTCollection).check<&{NonFungibleToken.CollectionPublic}>() {
            acct.unlink(/public/NFTCollection)
        }

        acct.link<&{NonFungibleToken.CollectionPublic}>(
            /public/NFTCollection,
            target: /storage/NFTForwarder
        )
    }
}
