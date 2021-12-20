# Flow Non-Fungible Token Standard

This standard defines the minimum functionality required to 
implement a safe, secure, and easy-to-use non-fungible token 
contract on the [Flow blockchain](https://www.onflow.org/).

## What is Cadence?

[Cadence is the resource-oriented programming language](https://docs.onflow.org/cadence)
for developing smart contracts on the Flow blockchain.

Before reading this standard, 
we recommend completing the [Cadence tutorials](https://docs.onflow.org/cadence/tutorial/01-first-steps/) 
to build a basic understanding of the programming language.

Resource-oriented programming, and by extension Cadence, 
provides an ideal programming model for non-fungible tokens (NFTs).
Users are able to store their NFT objects directly in their accounts and transact
peer-to-peer. Learn more in this [blog post about resources](https://medium.com/dapperlabs/resource-oriented-programming-bee4d69c8f8e).

## Core features

The `NonFungibleToken` contract defines the following set of functionality
that must be included in each implementation.

Contracts that implement the `NonFungibleToken` interface are required to implement two resource interfaces:

- `NFT` -  A resource that describes the structure of a single NFT.
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
````

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

### Read an NFT from an account

Obtain a reference to a specific NFT in a `Collection` using the [`borrowNFT`]() function.

This only returns a reference to the NFT resource, not the resource itself.
However, the caller can read fields on the NFT and call public functions.

```swift
let collection = account.getCapability(/public/ExampleNFTCollection)
    .borrow<&{NonFungibleToken.CollectionPublic}>()
    ?? panic("Could not borrow a reference to the receiver's collection")

let nftRef = collection.borrowNFT(id: 42)

log(nftRef.id)
```

## Metadata

NFT metadata is represented in a flexible and modular way using
the [standard proposed in FLIP-0636](https://github.com/onflow/flow/blob/master/flips/20210916-nft-metadata.md).

The `NonFungibleToken.NFT` interface implements the [Views.Resolver]() interface,
which allows an NFT to implement one or more metadata types called `Views`.

Each `View` represents a different type of metadata, 
such as an on-chain creator biography or an off-chain video clip.

### Display view

The [`Display`]() view is the most basic metadata view.
It returns the minimum information required to render an NFT in most applications.

```swift
let collection = account.getCapability(/public/ExampleNFTCollection)
    .borrow<&{NonFungibleToken.CollectionPublic}>()
    ?? panic("Could not borrow a reference to the receiver's collection")

let nftRef = collection.borrowNFT(id: 42)

if let view = nftRef.resolveView(Type<Views.Display>()) {
  let display = view as! Views.Display
  log(display.name)
  log(display.thumbnail)
  log(display.description)
}
```

### Full list of views

|Name|Purpose|Source|
|----|-------|------|
|`Display`|Render the basic representation of an NFT.|[Views](contracts/Views.cdc)|

### How to propose a new view

If you want to propose a new metadata view, 
or changes to an existing view, 
please create an issue in this repository.

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
- Easy ownership indexing: rathing than iterating through all tokens to find which ones you own, you have them all stored in your account's collection and can get the list of the ones you own instantly.

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
