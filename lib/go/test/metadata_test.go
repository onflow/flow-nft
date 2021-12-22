package test

import (
	"fmt"
	"testing"

	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/onflow/flow-go-sdk/test"
	"github.com/stretchr/testify/assert"

	"github.com/onflow/flow-nft/lib/go/contracts"
	"github.com/onflow/flow-nft/lib/go/templates"
)

func TestGetNFTMetadata(t *testing.T) {
	b := newBlockchain()

	nftAddress := deploy(t, b, "NonFungibleToken", contracts.NonFungibleToken())
	metadataAddress := deploy(t, b, "Metadata", contracts.Metadata())

	accountKeys := test.AccountKeyGenerator()

	exampleNFTAccountKey, exampleNFTSigner := accountKeys.NewWithSigner()
	exampleNFTAddress := deploy(
		t, b, 
		"ExampleNFT", 
		contracts.ExampleNFT(nftAddress, metadataAddress), 
		exampleNFTAccountKey,
	)

	script := templates.GenerateMintNFTScript(nftAddress, exampleNFTAddress)

	tx := createTxWithTemplateAndAuthorizer(b, script, exampleNFTAddress)

	const (
		name = "Example NFT 0"
		description = "This is an example NFT"
		thumbnail = "example.jpeg"
	)
	
	tx.AddArgument(cadence.NewAddress(exampleNFTAddress))
	tx.AddArgument(cadence.String(name))
	tx.AddArgument(cadence.String(description))
	tx.AddArgument(cadence.String(thumbnail))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{
			b.ServiceKey().Address,
			exampleNFTAddress,
		},
		[]crypto.Signer{
			b.ServiceKey().Signer(),
			exampleNFTSigner,
		},
		false,
	)

	script = templates.GenerateGetNFTMetadataScript(nftAddress, exampleNFTAddress, metadataAddress)
	result := executeScriptAndCheck(
		t, b,
		script,
		[][]byte{
			jsoncdc.MustEncode(cadence.NewAddress(exampleNFTAddress)),
			jsoncdc.MustEncode(cadence.NewUInt64(0)),
		},
	)

	nftResult := result.(cadence.Struct)

	nftType := fmt.Sprintf("A.%s.ExampleNFT.NFT", exampleNFTAddress)

	assert.Equal(t, cadence.String(name), nftResult.Fields[0])
	assert.Equal(t, cadence.String(description), nftResult.Fields[1])
	assert.Equal(t, cadence.String(thumbnail), nftResult.Fields[2])
	assert.Equal(t, cadence.NewAddress(exampleNFTAddress), nftResult.Fields[3])
	assert.Equal(t, cadence.String(nftType), nftResult.Fields[4])
}
