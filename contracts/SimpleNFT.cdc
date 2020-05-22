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

        destroy() {
            destroy self.ownedNFTs
        }
    }

	init() {
        let collection <- create Collection()
        self.account.save(<-collection, to: /storage/NFTCollection)
	}
}

