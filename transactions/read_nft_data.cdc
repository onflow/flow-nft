import NonFungibleToken from 0x01
import ExampleNFT from 0x02

// This script reads metadata about an NFT in a user's collection
pub fun main() {

    // Get the public account object of the owner of the token
    let owner = getAccount(0x01)

    // Get the Collection reference for the owner's collection by
    // getting the public capability and borrowing a reference from it
    // as `CollectionBorrow`, which has the `borrowNFT` function
    //
    let collectionBorrow = owner
        .getCapability(/public/NFTReceiver)!
        .borrow<&{ExampleNFT.CollectionBorrow}>()!

    // Borrow a reference to a specific NFT in the collection
    let nft = collectionBorrow.borrowNFT(id: 1)

    // Log the metadata of the token
    log(nft.id)
    log(nft.metadata)
}