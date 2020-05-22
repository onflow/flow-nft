pub contract ExampleNFT {

    pub resource NFT {}

    pub resource Collection {
        pub var ownedNFTs: @{UInt64: NFT}

        init () {
            self.ownedNFTs <- {UInt64(1): <- create NFT()}
        }

        pub fun withdraw(withdrawID: UInt64): @NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")
            return <-token
        }

        pub fun deposit(token: @NFT) {
            let token <- token as! @NFT
            let oldToken <- self.ownedNFTs[UInt64(1)] <- token
            destroy oldToken
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

	init() {
        let collection <- create Collection()

        let token <- collection.withdraw(withdrawID: 1)
        collection.deposit(token: <-token)

        self.account.save(<-collection, to: /storage/NFTCollection)
	}
}

