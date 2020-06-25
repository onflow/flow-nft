package templates

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../scripts -o internal/assets/assets.go -pkg assets -nometadata -nomemcopy ../../../scripts

import (
	"fmt"

	"github.com/onflow/flow-go-sdk"
)

const (
	readDataFilename = "read_nft_id.cdc"
)

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
