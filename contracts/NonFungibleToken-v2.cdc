/**

## The Flow Non-Fungible Token standard

## `NonFungibleToken` contract interface

The interface that all Non-Fungible Token contracts could conform to.
If a user wants to deploy a new NFT contract, their contract would need
to implement the NonFungibleToken interface.

Their contract would have to follow all the rules and naming
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

import MetadataViews from "./MetadataViews.cdc"

/// The main NFT contract interface. Other NFT contracts will
/// import and implement this interface
///
pub contract NonFungibleToken {

    /// Interface that the NFTs have to conform to
    ///
    pub resource interface NFT { //: MetadataViews.Resolver {
        /// The unique ID that each NFT has
        pub let id: UInt64

        pub fun getViews(): [Type]
        pub fun resolveView(_ view: Type): AnyStruct?
    }

    /// Interface to mediate withdraws from the Collection
    ///
    pub resource interface Provider {
        /// withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @AnyResource{NFT} {
            post {
                result.id == withdrawID: "The ID of the withdrawn token must be the same as the requested ID"
            }
        }
    }

    /// Interface to mediate withdraws from the Collection
    ///
    pub resource interface Transferable {
        /// withdraw removes an NFT from the collection and moves it to the caller
        pub fun transfer(id: UInt64, receiver: Capability<&AnyResource{Receiver}>): @AnyResource{NFT}
    }

    /// Interface to mediate deposits to the Collection
    ///
    pub resource interface Receiver {

        /// deposit takes an NFT as an argument and adds it to the Collection
        ///
        pub fun deposit(token: @AnyResource{NFT})

        /// getAcceptedTypes returns a list of NFT types that this receiver accepts
        pub fun getAcceptedTypes(): [Type]
    }

    /// Interface that an account would commonly 
    /// publish for their collection
    pub resource interface CollectionPublic { //: MetadataViews.ResolverCollection {
        pub fun deposit(token: @AnyResource{NFT})
        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver}
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &AnyResource{NFT}
    }

    /// Requirement for the concrete resource type
    /// to be declared in the implementing contract
    ///
    pub resource interface Collection { //: Provider, Receiver, Transferable, CollectionPublic, MetadataViews.ResolverCollection {

        /// Paths for the collection
        pub let storagePath: StoragePath
        pub let publicPath: PublicPath
        pub let privateProviderPath: PrivatePath

        /// Dictionary to hold the NFTs in the Collection
        /// Normally we would require that the collection specify
        /// a specific dictionary to store the NFTs, but this isn't necessary any more
        /// as long as all the other functions are there

        /// Returns the NFT types that this collection can store
        pub fun getAcceptedTypes(): [Type]

        /// withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @AnyResource{NFT}

        /// deposit takes a NFT and adds it to the collections dictionary
        /// and adds the ID to the id array
        pub fun deposit(token: @AnyResource{NFT})

        /// Function for a direct transfer instead of having to do a deposit and withdrawal
        ///
        pub fun transfer(id: UInt64, recipient: Capability<&{NonFungibleToken.Receiver}>): Bool

        /// getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64]

        /// Returns a borrowed reference to an NFT in the collection
        /// so that the caller can read data and call methods from it
        pub fun borrowNFT(id: UInt64): &AnyResource{NonFungibleToken.NFT}?

        /// From the MetadataViews Contract
        /// borrows a reference to get metadata views for the NFTs that the contract contains
        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver}

        /// createEmptyCollection creates an empty Collection
        /// and returns it to the caller so that they can own NFTs
        pub fun createEmptyCollection(): @{Collection} {
            post {
                result.getIDs().length == 0: "The created collection must be empty!"
            }
        }
    }

    /// Verifies that the array of types are actually collection types
    pub fun verifyCollectionTypes(_ types: [Type]): Bool {
        for type in types {
            if !type.isSubtype(of: Type<@{NonFungibleToken.Collection}>()) {
                return false
            }
        }
        return true
    }
}
