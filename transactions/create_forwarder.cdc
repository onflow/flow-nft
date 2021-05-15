import NonFungibleToken from 0xNFTADDRESS
import ExampleNFT from 0xNFTCONTRACTADDRESS
import NFTForwarding from 0xNFTFORWARDERADDRESS

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
