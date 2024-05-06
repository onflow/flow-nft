package templates

import (
	"github.com/onflow/flow-go-sdk"

	"github.com/onflow/flow-nft/lib/go/templates/internal/assets"
)

const (
	filenameBorrowNFT           = "transactions/scripts/borrow_nft.cdc"
	filenameGetCollectionLength = "transactions/scripts/get_collection_length.cdc"
	filenameGetCollectionIDs    = "transactions/scripts/get_collection_ids.cdc"
	filenameGetTotalSupply      = "transactions/scripts/get_total_supply.cdc"
	filenameGetNFTMetadata      = "transactions/scripts/get_nft_metadata.cdc"
	filenameGetNFTView          = "transactions/scripts/get_nft_view.cdc"
)

// GenerateBorrowNFTScript creates a script that retrieves an NFT collection
// from storage and tries to borrow a reference for an NFT that it owns.
// If it owns it, it will not fail.
func GenerateBorrowNFTScript(nftAddress, exampleNFTAddress, metadataAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameBorrowNFT)
	return replaceAddresses(code, nftAddress, exampleNFTAddress, metadataAddress, flow.EmptyAddress, flow.EmptyAddress)
}

// GenerateGetNFTMetadataScript creates a script that returns the metadata for an NFT.
func GenerateGetNFTMetadataScript(nftAddress, exampleNFTAddress, metadataAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameGetNFTMetadata)
	return replaceAddresses(code, nftAddress, exampleNFTAddress, metadataAddress, flow.EmptyAddress, flow.EmptyAddress)
}

// GenerateGetNFTViewScript creates a script that returns the rollup NFT View for an NFT.
func GenerateGetNFTViewScript(nftAddress, exampleNFTAddress, metadataAddress, viewResolverAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameGetNFTView)
	return replaceAddresses(code, nftAddress, exampleNFTAddress, metadataAddress, flow.EmptyAddress, viewResolverAddress)
}

// GenerateGetCollectionLengthScript creates a script that retrieves an NFT collection
// from storage and tries to borrow a reference for an NFT that it owns.
// If it owns it, it will not fail.
func GenerateGetCollectionLengthScript(nftAddress, exampleNFTAddress, metadataAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameGetCollectionLength)
	return replaceAddresses(code, nftAddress, exampleNFTAddress, metadataAddress, flow.EmptyAddress, flow.EmptyAddress)
}

// GenerateGetCollectionIDsScript creates a script that retrieves an NFT collection
// from storage and retrieves the NFT IDs that it owns.
// If it owns a Collection, it will not fail.
func GenerateGetCollectionIDsScript(nftAddress, exampleNFTAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameGetCollectionIDs)
	return replaceAddresses(code, nftAddress, exampleNFTAddress, flow.EmptyAddress, flow.EmptyAddress, flow.EmptyAddress)
}
