import NonFungibleToken from 0xNFTADDRESS
import ExampleNFT from 0x0xNFTCONTRACTADDRESS

// This transaction gets the length of an account's nft collection

pub fun main(account: Address): Int {
    let collectionRef = getAccount(account)
        .getCapability(/public/%s)
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")

    return collectionRef.getIDs().length
}
