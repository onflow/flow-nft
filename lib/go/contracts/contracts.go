package contracts

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../contracts -o internal/assets/assets.go -pkg assets -nometadata -nomemcopy ../../../contracts

import (
	"regexp"

	_ "github.com/kevinburke/go-bindata"

	"github.com/onflow/flow-go-sdk"

	"github.com/onflow/flow-nft/lib/go/contracts/internal/assets"
)

var (
	placeholderNonFungibleToken   = regexp.MustCompile(`"NonFungibleToken"`)
	placeholderNonFungibleTokenV2 = regexp.MustCompile(`"NonFungibleToken-v2"`)
	placeholderMetadataViews      = regexp.MustCompile(`"MetadataViews"`)
	placeholderFungibleToken      = regexp.MustCompile(`"FungibleToken"`)
	placeholderResolverToken      = regexp.MustCompile(`"ViewResolver"`)
	placeholderNFTMetadataViews   = regexp.MustCompile(`"NFTMetadataViews"`)
	placeholderMultipleNFT        = regexp.MustCompile(`"MultipleNFT"`)
)

const (
	filenameNonFungibleToken    = "NonFungibleToken.cdc"
	filenameNonFungibleTokenV2  = "NonFungibleToken-v2.cdc"
	filenameOldNonFungibleToken = "NonFungibleToken.cdc"
	filenameExampleNFT          = "ExampleNFT-v2.cdc"
	filenameMetadataViews       = "MetadataViews.cdc"
	filenameNFTMetadataViews    = "NFTMetadataViews.cdc"
	filenameResolver            = "ViewResolver.cdc"
	filenameMultipleNFT         = "MultipleNFT.cdc"
	filenameFungibleToken       = "utility/FungibleToken.cdc"
)

// NonFungibleToken returns the NonFungibleToken contract interface.
func NonFungibleToken() []byte {
	code := assets.MustAssetString(filenameNonFungibleTokenV2)
	return []byte(code)
}

// NonFungibleToken returns the NonFungibleToken contract interface.
func NonFungibleTokenV2(resolverAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameNonFungibleToken)
	code = placeholderResolverToken.ReplaceAllString(code, "0x"+resolverAddress.String())
	return []byte(code)
}

// OldNonFungibleToken returns the old NonFungibleToken contract interface
// without default implementations
func OldNonFungibleToken() []byte {
	return assets.MustAsset(filenameOldNonFungibleToken)
}

// ExampleNFT returns the ExampleNFT contract.
//
// The returned contract will import the NonFungibleToken contract from the specified address.
func ExampleNFT(nftAddress, metadataAddress, resolverAddress, multipleNFTAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameExampleNFT)

	code = placeholderNonFungibleTokenV2.ReplaceAllString(code, "0x"+nftAddress.String())
	code = placeholderMetadataViews.ReplaceAllString(code, "0x"+metadataAddress.String())
	code = placeholderResolverToken.ReplaceAllString(code, "0x"+resolverAddress.String())
	code = placeholderMultipleNFT.ReplaceAllString(code, "0x"+multipleNFTAddress.String())

	return []byte(code)
}

func MetadataViews(ftAddress, nftAddress, resolverAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameMetadataViews)

	code = placeholderFungibleToken.ReplaceAllString(code, "0x"+ftAddress.String())
	code = placeholderNonFungibleToken.ReplaceAllString(code, "0x"+nftAddress.String())
	code = placeholderResolverToken.ReplaceAllString(code, "0x"+resolverAddress.String())

	return []byte(code)
}

func Resolver() []byte {
	code := assets.MustAssetString(filenameResolver)
	return []byte(code)
}

func MultipleNFT(nftAddress flow.Address) []byte {
	code := assets.MustAssetString(filenameMultipleNFT)
	code = placeholderNonFungibleTokenV2.ReplaceAllString(code, "0x"+nftAddress.String())
	return []byte(code)
}

// FungibleToken returns the FungibleToken contract interface.
func FungibleToken() []byte {
	return assets.MustAsset(filenameFungibleToken)
}
