import FungibleToken from "./utility/FungibleToken.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"

/// This contract implements the metadata standard proposed
/// in FLIP-0636.
/// 
/// Ref: https://github.com/onflow/flow/blob/master/flips/20210916-nft-metadata.md
/// 
/// Structs and resources can implement one or more
/// metadata types, called views. Each view type represents
/// a different kind of metadata, such as a creator biography
/// or a JPEG image file.
///
pub contract MetadataViews {

    /// Provides access to a set of metadata views. A struct or 
    /// resource (e.g. an NFT) can implement this interface to provide access to 
    /// the views that it supports.
    ///
    pub resource interface Resolver {
        pub fun getViews(): [Type]
        pub fun resolveView(_ view: Type): AnyStruct?
    }

    /// A group of view resolvers indexed by ID.
    ///
    pub resource interface ResolverCollection {
        pub fun borrowViewResolver(id: UInt64): &{Resolver}
        pub fun getIDs(): [UInt64]
    }

    /// NFTView wraps all Core views along `id` and `uuid` fields, and is used 
    /// to give a complete picture of an NFT. Most NFTs should implement this 
    /// view.
    ///
    pub struct NFTView {
        pub let id: UInt64
        pub let uuid: UInt64
        pub let display: Display?
        pub let externalURL: ExternalURL?
        pub let collectionData: NFTCollectionData?
        pub let collectionDisplay: NFTCollectionDisplay?
        pub let royalties: Royalties?
        pub let traits: Traits?

        init(
            id : UInt64,
            uuid : UInt64,
            display : Display?,
            externalURL : ExternalURL?,
            collectionData : NFTCollectionData?,
            collectionDisplay : NFTCollectionDisplay?,
            royalties : Royalties?,
            traits: Traits?
        ) {
            self.id = id
            self.uuid = uuid
            self.display = display
            self.externalURL = externalURL
            self.collectionData = collectionData
            self.collectionDisplay = collectionDisplay
            self.royalties = royalties
            self.traits = traits
        }
    }

    /// Helper to get an NFT view 
    ///
    /// @param id: The NFT id
    /// @param viewResolver: A reference to the resolver resource
    /// @return A NFTView struct
    ///
    pub fun getNFTView(id: UInt64, viewResolver: &{Resolver}) : NFTView {
        let nftView = viewResolver.resolveView(Type<NFTView>())
        if nftView != nil {
            return nftView! as! NFTView
        }

        return NFTView(
            id : id,
            uuid: viewResolver.uuid,
            display: self.getDisplay(viewResolver),
            externalURL : self.getExternalURL(viewResolver),
            collectionData : self.getNFTCollectionData(viewResolver),
            collectionDisplay : self.getNFTCollectionDisplay(viewResolver),
            royalties : self.getRoyalties(viewResolver),
            traits : self.getTraits(viewResolver)
        )
    }

    /// Display is a basic view that includes the name, description and
    /// thumbnail for an object. Most objects should implement this view.
    ///
    pub struct Display {

        /// The name of the object. 
        ///
        /// This field will be displayed in lists and therefore should
        /// be short an concise.
        ///
        pub let name: String

        /// A written description of the object. 
        ///
        /// This field will be displayed in a detailed view of the object,
        /// so can be more verbose (e.g. a paragraph instead of a single line).
        ///
        pub let description: String

        /// A small thumbnail representation of the object.
        ///
        /// This field should be a web-friendly file (i.e JPEG, PNG)
        /// that can be displayed in lists, link previews, etc.
        ///
        pub let thumbnail: AnyStruct{File}

        init(
            name: String,
            description: String,
            thumbnail: AnyStruct{File}
        ) {
            self.name = name
            self.description = description
            self.thumbnail = thumbnail
        }
    }

    /// Helper to get Display in a typesafe way
    ///
    /// @param viewResolver: A reference to the resolver resource
    /// @return An optional Display struct
    ///
    pub fun getDisplay(_ viewResolver: &{Resolver}) : Display? {
        if let view = viewResolver.resolveView(Type<Display>()) {
            if let v = view as? Display {
                return v
            }
        }
        return nil
    }

    /// Generic interface that represents a file stored on or off chain. Files 
    /// can be used to references images, videos and other media.
    ///
    pub struct interface File {
        pub fun uri(): String
    }

    /// View to expose a file that is accessible at an HTTP (or HTTPS) URL. 
    ///
    pub struct HTTPFile: File {
        pub let url: String

        init(url: String) {
            self.url = url
        }

        pub fun uri(): String {
            return self.url
        }
    }

    /// View to expose a file stored on IPFS.
    /// IPFS images are referenced by their content identifier (CID)
    /// rather than a direct URI. A client application can use this CID
    /// to find and load the image via an IPFS gateway.
    ///
    pub struct IPFSFile: File {

        /// CID is the content identifier for this IPFS file.
        ///
        /// Ref: https://docs.ipfs.io/concepts/content-addressing/
        ///
        pub let cid: String

        /// Path is an optional path to the file resource in an IPFS directory.
        ///
        /// This field is only needed if the file is inside a directory.
        ///
        /// Ref: https://docs.ipfs.io/concepts/file-systems/
        ///
        pub let path: String?

        init(cid: String, path: String?) {
            self.cid = cid
            self.path = path
        }

        /// This function returns the IPFS native URL for this file.
        /// Ref: https://docs.ipfs.io/how-to/address-ipfs-on-web/#native-urls
        ///
        /// @return The string containing the file uri
        ///
        pub fun uri(): String {
            if let path = self.path {
                return "ipfs://".concat(self.cid).concat("/").concat(path)
            }

            return "ipfs://".concat(self.cid)
        }
    }

    /// Optional view for collections that issue multiple objects
    /// with the same or similar metadata, for example an X of 100 set. This 
    /// information is useful for wallets and marketplaces.
    /// An NFT might be part of multiple editions, which is why the edition 
    /// information is returned as an arbitrary sized array
    ///
    pub struct Edition {

        /// The name of the edition
        /// For example, this could be Set, Play, Series,
        /// or any other way a project could classify its editions
        pub let name: String?

        /// The edition number of the object.
        /// For an "24 of 100 (#24/100)" item, the number is 24.
        pub let number: UInt64

        /// The max edition number of this type of objects.
        /// This field should only be provided for limited-editioned objects.
        /// For an "24 of 100 (#24/100)" item, max is 100.
        /// For an item with unlimited edition, max should be set to nil.
        /// 
        pub let max: UInt64?

        init(name: String?, number: UInt64, max: UInt64?) {
            if max != nil {
                assert(number <= max!, message: "The number cannot be greater than the max number!")
            }
            self.name = name
            self.number = number
            self.max = max
        }
    }

    /// Wrapper view for multiple Edition views
    /// 
    pub struct Editions {

        /// An arbitrary-sized list for any number of editions
        /// that the NFT might be a part of
        pub let infoList: [Edition]

        init(_ infoList: [Edition]) {
            self.infoList = infoList
        }
    }

    /// Helper to get Editions in a typesafe way
    ///
    /// @param viewResolver: A reference to the resolver resource
    /// @return An optional Editions struct
    ///
    pub fun getEditions(_ viewResolver: &{Resolver}) : Editions? {
        if let view = viewResolver.resolveView(Type<Editions>()) {
            if let v = view as? Editions {
                return v
            }
        }
        return nil
    }

    /// View representing a project-defined serial number for a specific NFT
    /// Projects have different definitions for what a serial number should be
    /// Some may use the NFTs regular ID and some may use a different 
    /// classification system. The serial number is expected to be unique among 
    /// other NFTs within that project
    ///
    pub struct Serial {
        pub let number: UInt64

        init(_ number: UInt64) {
            self.number = number
        }
    }

    /// Helper to get Serial in a typesafe way
    ///
    /// @param viewResolver: A reference to the resolver resource
    /// @return An optional Serial struct
    ///
    pub fun getSerial(_ viewResolver: &{Resolver}) : Serial? {
        if let view = viewResolver.resolveView(Type<Serial>()) {
            if let v = view as? Serial {
                return v
            }
        }
        return nil
    }
    
    /// View that defines the composable royalty standard that gives marketplaces a 
    /// unified interface to support NFT royalties.
    ///
    pub struct Royalty {

        /// Generic FungibleToken Receiver for the beneficiary of the royalty
        /// Can get the concrete type of the receiver with receiver.getType()
        /// Recommendation - Users should create a new link for a FlowToken 
        /// receiver for this using `getRoyaltyReceiverPublicPath()`, and not 
        /// use the default FlowToken receiver. This will allow users to update 
        /// the capability in the future to use a more generic capability
        pub let receiver: Capability<&AnyResource{FungibleToken.Receiver}>

        /// Multiplier used to calculate the amount of sale value transferred to 
        /// royalty receiver. Note - It should be between 0.0 and 1.0 
        /// Ex - If the sale value is x and multiplier is 0.56 then the royalty 
        /// value would be 0.56 * x.
        /// Generally percentage get represented in terms of basis points
        /// in solidity based smart contracts while cadence offers `UFix64` 
        /// that already supports the basis points use case because its 
        /// operations are entirely deterministic integer operations and support 
        /// up to 8 points of precision.
        pub let cut: UFix64

        /// Optional description: This can be the cause of paying the royalty,
        /// the relationship between the `wallet` and the NFT, or anything else
        /// that the owner might want to specify.
        pub let description: String

        init(receiver: Capability<&AnyResource{FungibleToken.Receiver}>, cut: UFix64, description: String) {
            pre {
                cut >= 0.0 && cut <= 1.0 : "Cut value should be in valid range i.e [0,1]"
            }
            self.receiver = receiver
            self.cut = cut
            self.description = description
        }
    }

    /// Wrapper view for multiple Royalty views.
    /// Marketplaces can query this `Royalties` struct from NFTs 
    /// and are expected to pay royalties based on these specifications.
    ///
    pub struct Royalties {

        /// Array that tracks the individual royalties
        access(self) let cutInfos: [Royalty]

        pub init(_ cutInfos: [Royalty]) {
            // Validate that sum of all cut multipliers should not be greater than 1.0
            var totalCut = 0.0
            for royalty in cutInfos {
                totalCut = totalCut + royalty.cut
            }
            assert(totalCut <= 1.0, message: "Sum of cutInfos multipliers should not be greater than 1.0")
            // Assign the cutInfos
            self.cutInfos = cutInfos
        }

        /// Return the cutInfos list
        ///
        /// @return An array containing all the royalties structs
        ///
        pub fun getRoyalties(): [Royalty] {
            return self.cutInfos
        }
    }

    /// Helper to get Royalties in a typesafe way
    ///
    /// @param viewResolver: A reference to the resolver resource
    /// @return A optional Royalties struct
    ///
    pub fun getRoyalties(_ viewResolver: &{Resolver}) : Royalties? {
        if let view = viewResolver.resolveView(Type<Royalties>()) {
            if let v = view as? Royalties {
                return v
            }
        }
        return nil
    }

    /// Get the path that should be used for receiving royalties
    /// This is a path that will eventually be used for a generic switchboard receiver,
    /// hence the name but will only be used for royalties for now.
    ///
    /// @return The PublicPath for the generic FT receiver
    ///
    pub fun getRoyaltyReceiverPublicPath(): PublicPath {
        return /public/GenericFTReceiver
    }

    /// View to represent, a file with an correspoiding mediaType.
    ///
    pub struct Media {

        /// File for the media
        ///
        pub let file: AnyStruct{File}

        /// media-type comes on the form of type/subtype as described here 
        /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types
        ///
        pub let mediaType: String

        init(file: AnyStruct{File}, mediaType: String) {
          self.file=file
          self.mediaType=mediaType
        }
    }

    /// Wrapper view for multiple media views
    ///
    pub struct Medias {

        /// An arbitrary-sized list for any number of Media items
        pub let items: [Media]

        init(_ items: [Media]) {
            self.items = items
        }
    }

    /// Helper to get Medias in a typesafe way
    ///
    /// @param viewResolver: A reference to the resolver resource
    /// @return A optional Medias struct
    ///
    pub fun getMedias(_ viewResolver: &{Resolver}) : Medias? {
        if let view = viewResolver.resolveView(Type<Medias>()) {
            if let v = view as? Medias {
                return v
            }
        }
        return nil
    }

    /// View to represent a license according to https://spdx.org/licenses/
    /// This view can be used if the content of an NFT is licensed.
    ///
    pub struct License {
        pub let spdxIdentifier: String

        init(_ identifier: String) {
            self.spdxIdentifier = identifier
        }
    }

    /// Helper to get License in a typesafe way
    ///
    /// @param viewResolver: A reference to the resolver resource
    /// @return A optional License struct
    ///
    pub fun getLicense(_ viewResolver: &{Resolver}) : License? {
        if let view = viewResolver.resolveView(Type<License>()) {
            if let v = view as? License {
                return v
            }
        }
        return nil
    }

    /// View to expose a URL to this item on an external site.
    /// This can be used by applications like .find and Blocto to direct users 
    /// to the original link for an NFT.
    ///
    pub struct ExternalURL {
        pub let url: String

        init(_ url: String) {
            self.url=url
        }
    }

    /// Helper to get ExternalURL in a typesafe way
    ///
    /// @param viewResolver: A reference to the resolver resource
    /// @return A optional ExternalURL struct
    ///
    pub fun getExternalURL(_ viewResolver: &{Resolver}) : ExternalURL? {
        if let view = viewResolver.resolveView(Type<ExternalURL>()) {
            if let v = view as? ExternalURL {
                return v
            }
        }
        return nil
    }

    /// View to expose the information needed store and retrieve an NFT.
    /// This can be used by applications to setup a NFT collection with proper 
    /// storage and public capabilities.
    ///
    pub struct NFTCollectionData {
        /// Path in storage where this NFT is recommended to be stored.
        pub let storagePath: StoragePath

        /// Public path which must be linked to expose public capabilities of this NFT
        /// including standard NFT interfaces and metadataviews interfaces
        pub let publicPath: PublicPath

        /// Private path which should be linked to expose the provider
        /// capability to withdraw NFTs from the collection holding NFTs
        pub let providerPath: PrivatePath

        /// Public collection type that is expected to provide sufficient read-only access to standard
        /// functions (deposit + getIDs + borrowNFT)
        /// This field is for backwards compatibility with collections that have not used the standard
        /// NonFungibleToken.CollectionPublic interface when setting up collections. For new
        /// collections, this may be set to be equal to the type specified in `publicLinkedType`.
        pub let publicCollection: Type

        /// Type that should be linked at the aforementioned public path. This is normally a
        /// restricted type with many interfaces. Notably the `NFT.CollectionPublic`,
        /// `NFT.Receiver`, and `MetadataViews.ResolverCollection` interfaces are required.
        pub let publicLinkedType: Type

        /// Type that should be linked at the aforementioned private path. This is normally
        /// a restricted type with at a minimum the `NFT.Provider` interface
        pub let providerLinkedType: Type

        /// Function that allows creation of an empty NFT collection that is intended to store
        /// this NFT.
        pub let createEmptyCollection: ((): @NonFungibleToken.Collection)

        init(
            storagePath: StoragePath,
            publicPath: PublicPath,
            providerPath: PrivatePath,
            publicCollection: Type,
            publicLinkedType: Type,
            providerLinkedType: Type,
            createEmptyCollectionFunction: ((): @NonFungibleToken.Collection)
        ) {
            pre {
                publicLinkedType.isSubtype(of: Type<&{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>()): "Public type must include NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, and MetadataViews.ResolverCollection interfaces."
                providerLinkedType.isSubtype(of: Type<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>()): "Provider type must include NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, and MetadataViews.ResolverCollection interface."
            }
            self.storagePath=storagePath
            self.publicPath=publicPath
            self.providerPath = providerPath
            self.publicCollection=publicCollection
            self.publicLinkedType=publicLinkedType
            self.providerLinkedType = providerLinkedType
            self.createEmptyCollection=createEmptyCollectionFunction
        }
    }

    /// Helper to get NFTCollectionData in a way that will return an typed Optional
    ///
    /// @param viewResolver: A reference to the resolver resource
    /// @return A optional NFTCollectionData struct
    ///
    pub fun getNFTCollectionData(_ viewResolver: &{Resolver}) : NFTCollectionData? {
        if let view = viewResolver.resolveView(Type<NFTCollectionData>()) {
            if let v = view as? NFTCollectionData {
                return v
            }
        }
        return nil
    }

    /// View to expose the information needed to showcase this NFT's
    /// collection. This can be used by applications to give an overview and 
    /// graphics of the NFT collection this NFT belongs to.
    ///
    pub struct NFTCollectionDisplay {
        // Name that should be used when displaying this NFT collection.
        pub let name: String

        // Description that should be used to give an overview of this collection.
        pub let description: String

        // External link to a URL to view more information about this collection.
        pub let externalURL: ExternalURL

        // Square-sized image to represent this collection.
        pub let squareImage: Media

        // Banner-sized image for this collection, recommended to have a size near 1200x630.
        pub let bannerImage: Media

        // Social links to reach this collection's social homepages.
        // Possible keys may be "instagram", "twitter", "discord", etc.
        pub let socials: {String: ExternalURL}

        init(
            name: String,
            description: String,
            externalURL: ExternalURL,
            squareImage: Media,
            bannerImage: Media,
            socials: {String: ExternalURL}
        ) {
            self.name = name
            self.description = description
            self.externalURL = externalURL
            self.squareImage = squareImage
            self.bannerImage = bannerImage
            self.socials = socials
        }
    }

    /// Helper to get NFTCollectionDisplay in a way that will return a typed 
    /// Optional
    ///
    /// @param viewResolver: A reference to the resolver resource
    /// @return A optional NFTCollection struct
    ///
    pub fun getNFTCollectionDisplay(_ viewResolver: &{Resolver}) : NFTCollectionDisplay? {
        if let view = viewResolver.resolveView(Type<NFTCollectionDisplay>()) {
            if let v = view as? NFTCollectionDisplay {
                return v
            }
        }
        return nil
    }

    /// View to expose rarity information for a single rarity
    /// Note that a rarity needs to have either score or description but it can 
    /// have both
    ///
    pub struct Rarity {
        /// The score of the rarity as a number
        pub let score: UFix64?

        /// The maximum value of score
        pub let max: UFix64?

        /// The description of the rarity as a string.
        ///
        /// This could be Legendary, Epic, Rare, Uncommon, Common or any other string value
        pub let description: String?

        init(score: UFix64?, max: UFix64?, description: String?) {
            if score == nil && description == nil {
                panic("A Rarity needs to set score, description or both")
            }

            self.score = score
            self.max = max
            self.description = description
        }
    }

    /// Helper to get Rarity view in a typesafe way
    ///
    /// @param viewResolver: A reference to the resolver resource
    /// @return A optional Rarity struct
    ///
    pub fun getRarity(_ viewResolver: &{Resolver}) : Rarity? {
        if let view = viewResolver.resolveView(Type<Rarity>()) {
            if let v = view as? Rarity {
                return v
            }
        }
        return nil
    }

    /// View to represent a single field of metadata on an NFT.
    /// This is used to get traits of individual key/value pairs along with some
    /// contextualized data about the trait
    ///
    pub struct Trait {
        // The name of the trait. Like Background, Eyes, Hair, etc.
        pub let name: String

        // The underlying value of the trait, the rest of the fields of a trait provide context to the value.
        pub let value: AnyStruct

        // displayType is used to show some context about what this name and value represent
        // for instance, you could set value to a unix timestamp, and specify displayType as "Date" to tell
        // platforms to consume this trait as a date and not a number
        pub let displayType: String?

        // Rarity can also be used directly on an attribute.
        //
        // This is optional because not all attributes need to contribute to the NFT's rarity.
        pub let rarity: Rarity?

        init(name: String, value: AnyStruct, displayType: String?, rarity: Rarity?) {
            self.name = name
            self.value = value
            self.displayType = displayType
            self.rarity = rarity
        }
    }

    /// Wrapper view to return all the traits on an NFT.
    /// This is used to return traits as individual key/value pairs along with
    /// some contextualized data about each trait.
    pub struct Traits {
        pub let traits: [Trait]

        init(_ traits: [Trait]) {
            self.traits = traits
        }
            
        /// Adds a single Trait to the Traits view
        /// 
        /// @param Trait: The trait struct to be added
        ///
        pub fun addTrait(_ t: Trait) {
            self.traits.append(t)
        }
    }

    /// Helper to get Traits view in a typesafe way
    ///
    /// @param viewResolver: A reference to the resolver resource
    /// @return A optional Traits struct
    ///
    pub fun getTraits(_ viewResolver: &{Resolver}) : Traits? {
        if let view = viewResolver.resolveView(Type<Traits>()) {
            if let v = view as? Traits {
                return v
            }
        }
        return nil
    }

    /// Helper function to easily convert a dictionary to traits. For NFT 
    /// collections that do not need either of the optional values of a Trait, 
    /// this method should suffice to give them an array of valid traits.
    ///
    /// @param dict: The dictionary to be converted to Traits
    /// @param excludedNames: An optional String array specifying the `dict`
    ///         keys that are not wanted to become `Traits`
    /// @return The generated Traits view
    ///
    pub fun dictToTraits(dict: {String: AnyStruct}, excludedNames: [String]?): Traits {
        // Collection owners might not want all the fields in their metadata included.
        // They might want to handle some specially, or they might just not want them included at all.
        if excludedNames != nil {
            for k in excludedNames! {
                dict.remove(key: k)
            }
        }

        let traits: [Trait] = []
        for k in dict.keys {
            let trait = Trait(name: k, value: dict[k]!, displayType: nil, rarity: nil)
            traits.append(trait)
        }

        return Traits(traits)
    }

}
 