# Flow Non-Fungible Token Standard

This standard defines the minimum functionality required to
implement a safe, secure, and easy-to-use non-fungible token
contract on the [Flow blockchain](https://www.onflow.org/).

## What is Cadence?

[Cadence is the resource-oriented programming language](https://docs.onflow.org/cadence)
for developing smart contracts on Flow.

Before reading this standard,
we recommend completing the [Cadence tutorials](https://docs.onflow.org/cadence/tutorial/01-first-steps/)
to build a basic understanding of the programming language.

Resource-oriented programming, and by extension Cadence,
provides an ideal programming model for non-fungible tokens (NFTs).
Users are able to store their NFT objects directly in their accounts and transact
peer-to-peer. Learn more in this [blog post about resources](https://medium.com/dapperlabs/resource-oriented-programming-bee4d69c8f8e).

## Import Addresses

The `NonFungibleToken` and `MetadataViews` contracts are already deployed
on various networks. You can import them in your contracts from these addresses.
There is no need to deploy them yourself.

| Network         | Contract Address     |
| --------------- | -------------------- |
| Emulator/Canary | `0xf8d6e0586b0a20c7` |
| Testnet         | `0x631e88ae7f1d7c20` |
| Mainnet         | `0x1d7e57aa55817448` |

## Core features

The `NonFungibleToken` contract defines the following set of functionality
that must be included in each implementation.

Contracts that implement the `NonFungibleToken` interface are required to implement two resource interfaces:

- `NFT` - A resource that describes the structure of a single NFT.
- `Collection` - A resource that can hold multiple NFTs of the same type.

  Users typically store one collection per NFT type, saved at a well-known location in their account storage.

  For example, all NBA Top Shot Moments owned by a single user are held in a [`TopShot.Collection`](https://github.com/dapperlabs/nba-smart-contracts/blob/master/contracts/TopShot.cdc#L605) stored in their account at the path `/storage/MomentCollection`.

### Create a new NFT collection

Create a new collection using the `createEmptyCollection` function.

This function MUST return an empty collection that contains no NFTs.

Users typically save new collections to a well-known location in their account
and link the `NonFungibleToken.CollectionPublic` interface as a public capability.

```swift
let collection <- ExampleNFT.createEmptyCollection()

account.save(<-collection, to: /storage/ExampleNFTCollection)

// create a public capability for the collection
account.link<&{NonFungibleToken.CollectionPublic}>(
    /public/ExampleNFTCollection,
    target: /storage/ExampleNFTCollection
)
```

### Withdraw an NFT

Withdraw an `NFT` from a `Collection` using the [`withdraw`](contracts/ExampleNFT.cdc#L36-L42) function.
This function emits the [`Withdraw`](contracts/ExampleNFT.cdc#L12) event.

```swift
let collectionRef = account.borrow<&ExampleNFT.Collection>(from: /storage/ExampleNFTCollection)
    ?? panic("Could not borrow a reference to the owner's collection")

// withdraw the NFT from the owner's collection
let nft <- collectionRef.withdraw(withdrawID: 42)
```

### Deposit an NFT

Deposit an `NFT` into a `Collection` using the [`deposit`](contracts/ExampleNFT.cdc#L46-L57) function.
This function emits the [`Deposit`](contracts/ExampleNFT.cdc#L13) event.

This function is available on the `NonFungibleToken.CollectionPublic` interface,
which accounts publish as public capability.
This capability allows anybody to deposit an NFT into a collection
without accessing the entire collection.

```swift
let nft: ExampleNFT.NFT

// ...

let collection = account.getCapability(/public/ExampleNFTCollection)
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

```swift
let token <- token as! @ExampleNFT.NFT
```

### List NFTs in an account

Return a list of NFTs in a `Collection` using the [`getIDs`](contracts/ExampleNFT.cdc#L59-L62) function.

This function is available on the `NonFungibleToken.CollectionPublic` interface,
which accounts publish as public capability.

```swift
let collection = account.getCapability(/public/ExampleNFTCollection)
    .borrow<&{NonFungibleToken.CollectionPublic}>()
    ?? panic("Could not borrow a reference to the receiver's collection")

let ids = collection.getIDs()
```

## NFT Metadata

NFT metadata is represented in a flexible and modular way using
the [standard proposed in FLIP-0636](https://github.com/onflow/flow/blob/master/flips/20210916-nft-metadata.md).

When writing an NFT contract,
you should implement the [`MetadataViews.Resolver`](contracts/MetadataViews.cdc#L3-L6) interface,
which allows your NFT to implement one or more metadata types called views.

Each view represents a different type of metadata,
such as an on-chain creator biography or an off-chain video clip.
Views do not specify or require how to store your metadata, they only specify
the format to query and return them, so projects can still be flexible with how they store their data.

### How to read metadata

This example shows how to read basic information about an NFT
including the name, description, image and owner.

**Source: [get_nft_metadata.cdc](scripts/get_nft_metadata.cdc)**

```swift
import ExampleNFT from "..."
import MetadataViews from "..."

// ...

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

// The owner is stored directly on the NFT object
let owner: Address = nft.owner!.address!

// Inspect the type of this NFT to verify its origin
let nftType = nft.getType()

// `nftType.identifier` is `A.f3fcd2c1a78f5eee.ExampleNFT.NFT`
```

### How to implement metadata

The [example NFT contract](contracts/ExampleNFT.cdc) shows how to implement metadata views.

### List of views

| Name        | Purpose                                    | Status      | Source                                              | Core view
| ----------- | ------------------------------------------ | ----------- | --------------------------------------------------- | --------------------------------------------------- |
| `NFTView`   | Basic view that includes the name, description and thumbnail. | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L32-L65)  |
| `Display`   | Return the basic representation of an NFT. | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L85-L120)  | :white_check_mark: |
| `HTTPFile`  | A file available at an HTTP(S) URL.        | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L143-L155)  |
| `IPFSFile`  | A file stored in IPFS.                     | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L157-L195) |
| `Edition`   | Return information about one or more editions for an NFT. | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L197-L229) |
| `Editions`  | Wrapper for multiple edition views.        | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L176-L187)|
| `Serial`    | Serial number for an NFT.                  | Implemented | [MetadataViews.cdc](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L258-L270)|
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

## Core views

The views marked as `Core views` are considered the minimum required views to provide a full picture of any NFT. If you want your NFT to be featured on the [Flow NFT Catalog](https://nft-catalog.vercel.app/) it should implement all of them as a pre-requisite.

## Always prefer wrappers over single views

When exposing a view that could have multiple occurrences on a single NFT, such as `Edition`, `Royalty`, `Media` or `Trait` the wrapper view should always be used, even if there is only a single occurrence. The wrapper view is always the plural version of the single view name and can be found below the main view definition in the `MetadataViews` contract.

When resolving the view, the wrapper view should be the returned value, instead of returning the single view or just an array of several occurrences of the view.

### Example

#### Preferred

```cadence
pub fun resolveView(_ view: Type): AnyStruct? {
    switch view {
        case Type<MetadataViews.Editions>():
            let editionInfo = MetadataViews.Edition(name: "Example NFT Edition", number: self.id, max: nil)
            let editionList: [MetadataViews.Edition] = [editionInfo]
            return MetadataViews.Editions(
                editionList
            )
    }
}
```

#### To be avoided

```cadence
// `resolveView` should always return the same type that was passed to it as an argument, so this is improper usage because it returns `Edition` instead of `Editions`.
pub fun resolveView(_ view: Type): AnyStruct? {
    switch view {
        case Type<MetadataViews.Editions>():
            let editionInfo = MetadataViews.Edition(name: "Example NFT Edition", number: self.id, max: nil)
            return editionInfo
    }
}
```
```cadence
// This is also improper usage because it returns `[Edition]` instead of `Editions`
pub fun resolveView(_ view: Type): AnyStruct? {
    switch view {
        case Type<MetadataViews.Editions>():
            let editionInfo = MetadataViews.Edition(name: "Example NFT Edition", number: self.id, max: nil)
            let editionList: [MetadataViews.Edition] = [editionInfo]
            return editionList
    }
}
```

## Royalty View

The `MetadataViews` contract also includes [a standard view for Royalties](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L136-L208).

This view is meant to be used by 3rd party marketplaces to take a cut of the proceeds of an NFT sale
and send it to the author of a certain NFT. Each NFT can have its own royalty view:

```cadence
pub struct Royalties {

    /// Array that tracks the individual royalties
    access(self) let cutInfos: [Royalty]
}
```

and the royalty can indicate whatever fungible token it wants to accept via the type of the generic `{FungibleToken.Receiver}` capability that it specifies:

```cadence
pub struct Royalty {
    /// Generic FungibleToken Receiver for the beneficiary of the royalty
    /// Can get the concrete type of the receiver with receiver.getType()
    /// Recommendation - Users should create a new link for a FlowToken receiver for this using `getRoyaltyReceiverPublicPath()`,
    /// and not use the default FlowToken receiver.
    /// This will allow users to update the capability in the future to use a more generic capability
    pub let receiver: Capability<&AnyResource{FungibleToken.Receiver}>

    /// Multiplier used to calculate the amount of sale value transferred to royalty receiver.
    /// Note - It should be between 0.0 and 1.0
    /// Ex - If the sale value is x and multiplier is 0.56 then the royalty value would be 0.56 * x.
    ///
    /// Generally percentage get represented in terms of basis points
    /// in solidity based smart contracts while cadence offers `UFix64` that already supports
    /// the basis points use case because its operations
    /// are entirely deterministic integer operations and support up to 8 points of precision.
    pub let cut: UFix64
}
```

If someone wants to make a listing for their NFT on a marketplace,
the marketplace can check to see if the royalty receiver accepts the seller's desired fungible token
by checking the concrete type of the reference.
If the concrete type is not the same as the type of token the seller wants to accept,
the marketplace has a few options.
They could either get the address of the receiver by using the
`receiver.owner.address` field and check to see if the account has a receiver for the desired token,
they could perform the sale without a royalty cut, or they could abort the sale
since the token type isn't accepted by the royalty beneficiary.

You can see example implementations of royalties in the `ExampleNFT` contract
and the associated transactions and scripts.

#### Important instructions for royalty receivers

If you plan to set your account as a receiver of royalties, you'll likely want to be able to accept
as many token types as possible. This won't be immediately possible at first, but eventually,
we will also design a contract that can act as a sort of switchboard for fungible tokens.
It will accept any generic fungible token and route it to the correct vault in your account. 
This hasn't been built yet, but you can still set up your account to be ready for it in the future.
Therefore, if you want to receive royalties, you should set up your account with the
[`setup_account_to_receive_royalty.cdc` transaction](https://github.com/onflow/flow-nft/blob/master/transactions/setup_account_to_receive_royalty.cdc).

This will link generic public path from `MetadataViews.getRoyaltyReceiverPublicPath()`
to your chosen fungible token for now. Then, use that public path for your royalty receiver
and in the future, you will be able to easily update the link at that path to use the
fungible token switchboard instead.

## How to propose a new view

Please open a pull request to propose a new metadata view or changes to an existing view.

## Feedback

As Flow and Cadence are still new,
we expect this standard to evolve based on feedback
from both developers and users.

We'd love to hear from anyone who has feedback. For example:

- Are there any features that are missing from the standard?
- Are the current features defined in the best way possible?
- Are there any pre and post conditions that are missing?
- Are the pre and post conditions defined well enough? Error messages?
- Are there any other actions that need an event defined for them?
- Are the current event definitions clear enough and do they provide enough information?
- Are the variable, function, and parameter names descriptive enough?
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

You can find automated tests in the `lib/go/test/nft_test.go` file. It uses the transaction templates that are contained in the `lib/go/templates/templates.go` file. Currently, these rely on a dependency from a private dapper labs repository to run, so external users will not be able to run them. We are working on making all of this public so anyone can run tests, but haven't completed this work yet.

## Bonus features

**(These could each be defined as a separate interface and standard and are probably not part of the main standard) They are not implemented in this repository yet**

10- Withdrawing tokens from someone else's Collection by using their `Provider` reference.

- approved withdraw event
- Providing a resource that only approves an account to withdraw a specific amount per transaction or per day/month/etc.
- Returning the list of tokens that an account can withdraw for another account.
- Reading the balance of the account that you have permission to send tokens for
- Owner is able to increase and decrease the approval at will, or revoke it completely
  - This is much harder than anticipated

11 - Standard for Composability/Extensibility

12 - Minting a specific amount of tokens using a specific minter resource that an owner can control

- tokens minted event
- Setting a cap on the total number of tokens that can be minted at a time or overall
- Setting a time frame where this is allowed

13 - Burning a specific amount of tokens using a specific burner resource that an owner controls

- tokens burnt event
- Setting a cap on the number of tokens that can be burned at a time or overall
- Setting a time frame where this is allowed

14 - Pausing Token transfers (maybe a way to prevent the contract from being imported? probably not a good idea)

15 - Cloning the token to create a new token with the same distribution

## License

The works in these files:

- [ExampleNFT.cdc](contracts/ExampleNFT.cdc)
- [NonFungibleToken.cdc](contracts/NonFungibleToken.cdc)

are under the [Unlicense](LICENSE).

## Deploying updates

### Testnet

```sh
TESTNET_PRIVATE_KEY=xxxx flow project deploy --update --network testnet
```
