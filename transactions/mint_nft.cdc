import NonFungibleToken from 0xNFTADDRESS
import ExampleNFT from 0xNFTCONTRACTADDRESS


transaction(recipient: Address) {
    
    let minter: &ExampleNFT.NFTMinter

    prepare(signer: AuthAccount) {

        self.minter = signer.borrow<&ExampleNFT.NFTMinter>(from: /storage/NFTMinter)!
    }

    execute {
        let recipient = getAccount(recipient)

        let receiver = recipient
            .getCapability(/public/NFTCollection)!
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        self.minter.mintNFT(recipient: receiver)
    }
}