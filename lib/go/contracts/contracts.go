package contracts

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../contracts -o internal/assets/assets.go -pkg assets -nometadata -nomemcopy ../../../contracts

import (
	"strings"

	_ "github.com/kevinburke/go-bindata"

	"github.com/onflow/flow-nft/lib/go/contracts/internal/assets"
)

const (
	nonfungibleTokenFilename       = "NonFungibleToken.cdc"
	exampleNFTFilename             = "ExampleNFT.cdc"
	defaultNonFungibleTokenAddress = "02"
)

// NonFungibleToken returns the NonFungibleToken contract interface.
func NonFungibleToken() []byte {
	return assets.MustAsset(nonfungibleTokenFilename)
}

// ExampleNFT returns the ExampleNFT contract.
//
// The returned contract will import the NonFungibleToken contract from the specified address.
func ExampleNFT(nonfungibleTokenAddr string) []byte {
	code := assets.MustAssetString(exampleNFTFilename)

	code = strings.ReplaceAll(
		code,
		"0x"+defaultNonFungibleTokenAddress,
		"0x"+nonfungibleTokenAddr,
	)

	return []byte(code)
}
