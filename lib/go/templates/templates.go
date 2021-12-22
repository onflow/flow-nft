package templates

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../transactions -o internal/assets/assets.go -pkg assets -nometadata -nomemcopy ../../../transactions/...

import (
	"regexp"

	"github.com/onflow/flow-go-sdk"
)

var (
	placeholderNonFungibleToken = regexp.MustCompile(`"[^"\s].*/NonFungibleToken.cdc"`)
	placeholderExampleNFT       = regexp.MustCompile(`"[^"\s].*/ExampleNFT.cdc"`)
	placeholderMetadata         = regexp.MustCompile(`"[^"\s].*/Metadata.cdc"`)
)

func replaceAddresses(code string, nftAddress, exampleNFTAddress, metadataAddress flow.Address) []byte {
	code = placeholderNonFungibleToken.ReplaceAllString(code, "0x"+nftAddress.String())
	code = placeholderExampleNFT.ReplaceAllString(code, "0x"+exampleNFTAddress.String())
	code = placeholderMetadata.ReplaceAllString(code, "0x"+metadataAddress.String())
	return []byte(code)
}
