package templates

import (
	"github.com/onflow/flow-go-sdk"

	"github.com/onflow/flow-nft/lib/go/templates/internal/assets"
)

const (
	filenameBorrowNFT           = "scripts/borrow_nft.cdc"
	filenameGetCollectionLength = "scripts/get_collection_length.cdc"
	filenameGetTotalSupply      = "scripts/get_total_supply.cdc"
	filenameGetNFTMetadata      = "scripts/get_nft_metadata.cdc"
	filenameGetNFTView          = "scripts/get_nft_view.cdc"
)

// GenerateBorrowNFTScript creates a script that retrieves an NFT collection
// from storage and tries to borrow a reference for an NFT that it owns.
// If it owns it, it will not fail.
func GenerateBorrowNFTScript(nftAddress, exampleNFTAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameBorrowNFT)
	return replaceAddresses(code, nftAddress, exampleNFTAddress, flow.EmptyAddress, flow.EmptyAddress)
}

// GenerateGetNFTMetadataScript creates a script that returns the metadata for an NFT.
func GenerateGetNFTMetadataScript(nftAddress, exampleNFTAddress, metadataAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameGetNFTMetadata)
	return replaceAddresses(code, nftAddress, exampleNFTAddress, metadataAddress, flow.EmptyAddress)
}

// GenerateGetNFTViewScript creates a script that returns the rollup NFT View for an NFT.
func GenerateGetNFTViewScript(nftAddress, exampleNFTAddress, metadataAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameGetNFTView)
	return replaceAddresses(code, nftAddress, exampleNFTAddress, metadataAddress, flow.EmptyAddress)
}

// GenerateGetCollectionLengthScript creates a script that retrieves an NFT collection
// from storage and tries to borrow a reference for an NFT that it owns.
// If it owns it, it will not fail.
func GenerateGetCollectionLengthScript(nftAddress, exampleNFTAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameGetCollectionLength)
	return replaceAddresses(code, nftAddress, exampleNFTAddress, flow.EmptyAddress, flow.EmptyAddress)
}

// GenerateGetTotalSupplyScript creates a script that reads
// the total supply of tokens in existence
// and makes assertions about the number
func GenerateGetTotalSupplyScript(nftAddress, exampleNFTAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameGetTotalSupply)
	return replaceAddresses(code, nftAddress, exampleNFTAddress, flow.EmptyAddress, flow.EmptyAddress)
}
