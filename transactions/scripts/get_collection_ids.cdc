/// Script to get NFT IDs in an account's collection

import "NonFungibleToken"

access(all) fun main(address: Address, collectionPublicPath: PublicPath): [UInt64] {
    let account = getAccount(address)

    let collectionRef = account.capabilities.borrow<&{NonFungibleToken.Collection}>(
            collectionPublicPath
    ) ?? panic("The account ".concat(address.toString()).concat(" does not have a NonFungibleToken Collection at ")
                .concat(collectionPublicPath.toString())
                .concat("The account must initialize their account with this collection first!"))

    return collectionRef.getIDs()
}
