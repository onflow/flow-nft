package test

import (
	"encoding/json"
	"fmt"
	"testing"

	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/stretchr/testify/assert"

	"github.com/onflow/flow-nft/lib/go/templates"
)

func TestSetupRoyaltyReceiver(t *testing.T) {
	b, accountKeys := newTestSetup(t)

	exampleNFTAccountKey, exampleNFTSigner := accountKeys.NewWithSigner()
	_, metadataAddress, exampleNFTAddress := deployNFTContracts(t, b, exampleNFTAccountKey)

	t.Run("Should not be able to setup a royalty receiver for a vault that doesn't exist", func(t *testing.T) {

		// This transaction creates a new public link to the specified storage path
		// at a public path determined by the `MetadataViews.getRoyaltyReceiverPublicPath()` function
		// It can be used for any fungible token the beneficiary wants to receive
		script := templates.GenerateSetupAccountToReceiveRoyaltyScript(metadataAddress, flow.HexToAddress(emulatorFTAddress))
		tx := createTxWithTemplateAndAuthorizer(b, script, exampleNFTAddress)

		// Here we use a storage path that points to nothing, so it will fail
		// The positive case is handled in the `mintExampleNFT()` test case
		vaultPath := cadence.Path{Domain: "storage", Identifier: "missingVault"}
		tx.AddArgument(vaultPath)

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
			true,
		)
	})
}

func TestGetNFTMetadata(t *testing.T) {
	b, accountKeys := newTestSetup(t)

	// Create new keys for the NFT contract account
	// and deploy all the NFT contracts
	exampleNFTAccountKey, exampleNFTSigner := accountKeys.NewWithSigner()
	nftAddress, metadataAddress, exampleNFTAddress := deployNFTContracts(t, b, exampleNFTAccountKey)

	// Mint a single NFT with standard royalty cuts and metadata
	mintExampleNFT(t, b,
		accountKeys,
		nftAddress, metadataAddress, exampleNFTAddress,
		exampleNFTAccountKey,
		exampleNFTSigner)

	t.Run("Should be able to verify the metadata of the minted NFT through the Display View", func(t *testing.T) {

		// Run a script to get the Display view for the specified NFT ID
		script := templates.GenerateGetNFTMetadataScript(nftAddress, exampleNFTAddress, metadataAddress)
		result := executeScriptAndCheck(
			t, b,
			script,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewAddress(exampleNFTAddress)),
				jsoncdc.MustEncode(cadence.NewUInt64(0)),
			},
		)

		// Expected metadata
		const (
			name        = "Example NFT 0"
			description = "This is an example NFT"
			thumbnail   = "example.jpeg"
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

		// Unmarshal or Decode the JSON to the interface.
		json.Unmarshal([]byte(royalties), &results)

	})
}
