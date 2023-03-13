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

import NonFungibleToken from "./NonFungibleToken-v2.cdc"
import MetadataViews from "./MetadataViews.cdc"

pub contract BasicNFT {

    /// The only thing that an NFT really needs to have is this resource definition
    pub resource NFT: NonFungibleToken.NFT, MetadataViews.Resolver {
        /// Arbitrary trait mapping metadata
        access(self) let metadata: {String: AnyStruct}
    
        init(
            metadata: {String: AnyStruct},
        ) {
            self.metadata = metadata
        }

        /// Gets the ID of the NFT, which here is the UUID
        pub fun getID(): UInt64 { return self.uuid }
    
        /// Uses the basic NFT views
        pub fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Serial>(),
                Type<MetadataViews.Traits>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
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

    /// Return the NFT types that the contract defines
    pub fun getNFTTypes(): [Type] {
        return [
            Type<@BasicNFT.NFT>()
        ]
    }

    pub resource NFTMinter {
        pub fun mintNFT(metadata: {String: AnyStruct}): @BasicNFT.NFT {
           return <- create NFT(metadata: metadata)
        }
    }

    init() {
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: /storage/flowBasicNFTMinterPath)
    }
}
 