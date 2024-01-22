/* 
*
*  This is an basic implementation of a Flow Non-Fungible Token using the V2 standard.
*  It shows that a basic NFT can be defined in very few lines of code (less than 100 here)
*
*  Unlike the `ExampleNFT-v2` contract, this NFT illustrates a minimal implementation
*  of an NFT that is now possible with the NFT standard since Events, collections,
*  and other old requirements are not required any more.
* 
*  It also includes minimal metadata to showcase the simplicity
*   
*/

import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"
import ViewResolver from "ViewResolver"
import UniversalCollection from "UniversalCollection"

access(all) contract BasicNFT: NonFungibleToken {

    /// The only thing that an NFT really needs to have is this resource definition
    access(all) resource NFT: NonFungibleToken.NFT {
        /// Arbitrary trait mapping metadata
        access(self) let metadata: {String: AnyStruct}

        access(all) let id: UInt64
    
        init(
            metadata: {String: AnyStruct},
        ) {
            self.id = self.uuid
            self.metadata = metadata
        }

        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <- BasicNFT.createEmptyCollection(nftType: self.getType())
        }
    
        /// Uses the basic NFT views
        access(all) view fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Serial>(),
                Type<MetadataViews.Traits>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>()
            ]
        }

        access(all) fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.metadata["name"] as! String,
                        description: self.metadata["description"] as! String,
                        thumbnail: MetadataViews.HTTPFile(
                            url: self.metadata["thumbnail"] as! String
                        )
                    )
                case Type<MetadataViews.Serial>():
                    return MetadataViews.Serial(
                        self.id
                    )
                case Type<MetadataViews.Traits>():
                    return MetadataViews.dictToTraits(dict: self.metadata, excludedNames: nil)
                case Type<MetadataViews.NFTCollectionData>():
                    return BasicNFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>())
                case Type<MetadataViews.NFTCollectionDisplay>():
                    return BasicNFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionDisplay>())
            }
            return nil
        }
    }

    access(all) view fun getContractViews(resourceType: Type?): [Type] {
        return [
            Type<MetadataViews.NFTCollectionData>(),
            Type<MetadataViews.NFTCollectionDisplay>()
        ]
    }

    access(all) fun resolveContractView(resourceType: Type?, viewType: Type): AnyStruct? {
        switch viewType {
            case Type<MetadataViews.NFTCollectionData>():
                let collectionRef = self.account.storage.borrow<&ExampleNFT.Collection>(
                        from: /storage/cadenceExampleNFTCollection
                    ) ?? panic("Could not borrow a reference to the stored collection")
                
                return collectionRef.getNFTCollectionDataView()
            case Type<MetadataViews.NFTCollectionDisplay>():
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
        }
        return nil
    }

    access(all) resource NFTMinter {
        access(all) fun mintNFT(metadata: {String: AnyStruct}): @BasicNFT.NFT {
           return <- create NFT(metadata: metadata)
        }
    }

    access(all) fun createEmptyCollection(nftType: Type): @{NonFungibleToken.Collection} {
        return <- UniversalCollection.createEmptyCollection(identifier: "flowBasicNFTCollection", type: Type<@BasicNFT.NFT>())
    }

    init() {
        let minter <- create NFTMinter()
        self.account.storage.save(<-minter, to: /storage/flowBasicNFTMinterPath)

        let collection <- self.createEmptyCollection(nftType: Type<@BasicNFT.NFT>()>)
        let dataView = collection.getNFTCollectionDataView()
        self.account.storage.save(collection, to: dataView.storagePath)
    }
}
 