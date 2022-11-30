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

/// The main NFT contract interface. Other NFT contracts will
/// import and implement this interface
///
pub contract interface NonFungibleToken {

    /// The total number of tokens of this type in existence
    pub var totalSupply: UInt64

    /// Event that emitted when the NFT contract is initialized
    ///
    pub event ContractInitialized()

    /// Event that is emitted when a token is withdrawn,
    /// indicating the owner of the collection that it was withdrawn from.
    ///
    /// If the collection is not in an account's storage, `from` will be `nil`.
    ///
    pub event Withdraw(id: UInt64, from: Address?)

    /// Event that emitted when a token is deposited to a collection.
    ///
    /// It indicates the owner of the collection that it was deposited to.
    ///
    pub event Deposit(id: UInt64, to: Address?)

    /// Interface that the NFTs have to conform to
    /// The metadata views methods are included here temporarily
    /// because enforcing the metadata interfaces in the standard
    /// would break many contracts in an upgrade. Those breaking changes
    /// are being saved for the stable cadence milestone
    ///
    pub resource interface INFT {
        /// The unique ID that each NFT has
        pub let id: UInt64

        /// Function that returns all the Metadata Views implemented by a Non Fungible Token
        ///
        /// @return An array of Types defining the implemented views. This value will be used by
        ///         developers to know which parameter to pass to the resolveView() method.
        ///
        pub fun getViews(): [Type] {
            return []
        }

        /// Function that resolves a metadata view for this token.
        ///
        /// @param view: The Type of the desired view.
        /// @return A structure representing the requested view.
        ///
        pub fun resolveView(_ view: Type): AnyStruct? {
            return nil
        }
    }

    /// Requirement that all conforming NFT smart contracts have
    /// to define a resource called NFT that conforms to INFT
    ///
    pub resource NFT: INFT {
        pub let id: UInt64
    }

    /// Interface to mediate withdraws from the Collection
    ///
    pub resource interface Provider {
        /// Removes an NFT from the resource implementing it and moves it to the caller
        ///
        /// @param withdrawID: The ID of the NFT that will be removed
        /// @return The NFT resource removed from the implementing resource
        ///
        pub fun withdraw(withdrawID: UInt64): @NFT {
            post {
                result.id == withdrawID: "The ID of the withdrawn token must be the same as the requested ID"
            }
        }
    }

    /// Interface to mediate deposits to the Collection
    ///
    pub resource interface Receiver {

        /// Adds an NFT to the resource implementing it
        ///
        /// @param token: The NFT resource that will be deposited
        ///
        pub fun deposit(token: @NFT)
    }

    /// Interface that an account would commonly 
    /// publish for their collection
    ///
    pub resource interface CollectionPublic {
        pub fun deposit(token: @NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NFT
        /// Safe way to borrow a reference to an NFT that does not panic
        ///
        /// @param id: The ID of the NFT that want to be borrowed
        /// @return An optional reference to the desired NFT, will be nil if the passed id does not exist
        ///
        pub fun borrowNFTSafe(id: UInt64): &NFT? {
            post {
                result == nil || result!.id == id: "The returned reference's ID does not match the requested ID"
            }
            return nil
        }
    }

    /// Requirement for the concrete resource type
    /// to be declared in the implementing contract
    ///
    pub resource Collection: Provider, Receiver, CollectionPublic {

        /// Dictionary to hold the NFTs in the Collection
        pub var ownedNFTs: @{UInt64: NFT}

        /// Removes an NFT from the collection and moves it to the caller
        ///
        /// @param withdrawID: The ID of the NFT that will be withdrawn
        /// @return The resource containing the desired NFT
        ///
        pub fun withdraw(withdrawID: UInt64): @NFT

        /// Takes a NFT and adds it to the collections dictionary
        /// and adds the ID to the ID array
        /// 
        /// @param token: An NFT resource
        ///
        pub fun deposit(token: @NFT)

        /// Returns an array of the IDs that are in the collection
        ///
        /// @return An array containing all the IDs on the collection
        ///
        pub fun getIDs(): [UInt64]

        /// Returns a borrowed reference to an NFT in the collection
        /// so that the caller can read data and call methods from it
        ///
        /// @param id: The ID of the NFT that want to be borrowed
        /// @return A reference to the NFT
        ///
        pub fun borrowNFT(id: UInt64): &NFT {
            pre {
                self.ownedNFTs[id] != nil: "NFT does not exist in the collection!"
            }
        }
    }

    /// Creates an empty Collection and returns it to the caller so that they can own NFTs
    ///
    /// @return A new Collection resource
    /// 
    pub fun createEmptyCollection(): @Collection {
        post {
            result.getIDs().length == 0: "The created collection must be empty!"
        }
    }
}
 