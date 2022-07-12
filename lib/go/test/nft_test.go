package test

import (
	"fmt"
	"testing"

	. "github.com/bjartek/overflow/overflow"
	"github.com/stretchr/testify/assert"
)

func TestNFT(t *testing.T) {

	o, err := OverflowTesting(WithBasePath("../../.."), WithScriptFolderName("transactions/scripts"))
	assert.NoError(t, err)

	setupAccount := o.TxFileNameFN("setup_account")
	setupFlowRoyalty := o.TxFileNameFN("setup_account_to_receive_royalty", Arg("vaultPath", "/storage/flowTokenVault"))

	destroyNFT := o.TxFileNameFN("destroy_nft")

	mintNft := o.TxFileNameFN("mint_nft", SignProposeAndPayAsServiceAccount(),
		Arg("name", "Example NFT 0"),
		Arg("description", "This is an example NFT"),
		Arg("thumbnail", "example.jpeg"),
		Arg("cuts", "[0.25, 0.40]"),
		Arg("royaltyDescriptions", `["minter","creator"]`),
		Addresses("royaltyBeneficiaries", "alice", "bob"))

	t.Run("Should have properly initialized fields after deployment", func(t *testing.T) {
		result := o.Script("get_total_supply").GetAsJson()
		assert.Equal(t, "0", result)
	})

	t.Run("Should be able to mint a token", func(t *testing.T) {

		setupAccount(SignProposeAndPayAs("alice")).AssertSuccess(t)
		setupAccount(SignProposeAndPayAs("bob")).AssertSuccess(t)
		setupFlowRoyalty(SignProposeAndPayAs("alice")).AssertSuccess(t)
		setupFlowRoyalty(SignProposeAndPayAs("bob")).AssertSuccess(t)
		mintNft(Arg("recipient", "alice")).AssertSuccess(t)

		o.Script("borrow_nft", Arg("address", "alice"), Arg("id", "0")).GetAsInterface()
		supply := o.Script("get_total_supply").GetAsJson()
		assert.Equal(t, "1", supply)

		collectionLegnth := o.Script("get_collection_length", Arg("address", "alice")).GetAsJson()
		assert.Equal(t, "1", collectionLegnth)
	})

	t.Run("Shouldn't be able to borrow a reference to an NFT that doesn't exist", func(t *testing.T) {
		result := o.Script("borrow_nft", Arg("address", "alice"), Arg("id", 2))
		assert.ErrorContains(t, result.Err, "pre-condition failed: NFT does not exist in the collection")
	})

	t.Run("Shouldn't be able to withdraw an NFT that doesn't exist in a collection", func(t *testing.T) {

		o.Tx("transfer_nft", SignProposeAndPayAs("alice"), Arg("recipient", "bob"), Arg("withdrawID", 4)).
			AssertFailure(t, "missing NFT")
	})

	// Transfer an NFT correctly
	t.Run("Should be able to withdraw an NFT and deposit to another accounts collection", func(t *testing.T) {
		setupAccount(SignProposeAndPayAs("alice")).AssertSuccess(t)
		setupAccount(SignProposeAndPayAs("bob")).AssertSuccess(t)
		setupFlowRoyalty(SignProposeAndPayAs("alice")).AssertSuccess(t)
		setupFlowRoyalty(SignProposeAndPayAs("bob")).AssertSuccess(t)
		nft := mintNft(Arg("recipient", "alice")).AssertSuccess(t)

		//TODO: how is the best way to test events?
		assert.Equal(t, fmt.Sprintf("%v", nft.Events), "map[A.f8d6e0586b0a20c7.ExampleNFT.Deposit:[map[id:1 to:0x01cf0e2f2f715450]]]")

		id := nft.GetIdFromEvent("A.f8d6e0586b0a20c7.ExampleNFT.Deposit", "id")

		o.Tx("transfer_nft", SignProposeAndPayAs("alice"), Arg("recipient", "bob"), Arg("withdrawID", id)).AssertSuccess(t)

		result := o.Script("borrow_nft", Arg("address", "bob"), Arg("id", id))
		assert.NoError(t, result.Err)
	})

	t.Run("Should be able to withdraw an NFT and destroy it, not reducing the supply", func(t *testing.T) {
		setupAccount(SignProposeAndPayAs("alice")).AssertSuccess(t)
		setupFlowRoyalty(SignProposeAndPayAs("alice")).AssertSuccess(t)
		id := mintNft(Arg("recipient", "alice")).AssertSuccess(t).GetIdFromEvent("A.f8d6e0586b0a20c7.ExampleNFT.Deposit", "id")

		destroyNFT(SignProposeAndPayAs("alice"), Arg("id", id)).AssertSuccess(t)
		supply := o.Script("get_total_supply").GetAsJson()
		assert.Equal(t, "3", supply)

		collectionLength := o.Script("get_collection_length", Arg("address", "alice")).GetAsJson()
		assert.Equal(t, "1", collectionLength)

	})
}
