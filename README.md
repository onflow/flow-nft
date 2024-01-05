# Flow Non-Fungible Token Standard

This standard defines the minimum functionality required to
implement a safe, secure, and easy-to-use non-fungible token
contract on the [Flow blockchain](https://flow.com/

## What is Cadence?

[Cadence is the resource-oriented programming language](https://cadence-lang.org/)
for developing smart contracts on Flow.

Before reading this standard,
we recommend completing the [Cadence tutorials](https://cadence-lang.org/docs/tutorial/first-steps)
to build a basic understanding of the programming language.

Resource-oriented programming, and by extension Cadence,
provides an ideal programming model for non-fungible tokens (NFTs).
Users are able to store their NFT objects directly in their accounts and transact
peer-to-peer. Learn more in this [blog post about resources](https://medium.com/dapperlabs/resource-oriented-programming-bee4d69c8f8e).

## Import Addresses

The `NonFungibleToken`, `ViewResolver`, and `MetadataViews` contracts are already deployed
on various networks. You can import them in your contracts from these addresses.
There is no need to deploy them yourself.

Note: With the emulator, you must use the -contracts flag to deploy these contracts.

| Network         | Contract Address     |
| --------------- | -------------------- |
| Emulator/Canary | `0xf8d6e0586b0a20c7` |
| Testnet         | `0x631e88ae7f1d7c20` |
| Mainnet         | `0x1d7e57aa55817448` |

## Core Types

Contracts that implement the `NonFungibleToken` interface are required to implement two resource interfaces:

- `NFT` - A resource that describes the structure of a single NFT.
- `Collection` - A resource that can hold multiple NFTs of the same type and defines ways
  to deposit, withdraw, and query information about the stored NFTs.

  Users typically store one collection per NFT type, saved at a well-known location in their account storage.

  For example, all NBA Top Shot Moments owned by a single user are held in a [`TopShot.Collection`](https://github.com/dapperlabs/nba-smart-contracts/blob/master/contracts/TopShot.cdc#L605) stored in their account at the path `/storage/MomentCollection`.

## Core Features

The `NonFungibleToken` contract defines the following set of functionality
that must be included in each implementation:

### Create a new NFT collection

Create a new collection using the `Token.createEmptyCollection()` function.

This function MUST return an empty collection that contains no NFTs.

Users typically save new collections to a contract-defined location in their account
and link the `NonFungibleToken.CollectionPublic` interface as a public capability.

```cadence
let collection <- ExampleNFT.createEmptyCollection()

account.save(<-collection, to: ExampleNFT.CollectionStoragePath)

// create a public capability for the collection
account.link<&{NonFungibleToken.CollectionPublic}>(
    ExampleNFT.CollectionPublicPath,
    target: ExampleNFT.CollectionStoragePath
)
```

### Withdraw an NFT

Withdraw an `NFT` from a `Collection` using the [`withdraw()`](contracts/ExampleNFT.cdc#L36-L42) function.
This function emits the [`Withdraw`](contracts/ExampleNFT.cdc#L12) event.

```cadence
let collectionRef = account.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)
    ?? panic("Could not borrow a reference to the owner's collection")

// withdraw the NFT from the owner's collection
let nft <- collectionRef.withdraw(withdrawID: 42)
```

### Deposit an NFT

Deposit an `NFT` into a `Collection` using the [`deposit()`](contracts/ExampleNFT.cdc#L46-L57) function.
This function emits the [`Deposit`](contracts/ExampleNFT.cdc#L13) event.

This function is available on the `NonFungibleToken.CollectionPublic` interface,
which accounts publish as public capability.
This capability allows anybody to deposit an NFT into a collection
without accessing the entire collection.

```cadence
let nft: ExampleNFT.NFT

// ...

let collection = account.getCapability(ExampleNFT.CollectionPublicPath)
    .borrow<&{NonFungibleToken.CollectionPublic}>()
    ?? panic("Could not borrow a reference to the receiver's collection")

collection.deposit(token: <-nft)
```

#### ⚠️ Important

In order to comply with the deposit function in the interface,
an implementation MUST take a `@NonFungibleToken.NFT` resource as an argument.
This means that anyone can send a resource object that conforms to `@NonFungibleToken.NFT` to a deposit function.
In an implementation, you MUST cast the `token` as your specific token type before depositing it or you will
deposit another token type into your collection. For example:

```cadence
/// `ExampleNFT` much be changed to the name of your contract
let token <- token as! @ExampleNFT.NFT
```

### List NFTs in an account

Return a list of NFTs in a `Collection` using the [`getIDs`](contracts/ExampleNFT.cdc#L59-L62) function.

This function is available on the `NonFungibleToken.CollectionPublic` interface,
which accounts publish as public capability.

```cadence
let collection = account.getCapability(ExampleNFT.CollectionPublicPath)
    .borrow<&{NonFungibleToken.CollectionPublic}>()
    ?? panic("Could not borrow a reference to the receiver's collection")

let ids = collection.getIDs()
```

## NFT Metadata

The primary documentation for metadata views is on [the Flow developer portal](https://developers.flow.com/build/advanced-concepts/metadata-views).
Please refer to that for the most thorough exploration of the views with examples.

NFT metadata is represented in a flexible and modular way using
the [standard proposed in FLIP-0636](https://github.com/onflow/flips/blob/main/application/20210916-nft-metadata.md).

When writing an NFT contract,
you should implement the [`MetadataViews.Resolver`](contracts/MetadataViews.cdc#L3-L6) interface,
which allows your NFT to utilize one or more metadata types called views.

Each view represents a different type of metadata,
such as an on-chain creator biography or an off-chain video clip.
Views do not specify or require how to store your metadata, they only specify
the format to query and return them, so projects can still be flexible with how they store their data.

### How to read metadata

This example shows how to read basic information about an NFT
including the name, description, image and owner.

**Source: [get_nft_metadata.cdc](scripts/get_nft_metadata.cdc)**

```cadence
// Get the regular public capability
let collection = account.getCapability(ExampleNFT.CollectionPublicPath)
    .borrow<&{ExampleNFT.ExampleNFTCollectionPublic}>()
    ?? panic("Could not borrow a reference to the collection")

// Borrow a reference to the NFT as usual
let nft = collection.borrowExampleNFT(id: 42)
    ?? panic("Could not borrow a reference to the NFT")

// Call the resolveView method
// Provide the type of the view that you want to resolve
// View types are defined in the MetadataViews contract
// You can see if an NFT supports a specific view type by using the `getViews()` method
if let view = nft.resolveView(Type<MetadataViews.Display>()) {
    let display = view as! MetadataViews.Display

    log(display.name)
    log(display.description)
    log(display.thumbnail)
}
```

### How to implement metadata

The [example NFT contract](contracts/ExampleNFT.cdc) shows a basic example
for how to implement metadata views.

### List of views

The views marked as `Core views` are considered the minimum required views to provide a full picture of any NFT. If you want your NFT to be able to be easily accessed and understood by third-party apps such as the [Flow NFT Catalog](https://nft-catalog.vercel.app/) it should implement all of them as a pre-requisite.

| Name        | Purpose                                    | Status      | Source                                              | Core view
| ----------- | ------------------------------------------ | ----------- | --------------------------------------------------- | --------------------------------------------------- |
| `NFTView`   | Basic view that includes the name, description and thumbnail. | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L32-L65)  |
| `Display`   | Return the basic representation of an NFT. | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L85-L120)  | :white_check_mark: |
| `HTTPFile`  | A file available at an HTTP(S) URL.        | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L143-L155)  |
| `IPFSFile`  | A file stored in IPFS.                     | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L157-L195) |
| `Edition`   | Return information about one or more editions for an NFT. | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L197-L229) |
| `Editions`  | Wrapper for multiple edition views.        | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L176-L187)|
| `Serial`    | Serial number for an NFT.                  | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L258-L270)| :white_check_mark: |
| `Royalty`   | A Royalty Cut for a given NFT.             | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L286-L323) |
| `Royalties` | Wrapper for multiple Royalty views.        | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L325-L352) | :white_check_mark: |
| `Media`     | Represents a file with a corresponding mediaType | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L378-L395)|
| `Medias`    | Wrapper for multiple Media views.          | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L397-L407)|
| `License`   | Represents a license according to https://spdx.org/licenses/ | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L423-L432)|
| `ExternalURL`| Exposes a URL to an NFT on an external site. | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L448-L458)| :white_check_mark: |
| `NFTCollectionData` | Provides storage and retrieval information of an NFT | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L474-L531) | :white_check_mark: |
| `NFTCollectionDisplay` | Returns the basic representation of an NFT's Collection.  | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L547-L586) | :white_check_mark: |
| `Rarity`   | Expose rarity information for an NFT        | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L603-L628)|
| `Trait`    | Represents a single field of metadata on an NFT. | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L644-L671)|
| `Traits`   | Wrapper for multiple Trait views            | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L673-L690)| :white_check_mark: |

## How to propose a new view

Please open a issue or a pull request to propose a new metadata view
or changes to an existing view.

## Feedback

We'd love to hear from anyone who has feedback. For example:

- Are there any features that are missing from the standard?
- Are the current features defined in the best way possible?
- Are there any pre and post conditions that are missing?
- Are the pre and post conditions defined well enough? Error messages?
- Are there any other actions that need an event defined for them?
- Are the current event definitions clear enough and do they provide enough information?
- Are there any openings for bugs or vulnerabilities that we are not noticing?

Please create an issue in this repository if there is a feature that
you believe needs discussing or changing.

## Comparison to other standards on Ethereum

This standard covers much of the same ground as ERC-721 and ERC-1155,
but without most of the downsides.

- Tokens cannot be sent to contracts that don't understand how to use them, because an account needs to have a `Receiver` or `Collection` in its storage to receive tokens.
- If the recipient is a contract that has a stored `Collection`, the tokens can just be deposited to that Collection without having to do a clunky `approve`, `transferFrom`.
- Events are defined in the contract for withdrawing and depositing, so a recipient will always be notified that someone has sent them tokens with their own deposit event.
- This version can support batch transfers of NFTs. Even though it isn't explicitly defined in the contract, a batch transfer can be done within a transaction by just withdrawing all the tokens to transfer, then depositing them wherever they need to be, all atomically.
- Transfers can trigger actions because users can define custom `Receivers` to execute certain code when a token is sent.
- Easy ownership indexing: rather than iterating through all tokens to find which ones you own, you have them all stored in your account's collection and can get the list of the ones you own instantly.

## How to test the standard

If you want to test out these contracts, we recommend either testing them
with the [Flow Playground](https://play.onflow.org)
or with the [Visual Studio Code Extension](https://github.com/onflow/flow/blob/master/docs/vscode-extension.md#cadence-visual-studio-code-extension).

The steps to follow are:

1. Deploy `NonFungibleToken.cdc`
2. Deploy `ExampleNFT.cdc`, importing `NonFungibleToken` from the address you deployed it to.

Then you can experiment with some of the other transactions and scripts in `transactions/`
or even write your own. You'll need to replace some of the import address placeholders with addresses that you deploy to, as well as some of the transaction arguments.

## Running automated tests

You can find automated tests written in the
[Cadence testing framework](https://developers.flow.com/build/smart-contracts/testing)
in the `tests/` directory.
Use `flow test tests/test_example_nft.cdc` to run these tests.

More tests, written in Go, are in the `lib/go/test/` directory.
They use the transaction templates package that is contained in the `lib/go/templates/` directory.
To run the Go tests, you can run `make test` from the repository root.
Contract and transaction assets must be generated before individual tests can be run,
so if you are wanting to run the tests individually via `go test`,
you must run `make generate` from within the `lib/go/` directory
after every revision you make to the contract or transaction files.

## License

The works in these files:

- [ExampleNFT.cdc](contracts/ExampleNFT.cdc)
- [NonFungibleToken.cdc](contracts/NonFungibleToken.cdc)
- [MetadataViews.cdc](contracts/MetadataViews.cdc)
- [ViewResolver.cdc](contracts/ViewResolver.cdc)

are under the [Unlicense](LICENSE).
