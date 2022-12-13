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

		serviceSigner, _ := b.ServiceKey().Signer()

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

	t.Run("Should be able to verify the metadata of the minted NFT", func(t *testing.T) {

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
			externalURL = "https://example-nft.onflow.org/0"
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

		// Verify external URL view result is as expected
		assert.Equal(t, cadence.String(externalURL), nftResult.Fields[6])

		// Assert that the serial number is correct
		assert.Equal(t, cadence.NewUInt64(0), nftResult.Fields[7])

		// Verify NFTCollectionData results are as expected
		const (
			pathName                = "exampleNFTCollection"
			collectionType          = "A.f3fcd2c1a78f5eee.ExampleNFT.Collection"
			collectionPublicType    = "A.f3fcd2c1a78f5eee.ExampleNFT.ExampleNFTCollectionPublic"
			nftCollectionPublicType = "A.01cf0e2f2f715450.NonFungibleToken.CollectionPublic"
			nftReceiverType         = "A.01cf0e2f2f715450.NonFungibleToken.Receiver"
			resolverCollectionType  = "A.179b6b1cb6755e31.MetadataViews.ResolverCollection"
			providerType            = "A.01cf0e2f2f715450.NonFungibleToken.Provider"
		)
		assert.Equal(t, cadence.Path{Domain: "public", Identifier: pathName}, nftResult.Fields[8])
		assert.Equal(t, cadence.Path{Domain: "storage", Identifier: pathName}, nftResult.Fields[9])
		assert.Equal(t, cadence.Path{Domain: "private", Identifier: pathName}, nftResult.Fields[10])
		assert.Equal(t, cadence.String(fmt.Sprintf("&%s{%s}", collectionType, collectionPublicType)), nftResult.Fields[11])
		assert.Equal(t, cadence.String(fmt.Sprintf("&%s{%s,%s,%s,%s}", collectionType, collectionPublicType, nftCollectionPublicType, nftReceiverType, resolverCollectionType)), nftResult.Fields[12])
		assert.Equal(t, cadence.String(fmt.Sprintf("&%s{%s,%s,%s,%s}", collectionType, collectionPublicType, nftCollectionPublicType, providerType, resolverCollectionType)), nftResult.Fields[13])

		// Verify NFTCollectionDisplay results are as expected
		const (
			collectionName        = "The Example Collection"
			collectionDescription = "This collection is used as an example to help you develop your next Flow NFT."
			collectionImage       = "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg"
			collectionExternalURL = "https://example-nft.onflow.org"
		)
		assert.Equal(t, cadence.String(collectionName), nftResult.Fields[14])
		assert.Equal(t, cadence.String(collectionDescription), nftResult.Fields[15])
		assert.Equal(t, cadence.String(collectionExternalURL), nftResult.Fields[16])
		assert.Equal(t, cadence.String(collectionImage), nftResult.Fields[17])
		assert.Equal(t, cadence.String(collectionImage), nftResult.Fields[18])

		// TODO: Verify `nftResult.Fields[19]` is equal to a {String: String} dictionary
		// with key `twitter` and value `https://twitter.com/flow_blockchain`

		// Verify Edition results are as expected
		const (
			editionName = "Example NFT Edition"
			editionNum  = 0
		)
		expectedName, _ := cadence.NewString(editionName)
		assert.Equal(t, cadence.NewOptional(expectedName), nftResult.Fields[20].(cadence.Struct).Fields[0])
		assert.Equal(t, cadence.NewUInt64(editionNum), nftResult.Fields[20].(cadence.Struct).Fields[1])
		assert.Equal(t, cadence.NewOptional(nil), nftResult.Fields[20].(cadence.Struct).Fields[2])

		minterName, _ := cadence.NewString("minter")

		traitsView := nftResult.Fields[21].(cadence.Struct)
		traits := traitsView.Fields[0].(cadence.Array)

		blockNumberName, _ := cadence.NewString("mintedBlock")
		blockNumberTrait := traits.Values[0].(cadence.Struct)
		assert.Equal(t, blockNumberName, blockNumberTrait.Fields[0])
		assert.Equal(t, cadence.NewUInt64(13), blockNumberTrait.Fields[1])
		assert.Equal(t, cadence.NewOptional(nil), blockNumberTrait.Fields[2])
		assert.Equal(t, cadence.NewOptional(nil), blockNumberTrait.Fields[3])

		mintTrait := traits.Values[1].(cadence.Struct)
		assert.Equal(t, minterName, mintTrait.Fields[0])
		assert.Equal(t, fmt.Sprintf("0x%s", exampleNFTAddress.String()), mintTrait.Fields[1].String())
		assert.Equal(t, cadence.NewOptional(nil), mintTrait.Fields[2])
		assert.Equal(t, cadence.NewOptional(nil), mintTrait.Fields[3])

		mintedTimeName, _ := cadence.NewString("mintedTime")
		mintedTimeDisplayType, _ := cadence.NewString("Date")
		mintedTimeTrait := traits.Values[2].(cadence.Struct)
		assert.Equal(t, mintedTimeName, mintedTimeTrait.Fields[0])
		assert.Equal(t, cadence.NewOptional(mintedTimeDisplayType), mintedTimeTrait.Fields[2])

		fooName, _ := cadence.NewString("foo")
		fooValue, _ := cadence.NewString("bar")
		fooTrait := traits.Values[3].(cadence.Struct)
		fooRarityOptional := fooTrait.Fields[3].(cadence.Optional)
		fooRarity := fooRarityOptional.Value.(cadence.Struct)
		rarityDescription, _ := cadence.NewString("Common")
		assert.Equal(t, fooName, fooTrait.Fields[0])
		assert.Equal(t, cadence.NewOptional(fooValue), fooTrait.Fields[1])
		fooRarityScore := fooRarity.Fields[0].(cadence.Optional).Value
		score, _ := cadence.NewUFix64("10.0")
		assert.Equal(t, fooRarityScore, score)
		fooRarityMax := fooRarity.Fields[1].(cadence.Optional).Value
		max, _ := cadence.NewUFix64("100.0")
		assert.Equal(t, max, fooRarityMax)
		assert.Equal(t, fooRarity.Fields[2], cadence.NewOptional(rarityDescription))
	})
}

func TestGetNFTView(t *testing.T) {
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

	t.Run("Should be able to verify the nft metadata view of the minted NFT", func(t *testing.T) {

		// Run a script to get the Display view for the specified NFT ID
		script := templates.GenerateGetNFTViewScript(nftAddress, exampleNFTAddress, metadataAddress)
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
			externalURL = "https://example-nft.onflow.org/0"
		)

		nftResult := result.(cadence.Struct)

		assert.Equal(t, cadence.NewUInt64(0), nftResult.Fields[0])
		assert.Equal(t, cadence.String(name), nftResult.Fields[2])
		assert.Equal(t, cadence.String(name), nftResult.Fields[2])
		assert.Equal(t, cadence.String(description), nftResult.Fields[3])
		assert.Equal(t, cadence.String(thumbnail), nftResult.Fields[4])

		royalties := toJson(t, nftResult.Fields[5])
		// Declared an empty interface of type Array
		var results map[string]interface{}

		// Unmarshal or Decode the JSON to the interface.
		json.Unmarshal([]byte(royalties), &results)

		// Verify external URL view result is as expected
		assert.Equal(t, cadence.String(externalURL), nftResult.Fields[6])

		// Verify NFTCollectionData results are as expected
		const (
			pathName                = "exampleNFTCollection"
			collectionType          = "A.f3fcd2c1a78f5eee.ExampleNFT.Collection"
			collectionPublicType    = "A.f3fcd2c1a78f5eee.ExampleNFT.ExampleNFTCollectionPublic"
			nftCollectionPublicType = "A.01cf0e2f2f715450.NonFungibleToken.CollectionPublic"
			nftReceiverType         = "A.01cf0e2f2f715450.NonFungibleToken.Receiver"
			resolverCollectionType  = "A.179b6b1cb6755e31.MetadataViews.ResolverCollection"
			providerType            = "A.01cf0e2f2f715450.NonFungibleToken.Provider"
		)
		assert.Equal(t, cadence.Path{Domain: "public", Identifier: pathName}, nftResult.Fields[7])
		assert.Equal(t, cadence.Path{Domain: "storage", Identifier: pathName}, nftResult.Fields[8])
		assert.Equal(t, cadence.Path{Domain: "private", Identifier: pathName}, nftResult.Fields[9])
		assert.Equal(t, cadence.String(fmt.Sprintf("&%s{%s}", collectionType, collectionPublicType)), nftResult.Fields[10])
		assert.Equal(t, cadence.String(fmt.Sprintf("&%s{%s,%s,%s,%s}", collectionType, collectionPublicType, nftCollectionPublicType, nftReceiverType, resolverCollectionType)), nftResult.Fields[11])
		assert.Equal(t, cadence.String(fmt.Sprintf("&%s{%s,%s,%s,%s}", collectionType, collectionPublicType, nftCollectionPublicType, providerType, resolverCollectionType)), nftResult.Fields[12])

		// Verify NFTCollectionDisplay results are as expected
		const (
			collectionName        = "The Example Collection"
			collectionDescription = "This collection is used as an example to help you develop your next Flow NFT."
			collectionImage       = "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg"
			collectionExternalURL = "https://example-nft.onflow.org"
		)
		assert.Equal(t, cadence.String(collectionName), nftResult.Fields[13])
		assert.Equal(t, cadence.String(collectionDescription), nftResult.Fields[14])
		assert.Equal(t, cadence.String(collectionExternalURL), nftResult.Fields[15])
		assert.Equal(t, cadence.String(collectionImage), nftResult.Fields[16])
		assert.Equal(t, cadence.String(collectionImage), nftResult.Fields[17])

		minterName, _ := cadence.NewString("minter")

		traitsView := nftResult.Fields[19].(cadence.Struct)
		traits := traitsView.Fields[0].(cadence.Array)

		blockNumberName, _ := cadence.NewString("mintedBlock")
		blockNumberTrait := traits.Values[0].(cadence.Struct)
		assert.Equal(t, blockNumberName, blockNumberTrait.Fields[0])
		assert.Equal(t, cadence.NewUInt64(13), blockNumberTrait.Fields[1])
		assert.Equal(t, cadence.NewOptional(nil), blockNumberTrait.Fields[2])
		assert.Equal(t, cadence.NewOptional(nil), blockNumberTrait.Fields[3])

		mintTrait := traits.Values[1].(cadence.Struct)
		assert.Equal(t, minterName, mintTrait.Fields[0])
		assert.Equal(t, fmt.Sprintf("0x%s", exampleNFTAddress.String()), mintTrait.Fields[1].String())
		assert.Equal(t, cadence.NewOptional(nil), mintTrait.Fields[2])
		assert.Equal(t, cadence.NewOptional(nil), mintTrait.Fields[3])

		mintedTimeName, _ := cadence.NewString("mintedTime")
		mintedTimeDisplayType, _ := cadence.NewString("Date")
		mintedTimeTrait := traits.Values[2].(cadence.Struct)
		assert.Equal(t, mintedTimeName, mintedTimeTrait.Fields[0])
		assert.Equal(t, cadence.NewOptional(mintedTimeDisplayType), mintedTimeTrait.Fields[2])

		fooName, _ := cadence.NewString("foo")
		fooValue, _ := cadence.NewString("bar")
		fooTrait := traits.Values[3].(cadence.Struct)
		fooRarityOptional := fooTrait.Fields[3].(cadence.Optional)
		fooRarity := fooRarityOptional.Value.(cadence.Struct)
		rarityDescription, _ := cadence.NewString("Common")
		assert.Equal(t, fooName, fooTrait.Fields[0])
		assert.Equal(t, cadence.NewOptional(fooValue), fooTrait.Fields[1])
		fooRarityScore := fooRarity.Fields[0].(cadence.Optional).Value
		score, _ := cadence.NewUFix64("10.0")
		assert.Equal(t, fooRarityScore, score)
		fooRarityMax := fooRarity.Fields[1].(cadence.Optional).Value
		max, _ := cadence.NewUFix64("100.0")
		assert.Equal(t, max, fooRarityMax)
		assert.Equal(t, fooRarity.Fields[2], cadence.NewOptional(rarityDescription))

	})
}

func TestSetupCollectionFromNFTReference(t *testing.T) {
	b, accountKeys := newTestSetup(t)

	// Create a new account to setting up a new account
	aAddress, _, aSigner := newAccountWithAddress(b, accountKeys)

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

	t.Run("Should be able to setup an account using the NFTCollectionData metadata view of a referenced NFT", func(t *testing.T) {
		// Ideally, the exampleNFTAddress would not be needed in order to perform the full setup, but it is required
		// until the following issue is supported in cadence: https://github.com/onflow/cadence/issues/1617
		script := templates.GenerateSetupAccountFromNftReferenceScript(nftAddress, exampleNFTAddress, metadataAddress)
		tx := createTxWithTemplateAndAuthorizer(b, script, aAddress)

		tx.AddArgument(cadence.NewAddress(exampleNFTAddress))
		tx.AddArgument(cadence.Path{Domain: "public", Identifier: "exampleNFTCollection"})
		tx.AddArgument(cadence.NewUInt64(0))

		serviceSigner, _ := b.ServiceKey().Signer()

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				aAddress,
			},
			[]crypto.Signer{
				serviceSigner,
				aSigner,
			},
			false,
		)

		assertCollectionLength(t, b, nftAddress, exampleNFTAddress,
			aAddress,
			0,
		)
	})
}
