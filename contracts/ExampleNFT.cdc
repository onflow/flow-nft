// This is an example implementation of the NFT Standard

import NonFungibleToken from 0x01

pub contract ExampleNFT: NonFungibleToken {

    pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64

        pub var metadata: {String: String}

        init(initID: UInt64) {
            self.id = initID
            self.metadata = {}
        }
    }

    // This interface would be if someone wanted to expose the borrowNFT
    // function in their collection so that others could read the metadata
    // of specific NFTs in the Collection
    pub resource interface CollectionBorrow {
        pub fun borrowNFT(id: UInt64): &NFT
    }

    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NFT}

        init () {
            self.ownedNFTs <- {}
        }

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        pub fun batchWithdraw(ids: [UInt64]): @Collection {
            let batchCollection <- create Collection()

            for id in ids {
                let nft <- self.withdraw(withdrawID: id)
                batchCollection.deposit(token: <-nft)
            }

            return <-batchCollection
        }

        // deposit takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @NFT) {
            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        pub fun batchDeposit(tokens: @Collection) {
            for id in tokens.getIDs() {
                let nft <- tokens.withdraw(withdrawID: id)
                self.deposit(token: <-nft)
            }
            destroy tokens
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &NFT {
            return &self.ownedNFTs[id] as &NFT
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    // public function that anyone can call to create a new empty collection
    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
	pub resource NFTMinter {

		// mintNFT mints a new NFT with a new ID
		// and deposit it in the recipients collection using their collection reference
		pub fun mintNFT(recipient: &{NonFungibleToken.Receiver}) {

			// create a new NFT
			var newNFT <- create NFT(initID: ExampleNFT.totalSupply)

			// deposit it in the recipient's account using their reference
			recipient.deposit(token: <-newNFT)

            ExampleNFT.totalSupply = ExampleNFT.totalSupply + UInt64(1)
		}
	}

	init() {
        // Initialize the total supply
        self.totalSupply = 0

        // Create a Collection resource and save it to storage
        let collection <- create Collection()
        self.account.save(<-collection, to: /storage/NFTCollection)

        // create a public capability for the collection
        self.account.link<&{NonFungibleToken.Receiver, CollectionBorrow}>(
            /public/NFTReceiver,
            target: /storage/NFTCollection
        )

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: /storage/NFTMinter)

        emit ContractInitialized()
	}
}

