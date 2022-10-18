/* 
*
*  This is an example implementation of a Flow Non-Fungible Token
*  using the V2 standard.
*  It is not part of the official standard but it assumed to be
*  similar to how many NFTs would implement the core functionality.
*
*  This contract does not implement any sophisticated classification
*  system for its NFTs. It defines a simple NFT with minimal metadata.
*   
*/

import NonFungibleToken from "./NonFungibleToken-v2.cdc"
import MetadataViews from "./MetadataViews.cdc"

pub contract ExampleNFT: NonFungibleToken {

    /// Standard events from the NonFungibleToken Interface

    pub event Withdraw(id: UInt64, from: Address?, type: Type)
    pub event Deposit(id: UInt64, to: Address?, type: Type)
    pub event Transfer(id: UInt64, from: Address?, to: Address?, type: Type)
    pub event Mint(id: UInt64, type: Type)
    pub event Destroy(id: UInt64, type: Type)

    /// Path where the minter should be stored
    /// The standard paths for the collection are stored in the collection resource type
    pub let MinterStoragePath: StoragePath

    /// We choose the name NFT here, but this type can have any name now
    /// because the interface does not require it to have a specific name any more
    pub resource NFT: NonFungibleToken.NFT, MetadataViews.Resolver {

        /// The ID of the NFT
        /// Could be a project specific ID, or the UUID
        /// Here we choose the UUID
        pub let id: UInt64

        /// From the Display metadata view
        pub let name: String
        pub let description: String
        pub let thumbnail: String

        /// For the Royalties metadata view
        access(self) let royalties: [MetadataViews.Royalty]

        /// Generic dictionary of traits the NFT has
        access(self) let metadata: {String: AnyStruct}
    
        init(
            name: String,
            description: String,
            thumbnail: String,
            royalties: [MetadataViews.Royalty],
            metadata: {String: AnyStruct},
        ) {
            self.id = self.uuid
            self.name = name
            self.description = description
            self.thumbnail = thumbnail
            self.royalties = royalties
            self.metadata = metadata
        }
    
        pub fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Royalties>(),
                Type<MetadataViews.Editions>(),
                Type<MetadataViews.ExternalURL>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>(),
                Type<MetadataViews.Serial>(),
                Type<MetadataViews.Traits>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.name,
                        description: self.description,
                        thumbnail: MetadataViews.HTTPFile(
                            url: self.thumbnail
                        )
                    )
                case Type<MetadataViews.Editions>():
                    // There is no max number of NFTs that can be minted from this contract
                    // so the max edition field value is set to nil
                    let editionInfo = MetadataViews.Edition(name: "Example NFT Edition", number: self.id, max: nil)
                    let editionList: [MetadataViews.Edition] = [editionInfo]
                    return MetadataViews.Editions(
                        editionList
                    )
                case Type<MetadataViews.Serial>():
                    return MetadataViews.Serial(
                        self.id
                    )
                case Type<MetadataViews.Royalties>():
                    return MetadataViews.Royalties(
                        self.royalties
                    )
                case Type<MetadataViews.ExternalURL>():
                    return MetadataViews.ExternalURL("https://example-nft.onflow.org/".concat(self.id.toString()))
                case Type<MetadataViews.NFTCollectionData>():
                    return ExampleNFT.getCollectionData(nftType: Type<@ExampleNFT.NFT>())
                case Type<MetadataViews.NFTCollectionDisplay>():
                    return ExampleNFT.getCollectionDisplay(nftType: Type<@ExampleNFT.NFT>())
                case Type<MetadataViews.Traits>():
                    // exclude mintedTime and foo to show other uses of Traits
                    let excludedTraits = ["mintedTime", "foo"]
                    let traitsView = MetadataViews.dictToTraits(dict: self.metadata, excludedNames: excludedTraits)

                    // mintedTime is a unix timestamp, we should mark it with a displayType so platforms know how to show it.
                    let mintedTimeTrait = MetadataViews.Trait(name: "mintedTime", value: self.metadata["mintedTime"]!, displayType: "Date", rarity: nil)
                    traitsView.addTrait(mintedTimeTrait)

                    // foo is a trait with its own rarity
                    let fooTraitRarity = MetadataViews.Rarity(score: 10.0, max: 100.0, description: "Common")
                    let fooTrait = MetadataViews.Trait(name: "foo", value: self.metadata["foo"], displayType: nil, rarity: fooTraitRarity)
                    traitsView.addTrait(fooTrait)
                    
                    return traitsView

            }
            return nil
        }
    }

    pub resource Collection: NonFungibleToken.Collection, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.Transferor, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        /// dictionary of NFT conforming tokens
        /// NFT is a resource type with an `UInt64` ID field
        access(contract) var ownedNFTs: @{UInt64: ExampleNFT.NFT{NonFungibleToken.NFT}}

        /// Return the default storage path for the collection
        pub fun getDefaultStoragePath(): StoragePath {
            return /storage/cadenceExampleNFTCollection
        }

        /// Return the default public path for the collection
        pub fun getDefaultPublicPath(): PublicPath {
            return /public/cadenceExampleNFTCollection
        }

        init () {
            self.ownedNFTs <- {}
        }

        /// Returns the NFT types that this collection can store
        pub fun getAcceptedTypes(): {Type: Bool} {
            return {
                Type<@ExampleNFT.NFT>(): true
            }
        }

        /// withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @ExampleNFT.NFT{NonFungibleToken.NFT} {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address, type: token.getType())

            return <-token
        }

        /// deposit takes a NFT and adds it to the collections dictionary
        /// and adds the ID to the id array
        pub fun deposit(token: @AnyResource{NonFungibleToken.NFT}) {
            let token <- token as! @ExampleNFT.NFT

            emit Deposit(id: token.id, to: self.owner?.address, type: token.getType())

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[token.id] <- token

            destroy oldToken
        }

        /// Function for a direct transfer instead of having to do a deposit and withdrawal
        ///
        pub fun transfer(id: UInt64, receiver: Capability<&AnyResource{NonFungibleToken.Receiver}>): Bool {
            let token <- self.withdraw(withdrawID: id)

            // If we can't borrow a receiver reference, don't panic, just return the NFT
            // and return true for an error
            if let receiverRef = receiver.borrow() {
                emit Transfer(id: token.id, from: self.owner?.address, to: receiverRef.owner?.address, type: token.getType())
                receiverRef.deposit(token: <-token)

                return false
            } else {
                self.deposit(token: <-token)
                return true
            }
        }

        /// getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        /// borrowNFT gets a reference to an NFT in the collection
        /// so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &AnyResource{NonFungibleToken.NFT}? {
            return (&self.ownedNFTs[id] as &ExampleNFT.NFT{NonFungibleToken.NFT}?)
        }

        /// Borrow the view resolver for the specified NFT ID
        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            let nft = (&self.ownedNFTs[id] as &ExampleNFT.NFT?)!
            let exampleNFT = nft as! &ExampleNFT.NFT
            return exampleNFT as &AnyResource{MetadataViews.Resolver}
        }

        /// public function that anyone can call to create a new empty collection
        pub fun createEmptyCollection(): @ExampleNFT.Collection{NonFungibleToken.Collection} {
            return <- create ExampleNFT.Collection()
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    /// public function that anyone can call to create a new empty collection
    /// Since multiple collection types can be defined in a contract,
    /// The caller needs to specify which one they want to create
    pub fun createEmptyCollection(collectionType: Type): @ExampleNFT.Collection{NonFungibleToken.Collection}? {
        switch collectionType {
            case Type<@ExampleNFT.Collection>():
                return <- create Collection()
            default:
                return nil
        }
    }

    /// Return the types that the contract defines
    pub fun getNFTTypes(): [Type] {
        return [
            Type<@ExampleNFT.NFT>()
        ]
    }

    /// get a list of all the NFT collection types that the contract defines
    /// could include a post-condition that verifies that each Type is an NFT collection type
    pub fun getCollectionTypes(): [Type] {
        return [
            Type<@ExampleNFT.Collection>()
        ]
    }

    /// tells what collection type should be used for the specified NFT type
    /// return `nil` if no collection type exists for the specified NFT type
    pub fun getCollectionTypeForNftType(nftType: Type): Type? {
        switch nftType {
            case Type<@ExampleNFT.NFT>():
                return Type<@ExampleNFT.Collection>()
            default:
                return nil
        }
    }

    /// resolve a type to its CollectionData so you know where to store it
    /// Returns `nil` if no collection type exists for the specified NFT type
    pub fun getCollectionData(nftType: Type): MetadataViews.NFTCollectionData? {
        switch nftType {
            case Type<@ExampleNFT.NFT>():
                return MetadataViews.NFTCollectionData(
                    storagePath: /storage/cadenceExampleNFTCollection,
                    publicPath: /public/cadenceExampleNFTCollection,
                    providerPath: /private/exampleNFTCollection,
                    publicCollection: Type<&ExampleNFT.Collection{NonFungibleToken.CollectionPublic}>(),
                    publicLinkedType: Type<&ExampleNFT.Collection{NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(),
                    providerLinkedType: Type<&ExampleNFT.Collection{NonFungibleToken.CollectionPublic,NonFungibleToken.Provider,MetadataViews.ResolverCollection}>(),
                    createEmptyCollectionFunction: (fun (): @{NonFungibleToken.Collection} {
                        return <-ExampleNFT.createEmptyCollection()
                    })
                )
            default:
                return nil
        }
    }

    /// Returns the CollectionDisplay view for the NFT type that is specified 
    pub fun getCollectionDisplay(nftType: Type): MetadataViews.NFTCollectionDisplay? {
        switch nftType {
            case Type<@ExampleNFT.NFT>():
                let media = MetadataViews.Media(
                    file: MetadataViews.HTTPFile(
                        url: "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg"
                    ),
                    mediaType: "image/svg+xml"
                )
                return MetadataViews.NFTCollectionDisplay(
                    name: "The Example Collection",
                    description: "This collection is used as an example to help you develop your next Flow NFT.",
                    externalURL: MetadataViews.ExternalURL("https://example-nft.onflow.org"),
                    squareImage: media,
                    bannerImage: media,
                    socials: {
                        "twitter": MetadataViews.ExternalURL("https://twitter.com/flow_blockchain")
                    }
                )
            default:
                return nil
        }
    }

    /// Resource that an admin or something similar would own to be
    /// able to mint new NFTs
    ///
    pub resource NFTMinter {

        /// mintNFT mints a new NFT with a new ID
        /// and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(
            recipient: &{NonFungibleToken.CollectionPublic},
            name: String,
            description: String,
            thumbnail: String,
            royalties: [MetadataViews.Royalty]
        ) {
            let metadata: {String: AnyStruct} = {}
            let currentBlock = getCurrentBlock()
            metadata["mintedBlock"] = currentBlock.height
            metadata["mintedTime"] = currentBlock.timestamp
            metadata["minter"] = recipient.owner!.address

            // this piece of metadata will be used to show embedding rarity into a trait
            metadata["foo"] = "bar"

            // create a new NFT
            var newNFT <- create NFT(
                name: name,
                description: description,
                thumbnail: thumbnail,
                royalties: royalties,
                metadata: metadata,
            )

            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <-newNFT)
        }
    }

    init() {

        // Set the named paths
        self.MinterStoragePath = /storage/cadenceExampleNFTMinter

        // Create a Collection resource and save it to storage
        let collection <- create Collection()
        let defaultStoragePath = collection.defaultStoragePath
        let defaultPublicPath = collection.defaultPublicPath
        self.account.save(<-collection, to: defaultStoragePath)

        // create a public capability for the collection
        self.account.link<&ExampleNFT.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(
            defaultPublicPath,
            target: defaultStoragePath
        )

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)
    }
}
 