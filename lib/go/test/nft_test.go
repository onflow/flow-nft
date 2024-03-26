package test

import (
	//"fmt"
	"testing"

	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
	"github.com/onflow/cadence/runtime/common"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/onflow/flow-nft/lib/go/templates"
)

func TestNFTDeployment(t *testing.T) {
	b, adapter, accountKeys := newTestSetup(t)

	// Create new keys for the NFT contract account
	// and deploy all the NFT contracts
	exampleNFTAccountKey, _ := accountKeys.NewWithSigner()
	_, _, _, _ = deployNFTContracts(t, b, adapter, accountKeys, exampleNFTAccountKey)
}

func TestCreateNFT(t *testing.T) {
	b, adapter, accountKeys := newTestSetup(t)

	// Create new keys for the NFT contract account
	// and deploy all the NFT contracts
	exampleNFTAccountKey, exampleNFTSigner := accountKeys.NewWithSigner()
	nftAddress, metadataAddress, exampleNFTAddress, _ := deployNFTContracts(t, b, adapter, accountKeys, exampleNFTAccountKey)

	const (
		pathName = "exampleNFTCollection"
	)

	t.Run("Should be able to mint a token", func(t *testing.T) {

		// Mint a single NFT with standard royalty cuts and metadata
		mintExampleNFT(t, b,
			accountKeys,
			nftAddress, metadataAddress, exampleNFTAddress,
			exampleNFTAccountKey,
			exampleNFTSigner)

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

		script := templates.GenerateBorrowNFTScript(nftAddress, exampleNFTAddress, metadataAddress)
		executeScriptAndCheck(
			t, b,
			script,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewAddress(exampleNFTAddress)),
				jsoncdc.MustEncode(mintedID),
			},
		)

		assertCollectionLength(t, b, nftAddress, exampleNFTAddress, metadataAddress,
			exampleNFTAddress,
			1,
		)
	})

	t.Run("Shouldn't be able to borrow a reference to an NFT that doesn't exist", func(t *testing.T) {
		script := templates.GenerateBorrowNFTScript(nftAddress, exampleNFTAddress, metadataAddress)

		result, err := b.ExecuteScript(
			script,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewAddress(exampleNFTAddress)),
				jsoncdc.MustEncode(cadence.NewUInt64(5)),
			},
		)
		require.NoError(t, err)

		assert.True(t, result.Reverted())
	})
}

func TestTransferNFT(t *testing.T) {
	b, adapter, accountKeys := newTestSetup(t)

	// Create new keys for the NFT contract account
	// and deploy all the NFT contracts
	exampleNFTAccountKey, exampleNFTSigner := accountKeys.NewWithSigner()
	nftAddress, metadataAddress, exampleNFTAddress, viewResolverAddress := deployNFTContracts(t, b, adapter, accountKeys, exampleNFTAccountKey)

	// Create a new account to test transfers
	joshAddress, _, joshSigner := newAccountWithAddress(b, accountKeys)

	const (
		pathName = "exampleNFTCollection"
	)

	// Mint a single NFT with standard royalty cuts and metadata
	mintExampleNFT(t, b,
		accountKeys,
		nftAddress, metadataAddress, exampleNFTAddress,
		exampleNFTAccountKey,
		exampleNFTSigner)

	// create a new Collection
	t.Run("Should be able to create a new empty NFT Collection", func(t *testing.T) {

		// Setup Account creates an empty NFT collection, stores it in the authorizers account,
		// and creates a public link
		script := templates.GenerateSetupAccountFromAddressScript(nftAddress.String(), metadataAddress.String())
		tx := createTxWithTemplateAndAuthorizer(b, script, joshAddress)

		// Specify ExampleNFT contract address & name
		tx.AddArgument(cadence.NewAddress(exampleNFTAddress))
		tx.AddArgument(cadence.String("ExampleNFT"))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				joshAddress,
			},
			[]crypto.Signer{
				joshSigner,
			},
			false,
		)

		// Make sure that the collection is empty
		assertCollectionLength(t, b, nftAddress, exampleNFTAddress, metadataAddress,
			exampleNFTAddress,
			1,
		)
	})

	t.Run("Shouldn't be able to withdraw an NFT that doesn't exist in a collection", func(t *testing.T) {

		// This transaction tries to withdraw an NFT from a collection
		// and deposit it to another collection
		script := templates.GenerateTransferNFTScript(nftAddress, exampleNFTAddress, metadataAddress, viewResolverAddress)
		tx := createTxWithTemplateAndAuthorizer(b, script, exampleNFTAddress)

		// Specify ExampleNFT contract address & name
		tx.AddArgument(cadence.NewAddress(exampleNFTAddress))
		tx.AddArgument(cadence.String("ExampleNFT"))

		// Transfer it to joshAddress
		tx.AddArgument(cadence.NewAddress(joshAddress))

		// This ID does not exist in the authorizer's collection, so this will fail
		tx.AddArgument(cadence.NewUInt64(3))

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

		// Josh did not receive any, so his collection length should be zero
		assertCollectionLength(t, b, nftAddress, exampleNFTAddress, metadataAddress,
			joshAddress,
			0,
		)

		// The authorizer's transfer failed, so its collection length should still be one
		assertCollectionLength(t, b, nftAddress, exampleNFTAddress, metadataAddress,
			exampleNFTAddress,
			1,
		)
	})

	// Transfer an NFT correctly
	t.Run("Should be able to withdraw an NFT and deposit to another accounts collection", func(t *testing.T) {

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

		// Same transaction as before
		script := templates.GenerateTransferNFTScript(nftAddress, exampleNFTAddress, metadataAddress, viewResolverAddress)
		tx := createTxWithTemplateAndAuthorizer(b, script, exampleNFTAddress)

		// Specify ExampleNFT contract address & name
		tx.AddArgument(cadence.NewAddress(exampleNFTAddress))
		tx.AddArgument(cadence.String("ExampleNFT"))

		// Add the recipient's address
		tx.AddArgument(cadence.NewAddress(joshAddress))
		// The ID does exist in the authorizer's transaction, so the transfer will succeed
		tx.AddArgument(mintedID)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				exampleNFTAddress,
			},
			[]crypto.Signer{
				exampleNFTSigner,
			},
			false,
		)

		verifyWithdrawn(t, b, adapter, nftAddress,
			Withdrawn{
				nftType: "A.e03daebed8ca0615.ExampleNFT.NFT",
				// the rest of the values are not important
				id:           1,
				uuid:         1,
				from:         "",
				providerUuid: 1,
			})

		// Try to borrow a reference to the transferred NFT from josh's account
		// Should succeed
		script = templates.GenerateBorrowNFTScript(nftAddress, exampleNFTAddress, metadataAddress)
		executeScriptAndCheck(
			t, b,
			script,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewAddress(joshAddress)),
				jsoncdc.MustEncode(mintedID),
			},
		)

		// Make sure the new account has an NFT in their collection
		assertCollectionLength(t, b, nftAddress, exampleNFTAddress, metadataAddress,
			joshAddress,
			1,
		)

		// Make sure the old account has none, since they transferred
		assertCollectionLength(t, b, nftAddress, exampleNFTAddress, metadataAddress,
			exampleNFTAddress,
			0,
		)

		// Use the generic transfer transaction with contract address and name
		script = templates.GenerateTransferGenericNFTWithAddressScript(nftAddress.String(), metadataAddress.String())
		tx = createTxWithTemplateAndAuthorizer(b, script, joshAddress)

		// Add the recipient's address
		tx.AddArgument(cadence.NewAddress(exampleNFTAddress))
		// The ID does exist in the authorizer's transaction, so the transfer will succeed
		tx.AddArgument(mintedID)

		// Specify ExampleNFT contract address & name
		tx.AddArgument(cadence.NewAddress(exampleNFTAddress))
		tx.AddArgument(cadence.String("ExampleNFT"))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				joshAddress,
			},
			[]crypto.Signer{
				joshSigner,
			},
			false,
		)

		// Use the generic transfer transaction with paths and name
		// Same transaction as before
		script = templates.GenerateTransferGenericNFTWithPathsScript(nftAddress.String())
		tx = createTxWithTemplateAndAuthorizer(b, script, exampleNFTAddress)

		// Add the recipient's address
		tx.AddArgument(cadence.NewAddress(joshAddress))
		// The ID does exist in the authorizer's transaction, so the transfer will succeed
		tx.AddArgument(mintedID)

		// add path identifier arguments
		tx.AddArgument(cadence.String("exampleNFTCollection"))
		tx.AddArgument(cadence.String("exampleNFTCollection"))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				exampleNFTAddress,
			},
			[]crypto.Signer{
				exampleNFTSigner,
			},
			false,
		)

	})

	t.Run("Should be able to withdraw an NFT and destroy it, not reducing the supply", func(t *testing.T) {

		idsScript := templates.GenerateGetCollectionIDsScript(nftAddress, exampleNFTAddress)
		idsResult := executeScriptAndCheck(
			t, b,
			idsScript,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewAddress(joshAddress)),
				jsoncdc.MustEncode(cadence.Path{Domain: common.PathDomainPublic, Identifier: pathName}),
			},
		)
		mintedID := idsResult.(cadence.Array).Values[0].(cadence.UInt64)

		// This transaction withdraws the specifed NFT from the authorizers account
		// and calls `destroy NFT`
		script := templates.GenerateDestroyNFTScript(nftAddress, exampleNFTAddress, metadataAddress)

		tx := createTxWithTemplateAndAuthorizer(b, script, joshAddress)

		// Destroy the only NFT in the collection
		tx.AddArgument(mintedID)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				joshAddress,
			},
			[]crypto.Signer{
				joshSigner,
			},
			false,
		)

		// Both collections should now be empty since the only NFT was destroyed

		assertCollectionLength(t, b, nftAddress, exampleNFTAddress, metadataAddress,
			joshAddress,
			0,
		)

		assertCollectionLength(t, b, nftAddress, exampleNFTAddress, metadataAddress,
			exampleNFTAddress,
			0,
		)

	})
}
