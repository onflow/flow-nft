/* 
*
* This is an example collection that can store any one type of NFT
* The Collection is restricted to one NFT type.
* This allows developers to write NFT contracts without having
* to also write all of the Collection boilerplate code,
* saving many lines of code.
*
*/

import "NonFungibleToken"
import "MetadataViews"
import "ViewResolver"

access(all) contract UniversalCollection {

    /// The typical Collection resource, but one that anyone can use
    ///
    access(all) resource Collection: NonFungibleToken.Collection {

        /// every Universal collection supports a single type
        /// All deposits and withdrawals must be of this type
        access(all) let supportedType : Type

        /// The path identifier
        access(all) let identifier: String

        /// Dictionary mapping NFT IDs to the stored NFTs
        access(contract) var ownedNFTs: @{UInt64: {NonFungibleToken.NFT}}

        access(self) var storagePath: StoragePath
        access(self) var publicPath: PublicPath

        /// Return the default storage path for the collection
        access(all) view fun getDefaultStoragePath(): StoragePath? {
            return self.storagePath
        }

        /// Return the default public path for the collection
        access(all) view fun getDefaultPublicPath(): PublicPath? {
            return self.publicPath
        }

        init (identifier: String, type:Type) {
            self.ownedNFTs <- {}
            self.identifier = identifier
            self.supportedType = type
            self.storagePath = StoragePath(identifier: identifier)!
            self.publicPath = PublicPath(identifier: identifier)!
        }

        /// getSupportedNFTTypes returns a list of NFT types that this receiver accepts
        access(all) view fun getSupportedNFTTypes(): {Type: Bool} {
            let supportedTypes: {Type: Bool} = {}
            supportedTypes[self.supportedType] = true
            return supportedTypes
        }

        /// Returns whether or not the given type is accepted by the collection
        access(all) view fun isSupportedNFTType(type: Type): Bool {
            if type == self.supportedType {
                return true
            } else {
                return false
            }
        }

        /// withdraw removes an NFT from the collection and moves it to the caller
        access(NonFungibleToken.Withdrawable) fun withdraw(_ withdrawID: UInt64): @{NonFungibleToken.NFT} {
            let token <- self.ownedNFTs.remove(key: withdrawID)
            ?? panic("Could not withdraw an NFT with the ID: ".concat(withdrawID.toString()).concat(" from the collection"))

            return <-token
        }

        /// deposit takes a NFT and adds it to the collections dictionary
        /// and adds the ID to the id array
        access(all) fun deposit(_ token: @{NonFungibleToken.NFT}) {
            if self.supportedType != token.getType() {
                panic("Cannot deposit an NFT of the given type")
            }

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[token.getID()] <- token
            destroy oldToken
        }

        /// getIDs returns an array of the IDs that are in the collection
        access(all) view fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        /// getLength retusnt the number of items in the collection
        access(all) view fun getLength(): Int {
            return self.ownedNFTs.length
        }

        /// Borrows a reference to an NFT in the collection if it is there
        /// otherwise, returns `nil`
        access(all) view fun borrowNFTSafe(id: UInt64): &{NonFungibleToken.NFT}? {
            return (&self.ownedNFTs[id] as &{NonFungibleToken.NFT}?)
        }

        /// Borrow the view resolver for the specified NFT ID
        access(all) view fun borrowViewResolver(id: UInt64): &{ViewResolver.Resolver}? {
            return (&self.ownedNFTs[id] as &{ViewResolver.Resolver}?)!
        }

        /// public function that anyone can call to create a new empty collection
        /// of the same type as the called collection
        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            UniversalCollection.createEmptyCollection(identifier: self.identifier, type: self.supportedType)
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    /// Public function that anyone can call to create
    /// a new empty collection with the specified type restriction
    /// NFT contracts can include a call to this method in 
    /// their own createEmptyCollection method
    access(all) fun createEmptyCollection(identifier: String, type: Type): @{NonFungibleToken.Collection} {
        return <- create Collection(identifier: identifier, type:type)
    }

}
