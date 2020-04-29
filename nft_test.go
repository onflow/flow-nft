package tests

import (
	"testing"

	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/onflow/flow-go-sdk/test"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/onflow/flow-go-sdk"
)

const (
	NonFungibleTokenInterfaceFile = "./contracts/NonFungibleToken.cdc"
	NFTContractFile               = "./contracts/ExampleNFT.cdc"
)

func TestNFTDeployment(t *testing.T) {
	b := NewEmulator()

	// Should be able to deploy a contract as a new account with no keys.
	tokenCode := ReadFile(NonFungibleTokenInterfaceFile)
	_, err := b.CreateAccount(nil, tokenCode)
	if !assert.NoError(t, err) {
		t.Log(err.Error())
	}
	_, err = b.CommitBlock()
	assert.NoError(t, err)

	// Should be able to deploy a contract as a new account with no keys.
	tokenCode := ReadFile(NFTContractFile)
	_, err := b.CreateAccount(nil, tokenCode)
	if !assert.NoError(t, err) {
		t.Log(err.Error())
	}
	_, err = b.CommitBlock()
	assert.NoError(t, err)
}

func TestCreateNFT(t *testing.T) {
	b := NewEmulator()

	accountKeys := test.AccountKeyGenerator()

	// First, deploy the contract
	tokenCode := ReadFile(NFTContractFile)
	contractAccountKey, contractSigner := accountKeys.NewWithSigner()
	contractAddr, err := b.CreateAccount([]*flow.AccountKey{contractAccountKey}, tokenCode)
	assert.NoError(t, err)

	result, err := b.ExecuteScript(GenerateInspectNFTSupplyScript(contractAddr, 0))
	require.NoError(t, err)
	if !assert.True(t, result.Succeeded()) {
		t.Log(result.Error.Error())
	}

	result, err = b.ExecuteScript(GenerateInspectCollectionLenScript(contractAddr, contractAddr, 0))
	require.NoError(t, err)
	if !assert.True(t, result.Succeeded()) {
		t.Log(result.Error.Error())
	}

	t.Run("Should be able to mint a token", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(GenerateMintNFTScript(contractAddr, contractAddr)).
			SetGasLimit(20).
			SetProposalKey(b.RootKey().Address, b.RootKey().ID, b.RootKey().SequenceNumber).
			SetPayer(b.RootKey().Address).
			AddAuthorizer(contractAddr)

		SignAndSubmit(
			t, b, tx,
			[]flow.Address{b.RootKey().Address, contractAddr},
			[]crypto.Signer{b.RootKey().Signer(), contractSigner},
			false,
		)

		// Assert that the account's collection is correct
		result, err = b.ExecuteScript(GenerateInspectCollectionScript(contractAddr, contractAddr, 0))
		require.NoError(t, err)
		if !assert.True(t, result.Succeeded()) {
			t.Log(result.Error.Error())
		}

		result, err = b.ExecuteScript(GenerateInspectCollectionLenScript(contractAddr, contractAddr, 1))
		require.NoError(t, err)
		if !assert.True(t, result.Succeeded()) {
			t.Log(result.Error.Error())
		}

		result, err = b.ExecuteScript(GenerateInspectNFTSupplyScript(contractAddr, 1))
		require.NoError(t, err)
		if !assert.True(t, result.Succeeded()) {
			t.Log(result.Error.Error())
		}
	})

	t.Run("Shouldn't be able to borrow a reference to an NFT that doesn't exist", func(t *testing.T) {
		// Assert that the account's collection is correct
		result, err = b.ExecuteScript(GenerateInspectCollectionScript(contractAddr, contractAddr, 5))
		require.NoError(t, err)
		assert.True(t, result.Reverted())
	})

}

func TestTransferNFT(t *testing.T) {
	b := NewEmulator()

	accountKeys := test.AccountKeyGenerator()

	// First, deploy the contract
	tokenCode := ReadFile(NFTContractFile)
	contractAccountKey, contractSigner := accountKeys.NewWithSigner()
	contractAddr, err := b.CreateAccount([]*flow.AccountKey{contractAccountKey}, tokenCode)
	assert.NoError(t, err)

	joshAccountKey, joshSigner := accountKeys.NewWithSigner()
	joshAddress, err := b.CreateAccount([]*flow.AccountKey{joshAccountKey}, nil)

	tx := flow.NewTransaction().
		SetScript(GenerateMintNFTScript(contractAddr, contractAddr)).
		SetGasLimit(20).
		SetProposalKey(b.RootKey().Address, b.RootKey().ID, b.RootKey().SequenceNumber).
		SetPayer(b.RootKey().Address).
		AddAuthorizer(contractAddr)

	SignAndSubmit(
		t, b, tx,
		[]flow.Address{b.RootKey().Address, contractAddr},
		[]crypto.Signer{b.RootKey().Signer(), contractSigner},
		false,
	)

	// create a new Collection
	t.Run("Should be able to create a new empty NFT Collection", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(GenerateCreateCollectionScript(contractAddr)).
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

		result, err := b.ExecuteScript(GenerateInspectCollectionLenScript(contractAddr, joshAddress, 0))
		require.NoError(t, err)
		if !assert.True(t, result.Succeeded()) {
			t.Log(result.Error.Error())
		}
	})

	t.Run("Shouldn't be able to withdraw an NFT that doesn't exist in a collection", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(GenerateTransferScript(contractAddr, joshAddress, 3)).
			SetGasLimit(20).
			SetProposalKey(b.RootKey().Address, b.RootKey().ID, b.RootKey().SequenceNumber).
			SetPayer(b.RootKey().Address).
			AddAuthorizer(contractAddr)

		SignAndSubmit(
			t, b, tx,
			[]flow.Address{b.RootKey().Address, contractAddr},
			[]crypto.Signer{b.RootKey().Signer(), contractSigner},
			true,
		)

		result, err := b.ExecuteScript(GenerateInspectCollectionLenScript(contractAddr, joshAddress, 0))
		require.NoError(t, err)
		if !assert.True(t, result.Succeeded()) {
			t.Log(result.Error.Error())
		}

		// Assert that the account's collection is correct
		result, err = b.ExecuteScript(GenerateInspectCollectionLenScript(contractAddr, contractAddr, 1))
		require.NoError(t, err)
		if !assert.True(t, result.Succeeded()) {
			t.Log(result.Error.Error())
		}
	})

	// transfer an NFT
	t.Run("Should be able to withdraw an NFT and deposit to another accounts collection", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(GenerateTransferScript(contractAddr, joshAddress, 0)).
			SetGasLimit(20).
			SetProposalKey(b.RootKey().Address, b.RootKey().ID, b.RootKey().SequenceNumber).
			SetPayer(b.RootKey().Address).
			AddAuthorizer(contractAddr)

		SignAndSubmit(
			t, b, tx,
			[]flow.Address{b.RootKey().Address, contractAddr},
			[]crypto.Signer{b.RootKey().Signer(), contractSigner},
			false,
		)

		// Assert that the account's collection is correct
		result, err := b.ExecuteScript(GenerateInspectCollectionScript(contractAddr, joshAddress, 0))
		require.NoError(t, err)
		if !assert.True(t, result.Succeeded()) {
			t.Log(result.Error.Error())
		}

		result, err = b.ExecuteScript(GenerateInspectCollectionLenScript(contractAddr, joshAddress, 1))
		require.NoError(t, err)
		if !assert.True(t, result.Succeeded()) {
			t.Log(result.Error.Error())
		}

		// Assert that the account's collection is correct
		result, err = b.ExecuteScript(GenerateInspectCollectionLenScript(contractAddr, contractAddr, 0))
		require.NoError(t, err)
		if !assert.True(t, result.Succeeded()) {
			t.Log(result.Error.Error())
		}
	})

	// transfer an NFT
	t.Run("Should be able to withdraw an NFT and destroy it, reducing the supply", func(t *testing.T) {
		tx := flow.NewTransaction().
			SetScript(GenerateDestroyScript(contractAddr, 0)).
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

		result, err := b.ExecuteScript(GenerateInspectCollectionLenScript(contractAddr, joshAddress, 0))
		require.NoError(t, err)
		if !assert.True(t, result.Succeeded()) {
			t.Log(result.Error.Error())
		}

		// Assert that the account's collection is correct
		result, err = b.ExecuteScript(GenerateInspectCollectionLenScript(contractAddr, contractAddr, 0))
		require.NoError(t, err)
		if !assert.True(t, result.Succeeded()) {
			t.Log(result.Error.Error())
		}

		result, err = b.ExecuteScript(GenerateInspectNFTSupplyScript(contractAddr, 0))
		require.NoError(t, err)
		if !assert.True(t, result.Succeeded()) {
			t.Log(result.Error.Error())
		}
	})
}
