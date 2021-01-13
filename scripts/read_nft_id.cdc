import NonFungibleToken from 0xNFTADDRESS
import ExampleNFT from 0xNFTCONTRACTADDRESS

// This script reads metadata about an NFT in a user's collection
pub fun main(account: Address): UInt64 {

    // Get the public collection of the owner of the token
    let collectionRef = getAccount(account)
        .getCapability(/public/NFTCollection)
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")

    // Borrow a reference to a specific NFT in the collection
    let nft = collectionRef.borrowNFT(id: 1)

    return nft.id
}