import NonFungibleToken from 0xNFTADDRESS
import ExampleNFT from 0xNFTCONTRACTADDRESS

transaction(recipient: Address, withdrawID: UInt64) {
    prepare(acct: AuthAccount) {
        let recipient = getAccount(recipient)

        let collectionRef = acct.borrow<&ExampleNFT.Collection>(from: /storage/NFTCollection)!
        let depositRef = recipient.getCapability(/public/NFTCollection)!.borrow<&{NonFungibleToken.CollectionPublic}>()!

        let nft <- collectionRef.withdraw(withdrawID: withdrawID)

        depositRef.deposit(token: <-nft)
    }
}