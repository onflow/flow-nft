package test

import (
	"context"
	"testing"

	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
	"github.com/onflow/cadence/runtime/common"
	"github.com/onflow/flow-emulator/adapters"
	"github.com/onflow/flow-emulator/emulator"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	sdktemplates "github.com/onflow/flow-go-sdk/templates"
	"github.com/onflow/flow-go-sdk/test"
	"github.com/stretchr/testify/assert"

	"github.com/onflow/flow-nft/lib/go/contracts"
	"github.com/onflow/flow-nft/lib/go/templates"
)

// Deploys the NonFungibleToken, MetadataViews, and ExampleNFT contracts to new accounts
// and returns their addresses
func deployNFTContracts(
	t *testing.T,
	b emulator.Emulator,
	adapter *adapters.SDKAdapter,
	accountKeys *test.AccountKeys,
	exampleNFTAccountKey *flow.AccountKey,
) (flow.Address, flow.Address, flow.Address, flow.Address) {

	nftAccountKey, _ := accountKeys.NewWithSigner()

	resolverAddress := deploy(t, b, adapter, "ViewResolver", contracts.ViewResolver(), nftAccountKey)

	// Deploy the NonFungibleToken contract interface
	nftAddress, err := adapter.CreateAccount(context.Background(), []*flow.AccountKey{nftAccountKey}, []sdktemplates.Contract{
		{
			Name:   "NonFungibleToken",
			Source: string(contracts.NonFungibleToken(resolverAddress.String())),
		},
	})
	if !assert.NoError(t, err) {
		t.Log(err.Error())
	}
	_, err = b.CommitBlock()
	assert.NoError(t, err)

	metadataAddress := deploy(t, b, adapter, "MetadataViews", contracts.MetadataViews(emulatorFTAddress, nftAddress.String(), resolverAddress.String()), nftAccountKey)

	exampleNFTAddress := deploy(
		t, b, adapter,
		"ExampleNFT",
		contracts.ExampleNFT(nftAddress, metadataAddress, resolverAddress),
		exampleNFTAccountKey,
	)

	// Saving the UniversalCollection and Basic NFT for a different PR

	// universalCollectionAddress := deploy(
	// 	t, b, adapter,
	// 	"UniversalCollection",
	// 	contracts.UniversalCollection(nftAddress, resolverAddress, metadataAddress),
	// 	nftAccountKey,
	// )

	// deploy(
	// 	t, b, adapter,
	// 	"BasicNFT",
	// 	contracts.BasicNFT(nftAddress, resolverAddress, metadataAddress, universalCollectionAddress),
	// 	exampleNFTAccountKey,
	// )

	return nftAddress, metadataAddress, exampleNFTAddress, resolverAddress
}

// Mints a single NFT from the ExampleNFT contract
// with standard metadata fields and royalty cuts
func mintExampleNFT(
	t *testing.T,
	b emulator.Emulator,
	accountKeys *test.AccountKeys,
	nftAddress, metadataAddress, exampleNFTAddress flow.Address,
	exampleNFTAccountKey *flow.AccountKey,
	exampleNFTSigner crypto.Signer,
) {

	// Create two new accounts to act as beneficiaries for royalties
	beneficiaryAddress1, _, beneficiarySigner1 := newAccountWithAddress(b, accountKeys)
	setupRoyaltyReceiver(t, b,
		metadataAddress,
		beneficiaryAddress1,
		beneficiarySigner1,
	)
	beneficiaryAddress2, _, beneficiarySigner2 := newAccountWithAddress(b, accountKeys)
	setupRoyaltyReceiver(t, b,
		metadataAddress,
		beneficiaryAddress2,
		beneficiarySigner2,
	)

	// Generate the script that mints a new NFT and deposits it into the recipient's account
	// whose address is the first argument to the transaction
	script := templates.GenerateMintNFTScript(nftAddress, exampleNFTAddress, metadataAddress, flow.HexToAddress(emulatorFTAddress))

	// Create the transaction object with the generated script and authorizer
	tx := createTxWithTemplateAndAuthorizer(b, script, exampleNFTAddress)

	// Assemble the cut information for royalties
	cut1 := CadenceUFix64("0.25")
	cut2 := CadenceUFix64("0.40")
	cuts := []cadence.Value{cut1, cut2}

	// Assemble the royalty description and beneficiary addresses to get their receivers
	royaltyDescriptions := []cadence.Value{cadence.String("Minter royalty"), cadence.String("Creator royalty")}
	royaltyBeneficiaries := []cadence.Value{cadence.NewAddress(beneficiaryAddress1), cadence.NewAddress(beneficiaryAddress2)}

	// First argument is the recipient of the newly minted NFT
	tx.AddArgument(cadence.NewAddress(exampleNFTAddress))
	tx.AddArgument(cadence.String("Example NFT 0"))
	tx.AddArgument(cadence.String("This is an example NFT"))
	tx.AddArgument(cadence.String("example.jpeg"))
	tx.AddArgument(cadence.NewArray(cuts))
	tx.AddArgument(cadence.NewArray(royaltyDescriptions))
	tx.AddArgument(cadence.NewArray(royaltyBeneficiaries))

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
}

// Asserts that the ExampleNFT collection in the specified user's account
// is the expected length
func assertCollectionLength(
	t *testing.T,
	b emulator.Emulator,
	nftAddress flow.Address, exampleNFTAddress flow.Address, metadataAddress flow.Address,
	collectionAddress flow.Address,
	expectedLength int,
) {
	script := templates.GenerateGetCollectionLengthScript(nftAddress, exampleNFTAddress, metadataAddress)
	actualLength := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(collectionAddress))})
	assert.Equal(t, cadence.NewInt(expectedLength), actualLength)
}

// Sets up an account with the generic royalty receiver in place of their Flow token receiver
func setupRoyaltyReceiver(
	t *testing.T,
	b emulator.Emulator,
	metadataAddress flow.Address,
	authorizerAddress flow.Address,
	authorizerSigner crypto.Signer,
) {

	script := templates.GenerateSetupAccountToReceiveRoyaltyScript(metadataAddress, flow.HexToAddress(emulatorFTAddress))
	tx := createTxWithTemplateAndAuthorizer(b, script, authorizerAddress)

	vaultPath := cadence.Path{Domain: common.PathDomainStorage, Identifier: "flowTokenVault"}
	tx.AddArgument(vaultPath)

	signAndSubmit(
		t, b, tx,
		[]flow.Address{
			authorizerAddress,
		},
		[]crypto.Signer{
			authorizerSigner,
		},
		false,
	)
}
