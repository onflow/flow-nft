package main

import (
	"testing"

	. "github.com/bjartek/overflow"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestNFT(t *testing.T) {
	o, err := OverflowTesting()
	assert.NoError(t, err)

	setupAccount := o.TxFileNameFN("setup_account")
	setupFlowRoyalty := o.TxFileNameFN("setup_account_to_receive_royalty", WithArg("vaultPath", "/storage/flowTokenVault"))

	destroyNFT := o.TxFileNameFN("destroy_nft")

	mintNft := o.TxFileNameFN("mint_nft", WithSignerServiceAccount(),
		WithArg("name", "Example NFT 0"),
		WithArg("description", "This is an example NFT"),
		WithArg("thumbnail", "example.jpeg"),
		WithArg("cuts", "[0.25, 0.40]"),
		WithArg("royaltyDescriptions", `["minter","creator"]`),
		WithAddresses("royaltyBeneficiaries", "alice", "bob"))

	t.Run("Should have properly initialized fields after deployment", func(t *testing.T) {
		result, err := o.Script("get_total_supply").GetAsJson()
		require.NoError(t, err)
		assert.Equal(t, "0", result)
	})

	t.Run("Should be able to mint a token", func(t *testing.T) {

		setupAccount(WithSigner("alice")).AssertSuccess(t)
		setupAccount(WithSigner("bob")).AssertSuccess(t)
		setupFlowRoyalty(WithSigner("alice")).AssertSuccess(t)
		setupFlowRoyalty(WithSigner("bob")).AssertSuccess(t)
		mintNft(WithArg("recipient", "alice")).AssertSuccess(t)

		o.Script("borrow_nft", WithArg("address", "alice"), WithArg("id", "0")).GetAsInterface()
		supply, err := o.Script("get_total_supply").GetAsJson()
		require.NoError(t, err)
		assert.Equal(t, "1", supply)

		collectionLegnth, err := o.Script("get_collection_length", WithArg("address", "alice")).GetAsJson()
		require.NoError(t, err)
		assert.Equal(t, "1", collectionLegnth)
	})

	t.Run("Shouldn't be able to borrow a reference to an NFT that doesn't exist", func(t *testing.T) {
		result := o.Script("borrow_nft", WithArg("address", "alice"), WithArg("id", 2))
		assert.ErrorContains(t, result.Err, "pre-condition failed: NFT does not exist in the collection")
	})

	t.Run("Shouldn't be able to withdraw an NFT that doesn't exist in a collection", func(t *testing.T) {

		o.Tx("transfer_nft", WithSigner("alice"), WithArg("recipient", "bob"), WithArg("withdrawID", 4)).
			AssertFailure(t, "missing NFT")
	})

	// Transfer an NFT correctly
	t.Run("Should be able to withdraw an NFT and deposit to another accounts collection", func(t *testing.T) {
		setupAccount(WithSigner("alice")).AssertSuccess(t)
		setupAccount(WithSigner("bob")).AssertSuccess(t)
		setupFlowRoyalty(WithSigner("alice")).AssertSuccess(t)
		setupFlowRoyalty(WithSigner("bob")).AssertSuccess(t)
		nft := mintNft(WithArg("recipient", "alice")).AssertSuccess(t)

		nft.AssertEvent(t, "ExampleNFT.Deposit", map[string]interface{}{
			"id": uint64(1),
		})

		id, err := nft.GetIdFromEvent("ExampleNFT.Deposit", "id")
		require.NoError(t, err)

		o.Tx("transfer_nft", WithSigner("alice"), WithArg("recipient", "bob"), WithArg("withdrawID", id)).AssertSuccess(t)

		result := o.Script("borrow_nft", WithArg("address", "bob"), WithArg("id", id))
		assert.NoError(t, result.Err)
	})

	t.Run("Should be able to withdraw an NFT and destroy it, not reducing the supply", func(t *testing.T) {
		setupAccount(WithSigner("alice")).AssertSuccess(t)
		setupFlowRoyalty(WithSigner("alice")).AssertSuccess(t)
		id, err := mintNft(WithArg("recipient", "alice")).AssertSuccess(t).GetIdFromEvent("A.f8d6e0586b0a20c7.ExampleNFT.Deposit", "id")
		require.NoError(t, err)

		destroyNFT(WithSigner("alice"), WithArg("id", id)).AssertSuccess(t)
		supply, err := o.Script("get_total_supply").GetAsJson()
		require.NoError(t, err)
		assert.Equal(t, "3", supply)

		collectionLength, err := o.Script("get_collection_length", WithArg("address", "alice")).GetAsJson()
		require.NoError(t, err)
		assert.Equal(t, "3", supply)
		assert.Equal(t, "1", collectionLength)

	})
}
