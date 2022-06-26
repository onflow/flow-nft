package main

import (
	. "github.com/bjartek/overflow/overflow"
)

func main() {

	o := Overflow(WithBasePath("../../.."), WithScriptFolderName("transactions/scripts"))

	o.Tx("setup_account_to_receive_royalty", SignProposeAndPayAs("alice"), Arg("vaultPath", "/storage/flowTokenVault")).Print()
	o.Tx("setup_account_to_receive_royalty", SignProposeAndPayAs("bob"), Arg("vaultPath", "/storage/flowTokenVault")).Print()
	/*
		o.Tx("setup_account", SignProposeAndPayAs("alice")).Print()
		o.Tx("setup_account", SignProposeAndPayAs("bob")).Print()
		o.Tx("setup_account_to_receive_royalty", SignProposeAndPayAs("bob")).Print()

		o.Tx("mint_nft", SignProposeAndPayAsServiceAccount(),
			Arg("recipient", "alice"),
			Arg("name", "Example NFT 0"),
			Arg("description", "This is an example NFT"),
			Arg("thumbnail", "example.jpeg"),
			Arg("cuts", "[0.25, 0.40]"),
			Arg("royaltyDescriptions", `["minter","creator"]`),
			Addresses("royaltyBeneficiaries", "alice", "bob")).Print()
	*/

}
