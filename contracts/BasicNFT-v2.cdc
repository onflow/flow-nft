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

access(all) contract BasicNFT {

    /// The only thing that an NFT really needs to have is this resource definition
    access(all) resource NFT: NonFungibleToken.NFT, ViewResolver.Resolver {
        /// Arbitrary trait mapping metadata
        access(self) let metadata: {String: AnyStruct}
    
        init(
            metadata: {String: AnyStruct},
        ) {
            self.metadata = metadata
        }

        /// Gets the ID of the NFT, which here is the UUID
        access(all) view fun getID(): UInt64 { return self.uuid }
    
        /// Uses the basic NFT views
        access(all) view fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Serial>(),
                Type<MetadataViews.Traits>()
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
                        self.getID()
                    )
                case Type<MetadataViews.Traits>():
                    return MetadataViews.dictToTraits(dict: self.metadata, excludedNames: nil)
            }
            return nil
        }
    }

    access(all) resource NFTMinter {
        access(all) fun mintNFT(metadata: {String: AnyStruct}): @BasicNFT.NFT {
           return <- create NFT(metadata: metadata)
        }
    }

    init() {
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: /storage/flowBasicNFTMinterPath)
    }
}
 