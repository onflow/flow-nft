package contracts

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../contracts -o internal/assets/assets.go -pkg assets -nometadata -nomemcopy ../../../contracts

import (
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
	filenameMultipleNFT         = "MultipleNFT.cdc"
	filenameNonFungibleToken    = "NonFungibleToken.cdc"
	filenameExampleNFT          = "ExampleNFT.cdc"
	filenameMetadataViews       = "MetadataViews.cdc"
	filenameNFTMetadataViews    = "NFTMetadataViews.cdc"
	filenameResolver            = "ViewResolver.cdc"
	filenameUniversalCollection = "UniversalCollection.cdc"
	filenameBasicNFT            = "BasicNFT.cdc"
	filenameFungibleToken       = "utility/FungibleToken.cdc"
)

func MultipleNFT(nftAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameMultipleNFT)
	code = placeholderNonFungibleToken.ReplaceAllString(code, "0x"+nftAddress.String())
	return []byte(code)
}

// NonFungibleToken returns the NonFungibleToken contract interface.
func NonFungibleToken(resolverAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameNonFungibleToken)
	code = placeholderResolver.ReplaceAllString(code, "0x"+resolverAddress.String())
	return []byte(code)
}

// NonFungibleToken returns the NonFungibleToken contract interface.
func NonFungibleTokenV2(resolverAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameNonFungibleToken)
	code = placeholderResolver.ReplaceAllString(code, "0x"+resolverAddress.String())
	return []byte(code)
}

// ExampleNFT returns the ExampleNFT contract.
//
// The returned contract will import the NonFungibleToken contract from the specified address.
func ExampleNFT(nftAddress, metadataAddress, resolverAddress, multipleNFTAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameExampleNFT)

	code = placeholderNonFungibleToken.ReplaceAllString(code, "0x"+nftAddress.String())
	code = placeholderMetadataViews.ReplaceAllString(code, "0x"+metadataAddress.String())
	code = placeholderResolver.ReplaceAllString(code, "0x"+resolverAddress.String())

	return []byte(code)
}

func MetadataViews(ftAddress, nftAddress, resolverAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameMetadataViews)

	code = placeholderFungibleToken.ReplaceAllString(code, "0x"+ftAddress.String())
	code = placeholderNonFungibleToken.ReplaceAllString(code, "0x"+nftAddress.String())
	code = placeholderResolver.ReplaceAllString(code, "0x"+resolverAddress.String())

	return []byte(code)
}

func Resolver() []byte {
	code := assets.MustAssetString(filenameResolver)
	return []byte(code)
}

func UniversalCollection(nftAddress, resolverAddress, metadataAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameUniversalCollection)
	code = placeholderMetadataViews.ReplaceAllString(code, "0x"+metadataAddress.String())
	code = placeholderNonFungibleToken.ReplaceAllString(code, "0x"+nftAddress.String())
	code = placeholderResolver.ReplaceAllString(code, "0x"+resolverAddress.String())
	return []byte(code)
}

func BasicNFT(nftAddress, resolverAddress, metadataAddress, universalCollectionAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameBasicNFT)
	code = placeholderMetadataViews.ReplaceAllString(code, "0x"+metadataAddress.String())
	code = placeholderNonFungibleToken.ReplaceAllString(code, "0x"+nftAddress.String())
	code = placeholderResolver.ReplaceAllString(code, "0x"+resolverAddress.String())
	code = placeholderUniversalCollection.ReplaceAllString(code, "0x"+universalCollectionAddress.String())
	return []byte(code)
}

// FungibleToken returns the FungibleToken contract interface.
func FungibleToken() []byte {
	return assets.MustAsset(filenameFungibleToken)
}
