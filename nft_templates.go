package tests

import (
	"fmt"

	"github.com/onflow/flow-go-sdk"
)

// GenerateCreateCollectionScript Creates a script that instantiates a new
// NFT collection instance, stores the collection in memory, then stores a
// reference to the collection.
func GenerateCreateCollectionScript(nftAddr, tokenAddr flow.Address) []byte {
	template := `
		import NonFungibleToken from 0x%s
		import ExampleNFT from 0x%s

		transaction {
		  prepare(acct: AuthAccount) {

			let collection <- ExampleNFT.createEmptyCollection()
			
			acct.save(<-collection, to: /storage/NFTCollection)

			acct.link<&{NonFungibleToken.CollectionPublic}>(/public/NFTCollection, target: /storage/NFTCollection)
		  }
		}
	`

	return []byte(fmt.Sprintf(template, nftAddr, tokenAddr))
}

// GenerateMintNFTScript Creates a script that uses the admin resource
// to mint a new NFT and deposit it into a user's collection
func GenerateMintNFTScript(nftAddr, tokenAddr, receiverAddr flow.Address) []byte {
	template := `
		import NonFungibleToken from 0x%s
		import ExampleNFT from 0x%s

		transaction {
			let minter: &ExampleNFT.NFTMinter
		
			prepare(signer: AuthAccount) {
		
				self.minter = signer.borrow<&ExampleNFT.NFTMinter>(from: /storage/NFTMinter)!
			}
		
			execute {
				let recipient = getAccount(0x%s)
		
				let receiver = recipient
					.getCapability(/public/NFTCollection)!
					.borrow<&{NonFungibleToken.CollectionPublic}>()
					?? panic("Could not get receiver reference to the NFT Collection")
		
				self.minter.mintNFT(recipient: receiver)
			}
		}
	`

	return []byte(fmt.Sprintf(template, nftAddr, tokenAddr, receiverAddr))
}

// GenerateTransferScript creates a script that withdraws an NFT token
// from a collection and deposits it to another collection
func GenerateTransferScript(nftAddr, tokenAddr flow.Address, receiverAddr flow.Address, transferNFTID int) []byte {
	template := `
		import NonFungibleToken from 0x%s
		import ExampleNFT from 0x%s

		transaction {
		  prepare(acct: AuthAccount) {
			let recipient = getAccount(0x%s)

			let collectionRef = acct.borrow<&NonFungibleToken.Collection>(from: /storage/NFTCollection)!
			let depositRef = recipient.getCapability(/public/NFTCollection)!.borrow<&{NonFungibleToken.CollectionPublic}>()!

			let nft <- collectionRef.withdraw(withdrawID: %d)

			depositRef.deposit(token: <-nft)
		  }
		}
	`

	return []byte(fmt.Sprintf(template, nftAddr, tokenAddr, receiverAddr.String(), transferNFTID))
}

// GenerateDestroyScript creates a script that withdraws an NFT token
// from a collection and destroys it
func GenerateDestroyScript(nftAddr, tokenAddr flow.Address, destroyNFTID int) []byte {
	template := `
		import NonFungibleToken from 0x%s
		import ExampleNFT from 0x%s

		transaction {
		  prepare(acct: AuthAccount) {

			let collectionRef = acct.borrow<&NonFungibleToken.Collection>(from: /storage/NFTCollection)!

			let nft <- collectionRef.withdraw(withdrawID: %d)

			destroy nft
		  }
		}
	`

	return []byte(fmt.Sprintf(template, nftAddr, tokenAddr.String(), destroyNFTID))
}

// GenerateInspectCollectionScript creates a script that retrieves an NFT collection
// from storage and tries to borrow a reference for an NFT that it owns.
// If it owns it, it will not fail.
func GenerateInspectCollectionScript(nftAddr, tokenAddr, userAddr flow.Address, nftID int) []byte {
	template := `
		import NonFungibleToken from 0x%s
		import ExampleNFT from 0x%s

		pub fun main() {
			let acct = getAccount(0x%s)
			let collectionRef = acct.getCapability(/public/NFTCollection)!.borrow<&{NonFungibleToken.CollectionPublic}>()
				?? panic("Could not borrow capability from public collection")
			
			let tokenRef = collectionRef.borrowNFT(id: UInt64(%d))
		}
	`

	return []byte(fmt.Sprintf(template, nftAddr, tokenAddr, userAddr, nftID))
}

// GenerateInspectCollectionLenScript creates a script that retrieves an NFT collection
// from storage and tries to borrow a reference for an NFT that it owns.
// If it owns it, it will not fail.
func GenerateInspectCollectionLenScript(nftAddr, tokenAddr, userAddr flow.Address, length int) []byte {
	template := `
		import NonFungibleToken from 0x%s
		import ExampleNFT from 0x%s

		pub fun main() {
			let acct = getAccount(0x%s)
			let collectionRef = acct.getCapability(/public/NFTCollection)!.borrow<&{NonFungibleToken.CollectionPublic}>()
				?? panic("Could not borrow capability from public collection")
			
			if %d != collectionRef.getIDs().length {
				panic("Collection Length is not correct")
			}
		}
	`

	return []byte(fmt.Sprintf(template, nftAddr, tokenAddr, userAddr, length))
}

// GenerateInspectNFTSupplyScript creates a script that reads
// the total supply of tokens in existence
// and makes assertions about the number
func GenerateInspectNFTSupplyScript(nftAddr, tokenAddr flow.Address, expectedSupply int) []byte {
	template := `
		import NonFungibleToken from 0x%s
		import ExampleNFT from 0x%s

		pub fun main() {
			assert(
                ExampleNFT.totalSupply == UInt64(%d),
                message: "incorrect totalSupply!"
            )
		}
	`

	return []byte(fmt.Sprintf(template, nftAddr, tokenAddr, expectedSupply))
}
