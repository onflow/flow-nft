package nfttests

import (
	"testing"

	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/onflow/flow-go-sdk/test"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/onflow/flow-go-sdk"
)

const (
	NonFungibleTokenInterfaceFile = "../contracts/NonFungibleToken.cdc"
	NFTContractFile               = "../contracts/ExampleNFT.cdc"
)

func TestNFTDeployment(t *testing.T) {
	b := NewEmulator()

	// Should be able to deploy a contract as a new account with no keys.
	nftCode := ReadFile(NonFungibleTokenInterfaceFile)
	_, err := b.CreateAccount(nil, nftCode)
	if !assert.NoError(t, err) {
		t.Log(err.Error())
	}
	_, err = b.CommitBlock()
	assert.NoError(t, err)

	// Should be able to deploy a contract as a new account with no keys.
	tokenCode := ReadFile(NFTContractFile)
	_, err = b.CreateAccount(nil, tokenCode)
	if !assert.NoError(t, err) {
		t.Log(err.Error())
	}
	_, err = b.CommitBlock()
	assert.NoError(t, err)
}

func TestCreateNFT(t *testing.T) {
	b := NewEmulator()

	accountKeys := test.AccountKeyGenerator()

	// Should be able to deploy a contract as a new account with no keys.
	nftCode := ReadFile(NonFungibleTokenInterfaceFile)
	nftAddr, err := b.CreateAccount(nil, nftCode)
	assert.NoError(t, err)

	// First, deploy the contract
	tokenCode := ReadFile(NFTContractFile)
	tokenAccountKey, tokenSigner := accountKeys.NewWithSigner()
	tokenAddr, err := b.CreateAccount([]*flow.AccountKey{tokenAccountKey}, tokenCode)
	assert.NoError(t, err)

	ExecuteScriptAndCheck(t, b, GenerateInspectNFTSupplyScript(nftAddr, tokenAddr, "ExampleNFT", 0))

	ExecuteScriptAndCheck(t, b, GenerateInspectCollectionLenScript(nftAddr, tokenAddr, tokenAddr, "ExampleNFT", "NFTCollection", 0))

	t.Run("Should be able to mint a token", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(GenerateMintNFTScript(nftAddr, tokenAddr, tokenAddr)).
			SetGasLimit(20).
			SetProposalKey(b.RootKey().Address, b.RootKey().ID, b.RootKey().SequenceNumber).
			SetPayer(b.RootKey().Address).
			AddAuthorizer(tokenAddr)

		SignAndSubmit(
			t, b, tx,
			[]flow.Address{b.RootKey().Address, tokenAddr},
			[]crypto.Signer{b.RootKey().Signer(), tokenSigner},
			false,
		)

		// Assert that the account's collection is correct
		ExecuteScriptAndCheck(t, b, GenerateInspectCollectionScript(nftAddr, tokenAddr, tokenAddr, "ExampleNFT", "NFTCollection", 0))

		ExecuteScriptAndCheck(t, b, GenerateInspectCollectionLenScript(nftAddr, tokenAddr, tokenAddr, "ExampleNFT", "NFTCollection", 1))

		ExecuteScriptAndCheck(t, b, GenerateInspectNFTSupplyScript(nftAddr, tokenAddr, "ExampleNFT", 1))

	})

	t.Run("Shouldn't be able to borrow a reference to an NFT that doesn't exist", func(t *testing.T) {
		// Assert that the account's collection is correct
		result, err := b.ExecuteScript(GenerateInspectCollectionScript(nftAddr, tokenAddr, tokenAddr, "ExampleNFT", "NFTCollection", 5))
		require.NoError(t, err)
		assert.True(t, result.Reverted())
	})

}

func TestTransferNFT(t *testing.T) {
	b := NewEmulator()

	accountKeys := test.AccountKeyGenerator()

	// Should be able to deploy a contract as a new account with no keys.
	nftCode := ReadFile(NonFungibleTokenInterfaceFile)
	nftAddr, err := b.CreateAccount(nil, nftCode)
	assert.NoError(t, err)

	// First, deploy the contract
	tokenCode := ReadFile(NFTContractFile)
	tokenAccountKey, tokenSigner := accountKeys.NewWithSigner()
	tokenAddr, err := b.CreateAccount([]*flow.AccountKey{tokenAccountKey}, tokenCode)
	assert.NoError(t, err)

	joshAccountKey, joshSigner := accountKeys.NewWithSigner()
	joshAddress, err := b.CreateAccount([]*flow.AccountKey{joshAccountKey}, nil)

	tx := flow.NewTransaction().
		SetScript(GenerateMintNFTScript(nftAddr, tokenAddr, tokenAddr)).
		SetGasLimit(20).
		SetProposalKey(b.RootKey().Address, b.RootKey().ID, b.RootKey().SequenceNumber).
		SetPayer(b.RootKey().Address).
		AddAuthorizer(tokenAddr)

	SignAndSubmit(
		t, b, tx,
		[]flow.Address{b.RootKey().Address, tokenAddr},
		[]crypto.Signer{b.RootKey().Signer(), tokenSigner},
		false,
	)

	// create a new Collection
	t.Run("Should be able to create a new empty NFT Collection", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(GenerateCreateCollectionScript(nftAddr, "ExampleNFT", tokenAddr, "NFTCollection")).
			SetGasLimit(20).
			SetProposalKey(b.RootKey().Address, b.RootKey().ID, b.RootKey().SequenceNumber).
			SetPayer(b.RootKey().Address).
			AddAuthorizer(joshAddress)

		SignAndSubmit(
			t, b, tx,
			[]flow.Address{b.RootKey().Address, joshAddress},
			[]crypto.Signer{b.RootKey().Signer(), joshSigner},
			false,
		)

		ExecuteScriptAndCheck(t, b, GenerateInspectCollectionLenScript(nftAddr, tokenAddr, joshAddress, "ExampleNFT", "NFTCollection", 0))

	})

	t.Run("Shouldn't be able to withdraw an NFT that doesn't exist in a collection", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(GenerateTransferScript(nftAddr, tokenAddr, "ExampleNFT", "NFTCollection", joshAddress, 3)).
			SetGasLimit(20).
			SetProposalKey(b.RootKey().Address, b.RootKey().ID, b.RootKey().SequenceNumber).
			SetPayer(b.RootKey().Address).
			AddAuthorizer(tokenAddr)

		SignAndSubmit(
			t, b, tx,
			[]flow.Address{b.RootKey().Address, tokenAddr},
			[]crypto.Signer{b.RootKey().Signer(), tokenSigner},
			true,
		)

		ExecuteScriptAndCheck(t, b, GenerateInspectCollectionLenScript(nftAddr, tokenAddr, joshAddress, "ExampleNFT", "NFTCollection", 0))

		// Assert that the account's collection is correct
		ExecuteScriptAndCheck(t, b, GenerateInspectCollectionLenScript(nftAddr, tokenAddr, tokenAddr, "ExampleNFT", "NFTCollection", 1))

	})

	// transfer an NFT
	t.Run("Should be able to withdraw an NFT and deposit to another accounts collection", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(GenerateTransferScript(nftAddr, tokenAddr, "ExampleNFT", "NFTCollection", joshAddress, 0)).
			SetGasLimit(20).
			SetProposalKey(b.RootKey().Address, b.RootKey().ID, b.RootKey().SequenceNumber).
			SetPayer(b.RootKey().Address).
			AddAuthorizer(tokenAddr)

		SignAndSubmit(
			t, b, tx,
			[]flow.Address{b.RootKey().Address, tokenAddr},
			[]crypto.Signer{b.RootKey().Signer(), tokenSigner},
			false,
		)

		// Assert that the account's collection is correct
		ExecuteScriptAndCheck(t, b, GenerateInspectCollectionScript(nftAddr, tokenAddr, joshAddress, "ExampleNFT", "NFTCollection", 0))

		ExecuteScriptAndCheck(t, b, GenerateInspectCollectionLenScript(nftAddr, tokenAddr, joshAddress, "ExampleNFT", "NFTCollection", 1))

		// Assert that the account's collection is correct
		ExecuteScriptAndCheck(t, b, GenerateInspectCollectionLenScript(nftAddr, tokenAddr, tokenAddr, "ExampleNFT", "NFTCollection", 0))

	})

	// transfer an NFT
	t.Run("Should be able to withdraw an NFT and destroy it, not reducing the supply", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(GenerateDestroyScript(nftAddr, tokenAddr, "ExampleNFT", "NFTCollection", 0)).
			SetGasLimit(20).
			SetProposalKey(b.RootKey().Address, b.RootKey().ID, b.RootKey().SequenceNumber).
			SetPayer(b.RootKey().Address).
			AddAuthorizer(joshAddress)

		SignAndSubmit(
			t, b, tx,
			[]flow.Address{b.RootKey().Address, joshAddress},
			[]crypto.Signer{b.RootKey().Signer(), joshSigner},
			false,
		)

		ExecuteScriptAndCheck(t, b, GenerateInspectCollectionLenScript(nftAddr, tokenAddr, joshAddress, "ExampleNFT", "NFTCollection", 0))

		// Assert that the account's collection is correct
		ExecuteScriptAndCheck(t, b, GenerateInspectCollectionLenScript(nftAddr, tokenAddr, tokenAddr, "ExampleNFT", "NFTCollection", 0))

		ExecuteScriptAndCheck(t, b, GenerateInspectNFTSupplyScript(nftAddr, tokenAddr, "ExampleNFT", 1))

	})
}
