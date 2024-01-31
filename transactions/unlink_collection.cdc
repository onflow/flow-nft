/// This transaction unlinks signer's public Capability at canonical public path

import MetadataViews from "MetadataViews"
import ExampleNFT from "ExampleNFT"

transaction {
    prepare(signer: auth(UnpublishCapabilty) &Account) {
        let collectionData = ExampleNFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("ViewResolver does not resolve NFTCollectionData view")
        signer.capabilities.unpublish(ExampleNFT.CollectionPublicPath)
    }
}
