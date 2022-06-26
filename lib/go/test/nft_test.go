package test

import (
	"testing"

	. "github.com/bjartek/overflow/overflow"
	"github.com/stretchr/testify/assert"
)

func TestNFT(t *testing.T) {

	o, err := OverflowTesting(WithBasePath("../../.."), WithScriptFolderName("transactions/scripts"))
	assert.NoError(t, err)

	setupAccount := o.TxFileNameFN("setup_account")
	setupFlowRoyalty := o.TxFileNameFN("setup_account_to_receive_royalty", Arg("vaultPath", "/storage/flowTokenVault"))

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

		setupAccount(SignProposeAndPayAs("alice")).Test(t).AssertSuccess()
		setupAccount(SignProposeAndPayAs("bob")).Test(t).AssertSuccess()
		setupFlowRoyalty(SignProposeAndPayAs("alice")).Test(t).AssertSuccess()
		setupFlowRoyalty(SignProposeAndPayAs("bob")).Test(t).AssertSuccess()
		mintNft(Arg("recipient", "alice")).Test(t).AssertSuccess()

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
			Test(t).AssertFailure("missing NFT")
	})

	// Transfer an NFT correctly
	t.Run("Should be able to withdraw an NFT and deposit to another accounts collection", func(t *testing.T) {
		setupAccount(SignProposeAndPayAs("alice")).Test(t).AssertSuccess()
		setupAccount(SignProposeAndPayAs("bob")).Test(t).AssertSuccess()
		setupFlowRoyalty(SignProposeAndPayAs("alice")).Test(t).AssertSuccess()
		setupFlowRoyalty(SignProposeAndPayAs("bob")).Test(t).AssertSuccess()
		id := mintNft(Arg("recipient", "alice")).Test(t).AssertSuccess().GetIdFromEvent("A.f8d6e0586b0a20c7.ExampleNFT.Deposit", "id")

		o.Tx("transfer_nft", SignProposeAndPayAs("alice"), Arg("recipient", "bob"), Arg("withdrawID", id)).
			Test(t).AssertSuccess()

		result := o.Script("borrow_nft", Arg("address", "bob"), Arg("id", id))
		assert.NoError(t, result.Err)

	})
	/*

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
					b.ServiceKey().Signer(),
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
	*/
}
