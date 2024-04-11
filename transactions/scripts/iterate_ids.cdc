import "NonFungibleToken"

access(all) fun main(ownerAddress: Address, limit: Int): Int {

    let response: [&{NonFungibleToken.NFT}] = []

    let account = getAuthAccount<auth(BorrowValue) &Account>(ownerAddress)

    account.storage.forEachStored(fun (path: StoragePath, type: Type): Bool {

        if !type.isSubtype(of: Type<@{NonFungibleToken.Collection}>()) {

            return true
        }

        let storageCollection = account.storage.borrow<&{NonFungibleToken.Collection}>(from: path)!

        storageCollection.forEachID(fun (nftId: UInt64): Bool {

            let nft = storageCollection.borrowNFT(nftId)!

            response.append(nft)

            return response.length < limit
        })

        return response.length < limit
    })

    return response.length
}