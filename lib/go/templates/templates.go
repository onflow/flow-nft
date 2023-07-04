package templates

import (
	"regexp"

	"github.com/onflow/flow-go-sdk"
)

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../ -o internal/assets/assets.go -pkg assets -nometadata -nomemcopy ../../../scripts/... ../../../transactions/...

var (
	placeholderNonFungibleToken = regexp.MustCompile(`"NonFungibleToken"`)
	placeholderExampleNFT       = regexp.MustCompile(`"ExampleNFT"`)
	placeholderMetadataViews    = regexp.MustCompile(`"MetadataViews"`)
	placeholderFungibleToken    = regexp.MustCompile(`"FungibleToken"`)
)

func replaceAddresses(code string, nftAddress, exampleNFTAddress, metadataAddress, ftAddress flow.Address) []byte {
	code = placeholderNonFungibleToken.ReplaceAllString(code, "0x"+nftAddress.String())
	code = placeholderExampleNFT.ReplaceAllString(code, "0x"+exampleNFTAddress.String())
	code = placeholderMetadataViews.ReplaceAllString(code, "0x"+metadataAddress.String())
	code = placeholderFungibleToken.ReplaceAllString(code, "0x"+ftAddress.String())
	return []byte(code)
}
