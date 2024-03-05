package templates

import (
	"fmt"
	"regexp"

	"github.com/onflow/flow-go-sdk"
)

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../ -o internal/assets/assets.go -pkg assets -nometadata -nomemcopy ../../../scripts/... ../../../transactions/...

var (
	placeholderNonFungibleTokenString = "\"NonFungibleToken\""
	placeholderNonFungibleToken       = regexp.MustCompile(`"NonFungibleToken"`)
	placeholderExampleNFT             = regexp.MustCompile(`"ExampleNFT"`)
	placeholderMetadataViews          = regexp.MustCompile(`"MetadataViews"`)
	placeholderMetadataViewsString    = "\"MetadataViews\""
	placeholderFungibleToken          = regexp.MustCompile(`"FungibleToken"`)
	placeholderViewResolver           = regexp.MustCompile(`"ViewResolver"`)
	placeholderFlowToken              = regexp.MustCompile(`"FlowToken"`)
	nonFungibleTokenImport            = "NonFungibleToken from "
	exampleNFTImport                  = "ExampleNFT from "
	metadataViewsImport               = "MetadataViews from "
	fungibleTokenImport               = "FungibleToken from "
	viewResolverImport                = "ViewResolver from "
)

func replaceAddresses(code string, nftAddress, exampleNFTAddress, metadataAddress, ftAddress, viewResolverAddress flow.Address) []byte {
	code = placeholderNonFungibleToken.ReplaceAllString(code, nonFungibleTokenImport+withHexPrefix(nftAddress.String()))
	code = placeholderExampleNFT.ReplaceAllString(code, exampleNFTImport+withHexPrefix(exampleNFTAddress.String()))
	code = placeholderMetadataViews.ReplaceAllString(code, metadataViewsImport+withHexPrefix(metadataAddress.String()))
	code = placeholderFungibleToken.ReplaceAllString(code, fungibleTokenImport+withHexPrefix(ftAddress.String()))
	code = placeholderViewResolver.ReplaceAllString(code, viewResolverImport+withHexPrefix(viewResolverAddress.String()))
	return []byte(code)
}

func withHexPrefix(address string) string {
	if address == "" {
		return ""
	}

	if address[0:2] == "0x" {
		return address
	}

	return fmt.Sprintf("0x%s", address)
}
