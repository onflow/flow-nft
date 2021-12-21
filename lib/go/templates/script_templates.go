package templates

import (
	"github.com/onflow/flow-go-sdk"

	"github.com/onflow/flow-nft/lib/go/templates/internal/assets"
)

const (
	filenameBorrowNFT           = "scripts/borrow_nft.cdc"
	filenameGetCollectionLength = "scripts/get_collection_length.cdc"
	filenameGetTotalSupply      = "scripts/get_total_supply.cdc"
)

// GenerateBorrowNFTScript creates a script that retrieves an NFT collection
// from storage and tries to borrow a reference for an NFT that it owns.
// If it owns it, it will not fail.
func GenerateBorrowNFTScript(nftAddress, exampleNFTAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameBorrowNFT)
	return replaceAddresses(code, nftAddress, exampleNFTAddress)
}

// GenerateGetCollectionLengthScript creates a script that retrieves an NFT collection
// from storage and tries to borrow a reference for an NFT that it owns.
// If it owns it, it will not fail.
func GenerateGetCollectionLengthScript(nftAddress, exampleNFTAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameGetCollectionLength)
	return replaceAddresses(code, nftAddress, exampleNFTAddress)
}

// GenerateGetTotalSupplyScript creates a script that reads
// the total supply of tokens in existence
// and makes assertions about the number
func GenerateGetTotalSupplyScript(nftAddress, exampleNFTAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameGetTotalSupply)
	return replaceAddresses(code, nftAddress, exampleNFTAddress)
}
