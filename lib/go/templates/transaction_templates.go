package templates

import (
	"github.com/onflow/flow-go-sdk"

	_ "github.com/kevinburke/go-bindata"

	"github.com/onflow/flow-nft/lib/go/templates/internal/assets"
)

const (
	filenameSetupAccount = "setup_account.cdc"
	filenameMintNFT      = "mint_nft.cdc"
	filenameTransferNFT  = "transfer_nft.cdc"
	filenameDestroyNFT   = "destroy_nft.cdc"
	filenameSetupRoyalty = "setup_account_to_receive_royalty.cdc"
)

// GenerateSetupAccountScript returns a script that instantiates a new
// NFT collection instance, saves the collection in storage, then stores a
// reference to the collection.
func GenerateSetupAccountScript(nftAddress, exampleNFTAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameSetupAccount)
	return replaceAddresses(code, nftAddress, exampleNFTAddress, flow.EmptyAddress, flow.EmptyAddress)
}

// GenerateMintNFTScript returns script that uses the admin resource
// to mint a new NFT and deposit it into a user's collection.
func GenerateMintNFTScript(nftAddress, exampleNFTAddress, metadatViewsAddress, ftAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameMintNFT)
	return replaceAddresses(code, nftAddress, exampleNFTAddress, metadatViewsAddress, ftAddress)
}

// GenerateTransferNFTScript returns a script that withdraws an NFT token
// from a collection and deposits it into another collection.
func GenerateTransferNFTScript(nftAddress, exampleNFTAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameTransferNFT)
	return replaceAddresses(code, nftAddress, exampleNFTAddress, flow.EmptyAddress, flow.EmptyAddress)
}

// GenerateDestroyNFTScript creates a script that withdraws an NFT token
// from a collection and destroys it.
func GenerateDestroyNFTScript(nftAddress, exampleNFTAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameDestroyNFT)
	return replaceAddresses(code, nftAddress, exampleNFTAddress, flow.EmptyAddress, flow.EmptyAddress)
}

// GenerateSetupAccountToReceiveRoyaltyScript returns a script that
// links a new royalty receiver interface
func GenerateSetupAccountToReceiveRoyaltyScript(metadatViewsAddress, ftAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameSetupRoyalty)
	return replaceAddresses(code, flow.EmptyAddress, flow.EmptyAddress, metadatViewsAddress, ftAddress)
}
