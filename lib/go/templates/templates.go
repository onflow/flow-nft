package templates

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../transactions -o internal/assets/assets.go -pkg assets -nometadata -nomemcopy ../../../transactions

import (
	"fmt"
	"strings"

	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-nft/lib/go/templates/internal/assets"
)

const (
	defaultNFTAddress        = "NFTADDRESS"
	defaultContractAddress   = "NFTCONTRACTADDRESS"
	defaultNFTName           = "ExampleToken"
	defaultNFTStorage        = "NFTCollection"
	createCollectionFilename = "setup_account.cdc"
)

// GenerateCreateCollectionScript Creates a script that instantiates a new
// NFT collection instance, stores the collection in memory, then stores a
// reference to the collection.
func GenerateCreateCollectionScript(nftAddr, tokenAddr, tokenContractName string, storageName string) []byte {
	code := assets.MustAssetString(createCollectionFilename)

	code = strings.ReplaceAll(
		code,
		"0x"+defaultNFTAddress,
		"0x"+nftAddr,
	)

	code = strings.ReplaceAll(
		code,
		"0x"+defaultContractAddress,
		"0x"+tokenAddr,
	)

	code = strings.ReplaceAll(
		code,
		"0x"+defaultNFTName,
		"0x"+tokenContractName,
	)

	code = strings.ReplaceAll(
		code,
		"0x"+defaultNFTStorage,
		"0x"+storageName,
	)

	return []byte(code)
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
func GenerateTransferScript(nftAddr, tokenAddr flow.Address, tokenContractName, storageLocation string, receiverAddr flow.Address, transferNFTID int) []byte {
	template := `
		import NonFungibleToken from 0x%s
		import %s from 0x%s

		transaction {
		  prepare(acct: AuthAccount) {
			let recipient = getAccount(0x%s)

			let collectionRef = acct.borrow<&%s.Collection>(from: /storage/%s)!
			let depositRef = recipient.getCapability(/public/%s)!.borrow<&{NonFungibleToken.CollectionPublic}>()!

			let nft <- collectionRef.withdraw(withdrawID: %d)

			depositRef.deposit(token: <-nft)
		  }
		}
	`

	return []byte(fmt.Sprintf(template, nftAddr, tokenContractName, tokenAddr, receiverAddr.String(), tokenContractName, storageLocation, storageLocation, transferNFTID))
}

// GenerateDestroyScript creates a script that withdraws an NFT token
// from a collection and destroys it
func GenerateDestroyScript(nftAddr, tokenAddr flow.Address, tokenContractName, storageLocation string, destroyNFTID int) []byte {
	template := `
		import NonFungibleToken from 0x%s
		import %s from 0x%s

		transaction {
		  prepare(acct: AuthAccount) {

			let collection <- acct.load<@%s.Collection>(from:/storage/%s)!

			let nft <- collection.withdraw(withdrawID: %d)

			destroy nft
			
			acct.save(<-collection, to: /storage/%s)
		  }
		}
	`

	return []byte(fmt.Sprintf(template, nftAddr, tokenContractName, tokenAddr.String(), tokenContractName, storageLocation, destroyNFTID, storageLocation))
}

// GenerateInspectCollectionScript creates a script that retrieves an NFT collection
// from storage and tries to borrow a reference for an NFT that it owns.
// If it owns it, it will not fail.
func GenerateInspectCollectionScript(nftAddr, tokenAddr, userAddr flow.Address, tokenContractName, storageLocation string, nftID int) []byte {
	template := `
		import NonFungibleToken from 0x%s
		import %s from 0x%s

		pub fun main() {
			let acct = getAccount(0x%s)
			let collectionRef = acct.getCapability(/public/%s)!.borrow<&{NonFungibleToken.CollectionPublic}>()
				?? panic("Could not borrow capability from public collection")
			
			let tokenRef = collectionRef.borrowNFT(id: UInt64(%d))
		}
	`

	return []byte(fmt.Sprintf(template, nftAddr, tokenContractName, tokenAddr, userAddr, storageLocation, nftID))
}

// GenerateInspectCollectionLenScript creates a script that retrieves an NFT collection
// from storage and tries to borrow a reference for an NFT that it owns.
// If it owns it, it will not fail.
func GenerateInspectCollectionLenScript(nftAddr, tokenAddr, userAddr flow.Address, tokenContractName, storageLocation string, length int) []byte {
	template := `
		import NonFungibleToken from 0x%s
		import %s from 0x%s

		pub fun main() {
			let acct = getAccount(0x%s)
			let collectionRef = acct.getCapability(/public/%s)!.borrow<&{NonFungibleToken.CollectionPublic}>()
				?? panic("Could not borrow capability from public collection")
			
			if %d != collectionRef.getIDs().length {
				panic("Collection Length is not correct")
			}
		}
	`

	return []byte(fmt.Sprintf(template, nftAddr, tokenContractName, tokenAddr, userAddr, storageLocation, length))
}

// GenerateInspectNFTSupplyScript creates a script that reads
// the total supply of tokens in existence
// and makes assertions about the number
func GenerateInspectNFTSupplyScript(nftAddr, tokenAddr flow.Address, tokenContractName string, expectedSupply int) []byte {
	template := `
		import NonFungibleToken from 0x%s
		import %s from 0x%s

		pub fun main() {
			assert(
                %s.totalSupply == UInt64(%d),
                message: "incorrect totalSupply!"
            )
		}
	`

	return []byte(fmt.Sprintf(template, nftAddr, tokenContractName, tokenAddr, tokenContractName, expectedSupply))
}
