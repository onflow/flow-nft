/**

## The Flow Non-Fungible Token standard

## `NonFungibleToken` contract interface

The interface that all Non-Fungible Token contracts should conform to.
If a user wants to deploy a new NFT contract, their contract would need
to implement the NonFungibleToken interface.

Their contract must follow all the rules and naming
that the interface specifies.

## `NFT` resource

The core resource type that represents an NFT in the smart contract.

## `Collection` Resource

The resource that stores a user's NFT collection.
It includes a few functions to allow the owner to easily
move tokens in and out of the collection.

## `Provider` and `Receiver` resource interfaces

These interfaces declare functions with some pre and post conditions
that require the Collection to follow certain naming and behavior standards.

They are separate because it gives the user the ability to share a reference
to their Collection that only exposes the fields and functions in one or more
of the interfaces. It also gives users the ability to make custom resources
that implement these interfaces to do various things with the tokens.

By using resources and interfaces, users of NFT smart contracts can send
and receive tokens peer-to-peer, without having to interact with a central ledger
smart contract.

To send an NFT to another user, a user would simply withdraw the NFT
from their Collection, then call the deposit function on another user's
Collection to complete the transfer.

*/

import ViewResolver from "ViewResolver"

/// The main NFT contract interface. Other NFT contracts will
/// import and implement this interface
///
access(all) contract NonFungibleToken {

    /// An entitlement for allowing the withdrawal of tokens from a Vault
    access(all) entitlement Withdrawable

    /// An entitlement for allowing updates and update events for an NFT
    access(all) entitlement Updatable

    /// Event that contracts should emit when the metadata of an NFT is updated
    /// It can only be emitted by calling the `emitNFTUpdated` function
    /// with an `Updatable` entitled reference to the NFT that was updated
    /// The entitlement prevents spammers from calling this from other users' collections
    /// because only code within a collection or that has special entitled access
    /// to the collections methods will be able to get the entitled reference
    /// 
    /// The event makes it so that third-party indexers can monitor the events
    /// and query the updated metadata from the owners' collections.
    ///
    access(all) event Updated(id: UInt64, uuid: UInt64, owner: Address?, type: String)
    access(all) view fun emitNFTUpdated(_ nftRef: auth(Updatable) &{NonFungibleToken.NFT})
    {
        emit Updated(id: nftRef.getID(), uuid: nftRef.uuid, owner: nftRef.owner?.address, type: nftRef.getType().identifier)
    }


    /// Event that is emitted when a token is withdrawn,
    /// indicating the owner of the collection that it was withdrawn from.
    ///
    /// If the collection is not in an account's storage, `from` will be `nil`.
    ///
    access(all) event Withdraw(id: UInt64, uuid: UInt64, from: Address?, type: String)

    /// Event that emitted when a token is deposited to a collection.
    ///
    /// It indicates the owner of the collection that it was deposited to.
    ///
    access(all) event Deposit(id: UInt64, uuid: UInt64, to: Address?, type: String)

    /// Interface that the NFTs must conform to
    ///
    access(all) resource interface NFT: ViewResolver.Resolver {
        /// The unique ID that each NFT has
        access(all) view fun getID(): UInt64

        // access(all) event ResourceDestroyed(uuid: UInt64 = self.uuid, type: self.getType().identifier)

        /// Get a reference to an NFT that this NFT owns
        /// Both arguments are optional to allow the NFT to choose
        /// how it returns sub NFTs depending on what arguments are provided
        /// For example, if `type` has a value, but `id` doesn't, the NFT 
        /// can choose which NFT of that type to return if there is a "default"
        /// If both are `nil`, then NFTs that only store a single NFT can just return
        /// that. This helps callers who aren't sure what they are looking for 
        ///
        /// @param type: The Type of the desired NFT
        /// @param id: The id of the NFT to borrow
        ///
        /// @return A structure representing the requested view.
        access(all) fun getSubNFT(type: Type, id: UInt64) : &{NonFungibleToken.NFT}? {
            return nil
        }
    }

    /// Interface to mediate withdraws from the Collection
    ///
    access(all) resource interface Provider {

        // We emit withdraw events from the provider interface because conficting withdraw
        // events aren't as confusing to event listeners as conflicting deposit events

        /// withdraw removes an NFT from the collection and moves it to the caller
        /// It does not specify whether the ID is UUID or not
        access(Withdrawable) fun withdraw(withdrawID: UInt64): @{NFT} {
            post {
                result.getID() == withdrawID: "The ID of the withdrawn token must be the same as the requested ID"
                emit Withdraw(id: result.getID(), uuid: result.uuid, from: self.owner?.address, type: result.getType().identifier)
            }
        }
    }

    /// Interface to mediate deposits to the Collection
    ///
    access(all) resource interface Receiver {

        /// deposit takes an NFT as an argument and adds it to the Collection
        ///
        access(all) fun deposit(token: @{NFT})

        /// getSupportedNFTTypes returns a list of NFT types that this receiver accepts
        access(all) view fun getSupportedNFTTypes(): {Type: Bool}

        /// Returns whether or not the given type is accepted by the collection
        /// A collection that can accept any type should just return true by default
        access(all) view fun isSupportedNFTType(type: Type): Bool
    }

    /// Requirement for the concrete resource type
    /// to be declared in the implementing contract
    ///
    access(all) resource interface Collection: Provider, Receiver, ViewResolver.ResolverCollection {

        /// Return the default storage path for the collection
        access(all) view fun getDefaultStoragePath(): StoragePath?

        /// Return the default public path for the collection
        access(all) view fun getDefaultPublicPath(): PublicPath?

        /// Normally we would require that the collection specify
        /// a specific dictionary to store the NFTs, but this isn't necessary any more
        /// as long as all the other functions are there

        /// createEmptyCollection creates an empty Collection
        /// and returns it to the caller so that they can own NFTs
        access(all) fun createEmptyCollection(): @{Collection} {
            post {
                result.getLength() == 0: "The created collection must be empty!"
            }
        }

        /// deposit takes a NFT and adds it to the collections dictionary
        /// and adds the ID to the id array
        access(all) fun deposit(token: @{NonFungibleToken.NFT}) {
            pre {
                // We emit the deposit event in the `Collection` interface
                // because the `Collection` interface is almost always the final destination
                // of tokens and deposit emissions from custom receivers could be confusing
                // and hard to reconcile to event listeners
                emit Deposit(id: token.getID(), uuid: token.uuid, to: self.owner?.address, type: token.getType().identifier)
            }
        }

        /// Gets the amount of NFTs stored in the collection
        access(all) view fun getLength(): Int

        access(all) view fun borrowNFT(_ id: UInt64): &{NonFungibleToken.NFT}? {
            post {
                (result == nil) || (result?.getID() == id): 
                    "Cannot borrow NFT reference: The ID of the returned reference does not match the ID that was specified"
            }
            return nil
        }
    }
}
