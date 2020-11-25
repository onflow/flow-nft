package test

import (
	"testing"

	"github.com/onflow/flow-go-sdk/crypto"
	templates2 "github.com/onflow/flow-go-sdk/templates"
	"github.com/onflow/flow-go-sdk/test"

	"github.com/onflow/flow-nft/lib/go/contracts"
	"github.com/onflow/flow-nft/lib/go/templates"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/onflow/flow-go-sdk"
)

func TestNFTDeployment(t *testing.T) {
	b := newEmulator()

	// Should be able to deploy a contract as a new account with no keys.
	nftCode := contracts.NonFungibleToken()
	nftAddr, err := b.CreateAccount(nil, []templates2.Contract{
		{
			Name: "NonFungibleToken",
			Source: string(nftCode),
		},
	})
	if !assert.NoError(t, err) {
		t.Log(err.Error())
	}
	_, err = b.CommitBlock()
	assert.NoError(t, err)

	// Should be able to deploy a contract as a new account with no keys.
	tokenCode := contracts.ExampleNFT(nftAddr.String())
	_, err = b.CreateAccount(nil, []templates2.Contract{
		{
			Name: "ExampleNFT",
			Source: string(tokenCode),
		},
	})
	if !assert.NoError(t, err) {
		t.Log(err.Error())
	}
	_, err = b.CommitBlock()
	assert.NoError(t, err)

}

func TestCreateNFT(t *testing.T) {
	b := newEmulator()

	accountKeys := test.AccountKeyGenerator()

	// Should be able to deploy a contract as a new account with no keys.
	nftCode := contracts.NonFungibleToken()
	nftAddr, _ := b.CreateAccount(nil, []templates2.Contract{
		{
			Name: "NonFungibleToken",
			Source: string(nftCode),
		},
	})

	// First, deploy the contract
	tokenCode := contracts.ExampleNFT(nftAddr.String())
	tokenAccountKey, tokenSigner := accountKeys.NewWithSigner()
	tokenAddr, _ := b.CreateAccount([]*flow.AccountKey{tokenAccountKey}, []templates2.Contract{
		{
			Name: "ExampleNFT",
			Source: string(tokenCode),
		},
	})

	executeScriptAndCheck(t, b, templates.GenerateInspectNFTSupplyScript(nftAddr, tokenAddr, "ExampleNFT", 0))

	executeScriptAndCheck(t, b, templates.GenerateInspectCollectionLenScript(nftAddr, tokenAddr, tokenAddr, "ExampleNFT", "NFTCollection", 0))

	t.Run("Should be able to mint a token", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(templates.GenerateMintNFTScript(nftAddr, tokenAddr, tokenAddr)).
			SetGasLimit(100).
			SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
			SetPayer(b.ServiceKey().Address).
			AddAuthorizer(tokenAddr)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, tokenAddr},
			[]crypto.Signer{b.ServiceKey().Signer(), tokenSigner},
			false,
		)

		// Assert that the account's collection is correct
		executeScriptAndCheck(t, b, templates.GenerateInspectCollectionScript(nftAddr, tokenAddr, tokenAddr, "ExampleNFT", "NFTCollection", 0))

		executeScriptAndCheck(t, b, templates.GenerateInspectCollectionLenScript(nftAddr, tokenAddr, tokenAddr, "ExampleNFT", "NFTCollection", 1))

		executeScriptAndCheck(t, b, templates.GenerateInspectNFTSupplyScript(nftAddr, tokenAddr, "ExampleNFT", 1))

	})

	t.Run("Shouldn't be able to borrow a reference to an NFT that doesn't exist", func(t *testing.T) {
		// Assert that the account's collection is correct
		result, err := b.ExecuteScript(templates.GenerateInspectCollectionScript(nftAddr, tokenAddr, tokenAddr, "ExampleNFT", "NFTCollection", 5), nil)
		require.NoError(t, err)
		assert.True(t, result.Reverted())
	})

}

func TestTransferNFT(t *testing.T) {
	b := newEmulator()

	accountKeys := test.AccountKeyGenerator()

	// Should be able to deploy a contract as a new account with no keys.
	nftCode := contracts.NonFungibleToken()
	nftAddr, err := b.CreateAccount(nil, []templates2.Contract{
		{
			Name: "NonFungibleToken",
			Source: string(nftCode),
		},
	})
	assert.NoError(t, err)

	// First, deploy the contract
	tokenCode := contracts.ExampleNFT(nftAddr.String())
	tokenAccountKey, tokenSigner := accountKeys.NewWithSigner()
	tokenAddr, err := b.CreateAccount([]*flow.AccountKey{tokenAccountKey}, []templates2.Contract{
		{
			Name: "ExampleNFT",
			Source: string(tokenCode),
		},
	})
	assert.NoError(t, err)

	joshAccountKey, joshSigner := accountKeys.NewWithSigner()
	joshAddress, err := b.CreateAccount([]*flow.AccountKey{joshAccountKey}, nil)

	tx := flow.NewTransaction().
		SetScript(templates.GenerateMintNFTScript(nftAddr, tokenAddr, tokenAddr)).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(tokenAddr)

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, tokenAddr},
		[]crypto.Signer{b.ServiceKey().Signer(), tokenSigner},
		false,
	)

	// create a new Collection
	t.Run("Should be able to create a new empty NFT Collection", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(templates.GenerateCreateCollectionScript(nftAddr.String(), tokenAddr.String(), "ExampleNFT", "NFTCollection")).
			SetGasLimit(100).
			SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
			SetPayer(b.ServiceKey().Address).
			AddAuthorizer(joshAddress)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, joshAddress},
			[]crypto.Signer{b.ServiceKey().Signer(), joshSigner},
			false,
		)

		executeScriptAndCheck(t, b, templates.GenerateInspectCollectionLenScript(nftAddr, tokenAddr, joshAddress, "ExampleNFT", "NFTCollection", 0))

	})

	t.Run("Shouldn't be able to withdraw an NFT that doesn't exist in a collection", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(templates.GenerateTransferScript(nftAddr, tokenAddr, "ExampleNFT", "NFTCollection", joshAddress, 3)).
			SetGasLimit(100).
			SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
			SetPayer(b.ServiceKey().Address).
			AddAuthorizer(tokenAddr)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, tokenAddr},
			[]crypto.Signer{b.ServiceKey().Signer(), tokenSigner},
			true,
		)

		executeScriptAndCheck(t, b, templates.GenerateInspectCollectionLenScript(nftAddr, tokenAddr, joshAddress, "ExampleNFT", "NFTCollection", 0))

		// Assert that the account's collection is correct
		executeScriptAndCheck(t, b, templates.GenerateInspectCollectionLenScript(nftAddr, tokenAddr, tokenAddr, "ExampleNFT", "NFTCollection", 1))

	})

	// transfer an NFT
	t.Run("Should be able to withdraw an NFT and deposit to another accounts collection", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(templates.GenerateTransferScript(nftAddr, tokenAddr, "ExampleNFT", "NFTCollection", joshAddress, 0)).
			SetGasLimit(100).
			SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
			SetPayer(b.ServiceKey().Address).
			AddAuthorizer(tokenAddr)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, tokenAddr},
			[]crypto.Signer{b.ServiceKey().Signer(), tokenSigner},
			false,
		)

		// Assert that the account's collection is correct
		executeScriptAndCheck(t, b, templates.GenerateInspectCollectionScript(nftAddr, tokenAddr, joshAddress, "ExampleNFT", "NFTCollection", 0))

		executeScriptAndCheck(t, b, templates.GenerateInspectCollectionLenScript(nftAddr, tokenAddr, joshAddress, "ExampleNFT", "NFTCollection", 1))

		// Assert that the account's collection is correct
		executeScriptAndCheck(t, b, templates.GenerateInspectCollectionLenScript(nftAddr, tokenAddr, tokenAddr, "ExampleNFT", "NFTCollection", 0))

	})

	// transfer an NFT
	t.Run("Should be able to withdraw an NFT and destroy it, not reducing the supply", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(templates.GenerateDestroyScript(nftAddr, tokenAddr, "ExampleNFT", "NFTCollection", 0)).
			SetGasLimit(100).
			SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
			SetPayer(b.ServiceKey().Address).
			AddAuthorizer(joshAddress)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, joshAddress},
			[]crypto.Signer{b.ServiceKey().Signer(), joshSigner},
			false,
		)

		executeScriptAndCheck(t, b, templates.GenerateInspectCollectionLenScript(nftAddr, tokenAddr, joshAddress, "ExampleNFT", "NFTCollection", 0))

		// Assert that the account's collection is correct
		executeScriptAndCheck(t, b, templates.GenerateInspectCollectionLenScript(nftAddr, tokenAddr, tokenAddr, "ExampleNFT", "NFTCollection", 0))

		executeScriptAndCheck(t, b, templates.GenerateInspectNFTSupplyScript(nftAddr, tokenAddr, "ExampleNFT", 1))

	})
}
