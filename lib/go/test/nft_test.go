package test

import (
	//"fmt"
	"testing"

	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	//"github.com/onflow/flow-nft/lib/go/contracts"
	"github.com/onflow/flow-nft/lib/go/templates"
)

func TestNFTDeployment(t *testing.T) {
	b, accountKeys := newTestSetup(t)

	// Create new keys for the NFT contract account
	// and deploy all the NFT contracts
	exampleNFTAccountKey, _ := accountKeys.NewWithSigner()
	nftAddress, _, exampleNFTAddress := deployNFTContracts(t, b, exampleNFTAccountKey)

	t.Run("Should have properly initialized fields after deployment", func(t *testing.T) {

		script := templates.GenerateGetTotalSupplyScript(nftAddress, exampleNFTAddress)
		supply := executeScriptAndCheck(t, b, script, nil)
		assert.Equal(t, cadence.NewUInt64(0), supply)

		assertCollectionLength(t, b, nftAddress, exampleNFTAddress,
			exampleNFTAddress,
			0,
		)
	})
}

func TestCreateNFT(t *testing.T) {
	b, accountKeys := newTestSetup(t)

	// Create new keys for the NFT contract account
	// and deploy all the NFT contracts
	exampleNFTAccountKey, exampleNFTSigner := accountKeys.NewWithSigner()
	nftAddress, metadataAddress, exampleNFTAddress := deployNFTContracts(t, b, exampleNFTAccountKey)

	t.Run("Should be able to mint a token", func(t *testing.T) {

		// Mint a single NFT with standard royalty cuts and metadata
		mintExampleNFT(t, b,
			accountKeys,
			nftAddress, metadataAddress, exampleNFTAddress,
			exampleNFTAccountKey,
			exampleNFTSigner)

		script := templates.GenerateBorrowNFTScript(nftAddress, exampleNFTAddress)
		executeScriptAndCheck(
			t, b,
			script,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewAddress(exampleNFTAddress)),
				jsoncdc.MustEncode(cadence.NewUInt64(0)),
			},
		)

		script = templates.GenerateGetTotalSupplyScript(nftAddress, exampleNFTAddress)
		supply := executeScriptAndCheck(t, b, script, nil)
		assert.Equal(t, cadence.NewUInt64(1), supply)

		assertCollectionLength(t, b, nftAddress, exampleNFTAddress,
			exampleNFTAddress,
			1,
		)
	})

	t.Run("Shouldn't be able to borrow a reference to an NFT that doesn't exist", func(t *testing.T) {
		script := templates.GenerateBorrowNFTScript(nftAddress, exampleNFTAddress)

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
	b, accountKeys := newTestSetup(t)

	serviceSigner, _ := b.ServiceKey().Signer()

	// Create new keys for the NFT contract account
	// and deploy all the NFT contracts
	exampleNFTAccountKey, exampleNFTSigner := accountKeys.NewWithSigner()
	nftAddress, metadataAddress, exampleNFTAddress := deployNFTContracts(t, b, exampleNFTAccountKey)

	// Create a new account to test transfers
	joshAddress, _, joshSigner := newAccountWithAddress(b, accountKeys)

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
		script := templates.GenerateSetupAccountScript(nftAddress, exampleNFTAddress, metadataAddress)
		tx := createTxWithTemplateAndAuthorizer(b, script, joshAddress)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				joshAddress,
			},
			[]crypto.Signer{
				serviceSigner,
				joshSigner,
			},
			false,
		)

		// Make sure that the collection is empty
		assertCollectionLength(t, b, nftAddress, exampleNFTAddress,
			exampleNFTAddress,
			1,
		)
	})

	t.Run("Shouldn't be able to withdraw an NFT that doesn't exist in a collection", func(t *testing.T) {

		// This transaction tries to withdraw an NFT from a collection
		// and deposit it to another collection
		script := templates.GenerateTransferNFTScript(nftAddress, exampleNFTAddress)
		tx := createTxWithTemplateAndAuthorizer(b, script, exampleNFTAddress)

		// Transfer it to joshAddress
		tx.AddArgument(cadence.NewAddress(joshAddress))

		// This ID does not exist in the authorizer's collection, so this will fail
		tx.AddArgument(cadence.NewUInt64(3))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				exampleNFTAddress,
			},
			[]crypto.Signer{
				serviceSigner,
				exampleNFTSigner,
			},
			true,
		)

		// Josh did not receive any, so his collection length should be zero
		assertCollectionLength(t, b, nftAddress, exampleNFTAddress,
			joshAddress,
			0,
		)

		// The authorizer's transfer failed, so its collection length should still be one
		assertCollectionLength(t, b, nftAddress, exampleNFTAddress,
			exampleNFTAddress,
			1,
		)
	})

	// Transfer an NFT correctly
	t.Run("Should be able to withdraw an NFT and deposit to another accounts collection", func(t *testing.T) {

		// Same transaction as before
		script := templates.GenerateTransferNFTScript(nftAddress, exampleNFTAddress)
		tx := createTxWithTemplateAndAuthorizer(b, script, exampleNFTAddress)

		tx.AddArgument(cadence.NewAddress(joshAddress))
		// The ID does exist in the authorizer's transaction, so the transfer will succeed
		tx.AddArgument(cadence.NewUInt64(0))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				exampleNFTAddress,
			},
			[]crypto.Signer{
				serviceSigner,
				exampleNFTSigner,
			},
			false,
		)

		// Try to borrow a reference to the transferred NFT from josh's account
		// Should succeed
		script = templates.GenerateBorrowNFTScript(nftAddress, exampleNFTAddress)
		executeScriptAndCheck(
			t, b,
			script,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewAddress(joshAddress)),
				jsoncdc.MustEncode(cadence.NewUInt64(0)),
			},
		)

		// Make sure the new account has an NFT in their collection
		assertCollectionLength(t, b, nftAddress, exampleNFTAddress,
			joshAddress,
			1,
		)

		// Make sure the old account has none, since they transferred
		assertCollectionLength(t, b, nftAddress, exampleNFTAddress,
			exampleNFTAddress,
			0,
		)
	})

	t.Run("Should be able to withdraw an NFT and destroy it, not reducing the supply", func(t *testing.T) {

		// This transaction withdraws the specifed NFT from the authorizers account
		// and calls `destroy NFT`
		script := templates.GenerateDestroyNFTScript(nftAddress, exampleNFTAddress)

		tx := createTxWithTemplateAndAuthorizer(b, script, joshAddress)

		// Destroy the only NFT in the collection
		tx.AddArgument(cadence.NewUInt64(0))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				joshAddress,
			},
			[]crypto.Signer{
				serviceSigner,
				joshSigner,
			},
			false,
		)

		// Both collections should now be empty since the only NFT was destroyed

		assertCollectionLength(t, b, nftAddress, exampleNFTAddress,
			joshAddress,
			0,
		)

		assertCollectionLength(t, b, nftAddress, exampleNFTAddress,
			exampleNFTAddress,
			0,
		)

		// The total Supply should not have decreased, because it is used to make new IDs
		script = templates.GenerateGetTotalSupplyScript(nftAddress, exampleNFTAddress)
		supply := executeScriptAndCheck(t, b, script, nil)
		assert.Equal(t, cadence.NewUInt64(1), supply)
	})
}

// Placeholder test to be used when testing upgrades to the NFT standard
//
// func TestUpgradeNFT(t *testing.T) {
// 	b, accountKeys := newTestSetup(t)

// 	serviceSigner, _ := b.ServiceKey().Signer()

// 	// Create new keys for the NFT contract accounts
// 	// and deploy all the NFT contracts
// 	exampleNFTAccountKey, exampleNFTSigner := accountKeys.NewWithSigner()
// 	NFTAccountKey, NFTSigner := accountKeys.NewWithSigner()

// 	nftAddress := deploy(t, b,
// 		"NonFungibleToken",
// 		contracts.OldNonFungibleToken(),
// 		NFTAccountKey,
// 	)

// 	metadataAddress := deploy(t, b, "MetadataViews", contracts.MetadataViews(flow.HexToAddress(emulatorFTAddress), nftAddress))

// 	exampleNFTAddress := deploy(
// 		t, b,
// 		"ExampleNFT",
// 		contracts.ExampleNFT(nftAddress, metadataAddress),
// 		exampleNFTAccountKey,
// 	)

// 	// Create a new account to test transfers
// 	joshAddress, _, joshSigner := newAccountWithAddress(b, accountKeys)

// 	// Mint a single NFT with standard royalty cuts and metadata
// 	mintExampleNFT(t, b,
// 		accountKeys,
// 		nftAddress, metadataAddress, exampleNFTAddress,
// 		exampleNFTAccountKey,
// 		exampleNFTSigner)

// 	// create a new Collection
// 	script := templates.GenerateSetupAccountScript(nftAddress, exampleNFTAddress, metadataAddress)
// 	tx := createTxWithTemplateAndAuthorizer(b, script, joshAddress)

// 	signAndSubmit(
// 		t, b, tx,
// 		[]flow.Address{
// 			b.ServiceKey().Address,
// 			joshAddress,
// 		},
// 		[]crypto.Signer{
// 			serviceSigner,
// 			joshSigner,
// 		},
// 		false,
// 	)

// 	t.Run("Should be able to upgrade the NFT contract with default implementations and not break", func(t *testing.T) {

// 		// Upgrade the contract
// 		template := `
// 		transaction(code: [UInt8]) {
// 			prepare(acct: AuthAccount) {
// 				acct.contracts.update__experimental(name: "NonFungibleToken", code: code)
// 			}
// 		}
// 		`
// 		transaction := []byte(fmt.Sprintf(template))

// 		newNFTCode := contracts.OldNonFungibleToken()
// 		cadenceCode := bytesToCadenceArray(newNFTCode)

// 		tx := createTxWithTemplateAndAuthorizer(b, transaction, nftAddress)
// 		tx.AddRawArgument(jsoncdc.MustEncode(cadenceCode))

// 		signAndSubmit(
// 			t, b, tx,
// 			[]flow.Address{
// 				b.ServiceKey().Address,
// 				nftAddress,
// 			},
// 			[]crypto.Signer{
// 				serviceSigner,
// 				NFTSigner,
// 			},
// 			false,
// 		)

// 		// Transfer an NFT correctly
// 		script := templates.GenerateTransferNFTScript(nftAddress, exampleNFTAddress)
// 		tx = createTxWithTemplateAndAuthorizer(b, script, exampleNFTAddress)

// 		tx.AddArgument(cadence.NewAddress(joshAddress))
// 		tx.AddArgument(cadence.NewUInt64(0))

// 		signAndSubmit(
// 			t, b, tx,
// 			[]flow.Address{
// 				b.ServiceKey().Address,
// 				exampleNFTAddress,
// 			},
// 			[]crypto.Signer{
// 				serviceSigner,
// 				exampleNFTSigner,
// 			},
// 			false,
// 		)
// 	})

// }
