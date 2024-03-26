package test

import (
	"testing"

	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
	"github.com/onflow/cadence/runtime/common"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"

	"github.com/onflow/flow-nft/lib/go/templates"
)

func TestSetupRoyaltyReceiver(t *testing.T) {
	b, adapter, accountKeys := newTestSetup(t)

	exampleNFTAccountKey, exampleNFTSigner := accountKeys.NewWithSigner()
	_, metadataAddress, exampleNFTAddress, _ := deployNFTContracts(t, b, adapter, accountKeys, exampleNFTAccountKey)

	t.Run("Should not be able to setup a royalty receiver for a vault that doesn't exist", func(t *testing.T) {

		// This transaction creates a new public link to the specified storage path
		// at a public path determined by the `MetadataViews.getRoyaltyReceiverPublicPath()` function
		// It can be used for any fungible token the beneficiary wants to receive
		script := templates.GenerateSetupAccountToReceiveRoyaltyScript(metadataAddress, flow.HexToAddress(emulatorFTAddress))
		tx := createTxWithTemplateAndAuthorizer(b, script, exampleNFTAddress)

		// Here we use a storage path that points to nothing, so it will fail
		// The positive case is handled in the `mintExampleNFT()` test case
		vaultPath := cadence.Path{Domain: common.PathDomainStorage, Identifier: "missingVault"}
		tx.AddArgument(vaultPath)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				exampleNFTAddress,
			},
			[]crypto.Signer{
				exampleNFTSigner,
			},
			true,
		)
	})
}

func TestSetupCollectionFromNFTReference(t *testing.T) {
	b, adapter, accountKeys := newTestSetup(t)

	// Create a new account to setting up a new account
	aAddress, _, aSigner := newAccountWithAddress(b, accountKeys)

	// Create new keys for the NFT contract account
	// and deploy all the NFT contracts
	exampleNFTAccountKey, exampleNFTSigner := accountKeys.NewWithSigner()
	nftAddress, metadataAddress, exampleNFTAddress, _ := deployNFTContracts(t, b, adapter, accountKeys, exampleNFTAccountKey)

	// Mint a single NFT with standard royalty cuts and metadata
	mintExampleNFT(t, b,
		accountKeys,
		nftAddress, metadataAddress, exampleNFTAddress,
		exampleNFTAccountKey,
		exampleNFTSigner)

	t.Run("Should be able to setup an account using the NFTCollectionData metadata view of a referenced NFT", func(t *testing.T) {
		const (
			pathName = "exampleNFTCollection"
		)

		idsScript := templates.GenerateGetCollectionIDsScript(nftAddress, exampleNFTAddress)
		idsResult := executeScriptAndCheck(
			t, b,
			idsScript,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewAddress(exampleNFTAddress)),
				jsoncdc.MustEncode(cadence.Path{Domain: common.PathDomainPublic, Identifier: pathName}),
			},
		)
		mintedID := idsResult.(cadence.Array).Values[0].(cadence.UInt64)

		script := templates.GenerateSetupAccountFromNftReferenceScript(nftAddress, metadataAddress)
		tx := createTxWithTemplateAndAuthorizer(b, script, aAddress)

		tx.AddArgument(cadence.NewAddress(exampleNFTAddress))
		tx.AddArgument(cadence.Path{Domain: common.PathDomainPublic, Identifier: pathName})
		tx.AddArgument(mintedID)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				aAddress,
			},
			[]crypto.Signer{
				aSigner,
			},
			false,
		)

		assertCollectionLength(t, b, nftAddress, exampleNFTAddress, metadataAddress,
			aAddress,
			0,
		)
	})
}
