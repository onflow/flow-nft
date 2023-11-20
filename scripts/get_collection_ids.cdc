/// Script to get NFT IDs in an account's collection

import "NonFungibleToken"
import "ExampleNFT"

access(all) fun main(address: Address, collectionPublicPath: PublicPath): [UInt64] {
    let account = getAccount(address)

    let collectionRef = account.capabilities.borrow<&{NonFungibleToken.Collection}>(
            collectionPublicPath
        ) ?? panic("Could not borrow capability from collection at specified path")

    return collectionRef.getIDs()
}
