import NonFungibleToken from 0xNFTADDRESS
import ExampleNFT from 0xNFTCONTRACTADDRESS

// This transaction is for transferring and NFT from 
// one account to another

transaction(recipient: Address, withdrawID: UInt64) {
    prepare(acct: AuthAccount) {
        
        // get the recipients public account object
        let recipient = getAccount(recipient)

        // borrow a reference to the signer's NFT collection
        let collectionRef = acct.borrow<&ExampleNFT.Collection>(from: /storage/NFTCollection)
            ?? panic("Could not borrow a reference to the owner's collection")

        // borrow a public reference to the receivers collection
        let depositRef = recipient.getCapability(/public/NFTCollection)!.borrow<&{NonFungibleToken.CollectionPublic}>()!

        // withdraw the NFT from the owner's collection
        let nft <- collectionRef.withdraw(withdrawID: withdrawID)

        // Deposit the NFT in the recipient's collection
        depositRef.deposit(token: <-nft)
    }
}