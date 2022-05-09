package test

import (
	"encoding/json"
	"fmt"
	"testing"

	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/onflow/flow-go-sdk/test"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/onflow/flow-nft/lib/go/contracts"
	"github.com/onflow/flow-nft/lib/go/templates"
)

func TestGetNFTMetadata(t *testing.T) {
	b := newBlockchain()

	nftAddress := deploy(t, b, "NonFungibleToken", contracts.NonFungibleToken())
	metadataAddress := deploy(t, b, "MetadataViews", contracts.MetadataViews())

	accountKeys := test.AccountKeyGenerator()

	exampleNFTAccountKey, exampleNFTSigner := accountKeys.NewWithSigner()
	exampleNFTAddress := deploy(
		t, b,
		"ExampleNFT",
		contracts.ExampleNFT(nftAddress, metadataAddress),
		exampleNFTAccountKey,
	)

	script := templates.GenerateMintNFTScript(nftAddress, exampleNFTAddress, metadataAddress)

	beneficiaryAccountKey1, _ := accountKeys.NewWithSigner()
	beneficiaryAddress1, err := b.CreateAccount([]*flow.AccountKey{beneficiaryAccountKey1}, nil)
	require.NoError(t, err)
	beneficiaryAccountKey2, _ := accountKeys.NewWithSigner()
	beneficiaryAddress2, err := b.CreateAccount([]*flow.AccountKey{beneficiaryAccountKey2}, nil)
	require.NoError(t, err)

	tx := createTxWithTemplateAndAuthorizer(b, script, exampleNFTAddress)

	const (
		name        = "Example NFT 0"
		description = "This is an example NFT"
		thumbnail   = "example.jpeg"
		externalURL = "https://example-nft.onflow.org/0"
	)

	// Add two new royalties to the minted NFT
	cut1, err := cadence.NewUFix64("0.25")
	require.NoError(t, err)
	cut2, err := cadence.NewUFix64("0.40")
	require.NoError(t, err)

	cuts := []cadence.Value{cut1, cut2}
	royaltyDescriptions := []cadence.Value{cadence.String("Minter royalty"), cadence.String("Creator royalty")}
	royaltyBeneficiaries := []cadence.Value{cadence.NewAddress(beneficiaryAddress1), cadence.NewAddress(beneficiaryAddress2)}

	tx.AddArgument(cadence.NewAddress(exampleNFTAddress))
	tx.AddArgument(cadence.String(name))
	tx.AddArgument(cadence.String(description))
	tx.AddArgument(cadence.String(thumbnail))
	tx.AddArgument(cadence.NewArray(cuts))
	tx.AddArgument(cadence.NewArray(royaltyDescriptions))
	tx.AddArgument(cadence.NewArray(royaltyBeneficiaries))

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

	// TODO: To verify the return data from the script with the expected data.
	royalties := toJson(t, nftResult.Fields[5])
	// Declared an empty interface of type Array
	var results map[string]interface{}

	assert.Equal(t, cadence.String(externalURL), nftResult.Fields[6])

	const (
		collectionName        = "The Example Collection"
		collectionDescription = "This collection is used as an example to help you develop your next Flow NFT."
		collectionImage       = "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg"
		collectionExternalURL = "https://example-nft.onflow.org"
	)

	assert.Equal(t, cadence.String(collectionName), nftResult.Fields[7])
	assert.Equal(t, cadence.String(collectionDescription), nftResult.Fields[8])
	assert.Equal(t, cadence.String(collectionExternalURL), nftResult.Fields[9])
	assert.Equal(t, cadence.String(collectionImage), nftResult.Fields[10])
	assert.Equal(t, cadence.String(collectionImage), nftResult.Fields[11])

	// Unmarshal or Decode the JSON to the interface.
	json.Unmarshal([]byte(royalties), &results)
}
