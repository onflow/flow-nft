package main

import (
	"fmt"

	. "github.com/bjartek/overflow/overflow"
	"github.com/fatih/color"
)

func main() {

	color.Green("This is a demo of what overflow can do for an NFT project, in this case the example is a modified version of flow-nft repo")

	color.Green("In order to start overflow with a default in memory client you simply run")
	color.Cyan(`o := Overflow(
		StopOnError(),
		PrintInteractionResults(),
	)`)
	color.Green("This will start overflow in embedded mode, and also instruct it to stop if there are errors after scripts/transactions and print the results of them with the embedded emulator log. ")

	pause()
	o := Overflow(
		StopOnError(),
		PrintInteractionResults(),
	)

	fmt.Println("")
	color.Green(`We now have an running version of 'Overflow' in embedded mode, it automatically deployed all contracts for the serviceAccount that was specified in flow.json and created all other empty accounts. 

In our case we deployed contracts and created the users alice and bob.`)

	pause()

	color.Green("Running an transaction in overflow is don by calling the `Tx` method on the `o` or overflow object")
	color.Cyan(`o.Tx("setup_account", SignProposeAndPayAs("alice"))`)
	color.Green("")
	color.Green("that line will run the transaction `setup_account` from the `transactions/` folder, sign is as the demo user `alice` it will also print out the result in a nice terse way")

	color.Green("note that when we refer to users by name in overflow we do not use the network prefix, this is so that you can have the same stakeholders on mainnet/testnet if you want to without chaning the code. So in flow.json the account for alice is called 'emulator-alice'")

	pause()
	o.Tx("setup_account", SignProposeAndPayAs("alice"))

	color.Green("so we now have set up alice, lets set up bob and also setup their royalty receivers")

	color.Cyan(`
	o.Tx("setup_account", 
		SignProposeAndPayAs("bob")
	)

	o.Tx("setup_account_to_receive_royalty", 
		SignProposeAndPayAs("alice"), 
		Arg("vaultPath", "/storage/flowTokenVault"),
	)
	o.Tx("setup_account_to_receive_royalty", 
		SignProposeAndPayAs("bob"), 
		Arg("vaultPath", "/storage/flowTokenVault"),
	)	
	`)

	o.Tx("setup_account",
		SignProposeAndPayAs("bob"),
	)
	o.Tx("setup_account_to_receive_royalty",
		SignProposeAndPayAs("alice"),
		Arg("vaultPath", "/storage/flowTokenVault"),
	)
	o.Tx("setup_account_to_receive_royalty",
		SignProposeAndPayAs("bob"),
		Arg("vaultPath", "/storage/flowTokenVault"),
	)

	color.Green("Everything is now ready to mint an NFT into alice collection!")

	pause()

	color.Green(`Minting is running another transaction but in thise case we have a lot more arguments to the transaction.

In overflow v1 all arguments are _named_ that is you mention them by their name and the value and not the order they appear in the transaction. If you use the wrong names and types then overflow will let you know with an terse appropritate error message`)

	color.Cyan(`
  id,_ :=o.Tx("mint_nft", 
	  SignProposeAndPayAsServiceAccount(),
		Arg("recipient", "alice"),
		Arg("name", "Example NFT 0"),
		Arg("description", "This is an example NFT"),
		Arg("thumbnail", "example.jpeg"),
		Arg("cuts", "[0.25, 0.40]"),
		Arg("royaltyDescriptions", ` + "`" + `["minter","creator"]` + "`" + `'),
		Addresses("royaltyBeneficiaries", "alice", "bob")).
		GetIdFromEvent("Deposit", "id")
		`)

	color.Green("Most arguments in overflow are sent using the `Arg` method but there are some other helpfull methods, in this case we use `Addresses` to erturn a list of addresses. As you can see we can use the logical name of the account in flow.json and it will replace that with the address in the transaction")

	color.Green("We can also see that after we have run and printed the result we can fetch out data from the events in the transaction, in this case we fetch out the first entry of an event that has the suffix Deposit and we fetch the id `id` field as an UInt64. This is a convenience method that was added since this is a very normal pattern")

	pause()

	id, _ := o.Tx("mint_nft", SignProposeAndPayAsServiceAccount(),
		Arg("recipient", "alice"),
		Arg("name", "Example NFT 0"),
		Arg("description", "This is an example NFT"),
		Arg("thumbnail", "example.jpeg"),
		Arg("cuts", "[0.25, 0.40]"),
		Arg("royaltyDescriptions", `["minter","creator"]`),
		Addresses("royaltyBeneficiaries", "alice", "bob")).
		GetIdFromEvent("Deposit", "id")

	color.Green("We now have an NFT that is minted with id %d that we can run some scripts against!\n", id)

	pause()

	color.Green("A script is run in very much the same way as a Transaction only it uses the `Script` method like the following example")
	color.Cyan(`o.Script("get_nft_metadata", Arg("address", "alice"), Arg("id", id))`)

	pause()
	o.Script("get_nft_metadata", Arg("address", "alice"), Arg("id", id))

	color.Green("And that is the metadata of the nft that we just minted, hope you like what overflow can do to tell a story! Oh and if you want to run this story against `testnet` you can easily do that. At .find we use overflow to run system.d job, cronjobs, serverless functions and lots of things. it is the green goo that keeps everything (over)flowing")

}

func pause() {
	fmt.Println()
	color.Yellow("press any key to continue")
	fmt.Scanln()
	fmt.Println()
}
