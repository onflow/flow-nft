package contracts

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../contracts -o internal/assets/assets.go -pkg assets -nometadata -nomemcopy ../../../contracts

import (
	"fmt"
	"regexp"

	_ "github.com/kevinburke/go-bindata"

	"github.com/onflow/flow-go-sdk"

	"github.com/onflow/flow-nft/lib/go/contracts/internal/assets"
)

var (
	placeholderNonFungibleToken    = regexp.MustCompile(`"NonFungibleToken"`)
	placeholderMetadataViews       = regexp.MustCompile(`"MetadataViews"`)
	placeholderFungibleToken       = regexp.MustCompile(`"FungibleToken"`)
	placeholderResolver            = regexp.MustCompile(`"ViewResolver"`)
	placeholderNFTMetadataViews    = regexp.MustCompile(`"NFTMetadataViews"`)
	placeholderUniversalCollection = regexp.MustCompile(`"UniversalCollection"`)
)

const (
	filenameNonFungibleToken    = "NonFungibleToken.cdc"
	filenameExampleNFT          = "ExampleNFT.cdc"
	filenameMetadataViews       = "MetadataViews.cdc"
	filenameNFTMetadataViews    = "NFTMetadataViews.cdc"
	filenameViewResolver        = "ViewResolver.cdc"
	filenameUniversalCollection = "UniversalCollection.cdc"
	filenameBasicNFT            = "BasicNFT.cdc"
	filenameFungibleToken       = "utility/FungibleToken.cdc"
)

func withHexPrefix(address string) string {
	if address == "" {
		return ""
	}

	if address[0:2] == "0x" {
		return address
	}

	return fmt.Sprintf("0x%s", address)
}

// NonFungibleToken returns the NonFungibleToken contract interface.
func NonFungibleToken(resolverAddress string) []byte {
	code := assets.MustAssetString(filenameNonFungibleToken)
	code = placeholderResolver.ReplaceAllString(code, withHexPrefix(resolverAddress))
	return []byte(code)
}

// ExampleNFT returns the ExampleNFT contract.
//
// The returned contract will import the NonFungibleToken contract from the specified address.
func ExampleNFT(nftAddress, metadataAddress, resolverAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameExampleNFT)

	code = placeholderNonFungibleToken.ReplaceAllString(code, withHexPrefix(nftAddress.String()))
	code = placeholderMetadataViews.ReplaceAllString(code, withHexPrefix(metadataAddress.String()))
	code = placeholderResolver.ReplaceAllString(code, withHexPrefix(resolverAddress.String()))

	return []byte(code)
}

func MetadataViews(ftAddress, nftAddress, resolverAddress string) []byte {
	code := assets.MustAssetString(filenameMetadataViews)

	code = placeholderFungibleToken.ReplaceAllString(code, withHexPrefix(ftAddress))
	code = placeholderNonFungibleToken.ReplaceAllString(code, withHexPrefix(nftAddress))
	code = placeholderResolver.ReplaceAllString(code, withHexPrefix(resolverAddress))

	return []byte(code)
}

func ViewResolver() []byte {
	code := assets.MustAssetString(filenameViewResolver)
	return []byte(code)
}

func UniversalCollection(nftAddress, resolverAddress, metadataAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameUniversalCollection)
	code = placeholderMetadataViews.ReplaceAllString(code, withHexPrefix(metadataAddress.String()))
	code = placeholderNonFungibleToken.ReplaceAllString(code, withHexPrefix(nftAddress.String()))
	code = placeholderResolver.ReplaceAllString(code, withHexPrefix(resolverAddress.String()))
	return []byte(code)
}

func BasicNFT(nftAddress, resolverAddress, metadataAddress, universalCollectionAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameBasicNFT)
	code = placeholderMetadataViews.ReplaceAllString(code, withHexPrefix(metadataAddress.String()))
	code = placeholderNonFungibleToken.ReplaceAllString(code, withHexPrefix(nftAddress.String()))
	code = placeholderResolver.ReplaceAllString(code, withHexPrefix(resolverAddress.String()))
	code = placeholderUniversalCollection.ReplaceAllString(code, withHexPrefix(universalCollectionAddress.String()))
	return []byte(code)
}

// FungibleToken returns the FungibleToken contract interface.
func FungibleToken() []byte {
	return assets.MustAsset(filenameFungibleToken)
}
