// This is an example implementation of a Flow Non-Fungible Token
// It is not part of the official standard but it assumed to be
// very similar to how many NFTs would implement the core functionality.

import NonFungibleToken from 0x02

pub contract ExampleNFT {

    pub resource NFT {
        pub let id: UInt64

        init(initID: UInt64) {
            self.id = initID
        }
    }

    pub resource Collection {
        pub var ownedNFTs: @{UInt64: NFT}

        init () {
            self.ownedNFTs <- {}
        }

        pub fun withdraw(withdrawID: UInt64): @NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            return <-token
        }

        pub fun deposit(token: @NFT) {
            let token <- token as! @ExampleNFT.NFT

            let id: UInt64 = token.id

            let oldToken <- self.ownedNFTs[id] <- token

            destroy oldToken
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

	init() {
        let collection <- create Collection()

        var newNFT <- create NFT(initID: 1)

        collection.deposit(token: <-newNFT)

        self.account.save(<-collection, to: /storage/NFTCollection)
	}
}

