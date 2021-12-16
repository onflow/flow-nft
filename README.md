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
is an ideal programming model for non-fungible tokens (NFTs).
Users are able to store their NFT objects directly in their accounts and transact
peer-to-peer. Learn more in this [blog post about resources](https://medium.com/dapperlabs/resource-oriented-programming-bee4d69c8f8e).

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

## Core Features (main NonFungibleToken interface)

These features are the ones that are specified in the interface for NFTs.
Please be aware, that a NFT contract that implements the interface can 
include other features in addition to these if they so wish. Also be aware
that with the way that Cadence smart contracts define objects and with how
objects can be integrated easily into other contracts, many more actions and 
features are possible even with a contract that only defines the bare minimim 
functionality.

The main interface requires that implementing types define a `NFT` resource 
and a `Collection` resource that contains and manages these NFTs.

#### 1 - Getting metadata for the token smart contract via the fields of the contract:

- Get the total number of tokens that have been created by the contract
    - `pub var totalSupply: UInt64`
- Event that gets emitted when the contract is initialized
    - `event ContractInitialized()`

#### 2 - Retrieving the token fields of an NFT in a user's collection

- unique identifier
    - `pub let id: UInt64`
- function to borrow a reference to a specific NFT in the collection
    - `pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT`
        - the caller can read fields and call functions on the NFT with
          the reference

#### 3 - Withdrawing a single token id using the `withdraw` function of the owner's collection

- withdraw event
    - `event Withdraw(id: UInt64, from: Address?)`
- Provider interface
    - `pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT`

#### 5 - Depositing a single token id using the recipient's *deposit function*

- deposit event
    - `event Deposit(id: UInt64, to: Address?)`
- Receiver interface
    - `pub fun deposit(token: @NonFungibleToken.NFT)`
    - **IMPORTANT**: In order to comply with the deposit function in the interface, an implementation MUST take a `@NonFungibleToken.NFT` resource as an argument. This means that anyone can send a resource object that conforms to `@NonFungibleToken.NFT` to a deposit function. In an implementation, you MUST cast the `token` as your specific token type before depositing it or you will deposit another token type into your collection:
    `let token <- token as! @ExampleNFT.NFT`

#### 7 - Retrieving a list of the token IDs in the collection

- `getIDs(): [UInt64]` returns an array of all the tokens in the collection

#### 8 - Creating an empty collection resource

- `pub fun createEmptyCollection(): @NonFungibleToken.NFTCollection`
- no event
- defined in the contract
- the returned collection must not contain any NFTs

#### 8 - NFTCollection Resource Destructor

- no event

## Metadata

NFT metadata is represented in a flexible and modular way using
the [standard proposed in FLIP-0636](https://github.com/onflow/flow/blob/master/flips/20210916-nft-metadata.md).

The standard `NonFungibleToken.NFT` interface implements the [Views.Resolver]() interface,
which allows an NFT to implement one or more metadata types,
called `Views`.

Each `View` represents a different kind of metadata.

- An NFT can implement multiple views

## Comparison to other Standards on Ethereum

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

# Running Automated Tests

You can find automated tests in the `lib/go/test/nft_test.go` file. It uses the transaction templates that are contained in the `lib/go/templates/templates.go` file. Currently, these rely on a dependency from a private dapper labs repository to run, so external users will not be able to run them. We are working on making all of this public so anyone can run tests, but haven't completed this work yet.

## Bonus Features 

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

The works in these folders 
/onflow/flow-NFT/blob/master/contracts/ExampleNFT.cdc 
/onflow/flow-NFT/blob/master/contracts/NonFungibleToken.cdc

are under the Unlicense
https://github.com/onflow/flow-NFT/blob/master/LICENSE

## Metadata

