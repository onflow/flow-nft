/// This transaction unlinks signer's public Capability at canonical public path

import "MetadataViews"
import "ExampleNFT"

transaction {
    prepare(signer: auth(UnpublishCapabilty) &Account) {
        let collectionData = ExampleNFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve NFTCollectionData view. The ExampleNFT contract needs to implement the NFTCollectionData Metadata view in order to execute this transaction")
        signer.capabilities.unpublish(ExampleNFT.CollectionPublicPath)
    }
}
