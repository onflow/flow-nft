/**

This contract implements the metadata standard proposed
in FLIP-0636.

Ref: https://github.com/onflow/flow/blob/master/flips/20210916-nft-metadata.md

Structs and resources can implement one or more
metadata types, called views. Each view type represents
a different kind of metadata, such as a creator biography
or a JPEG image file.
*/

pub contract MetadataViews {

    // A ViewResolver provides access to a set of metadata views.
    //
    // A struct or resource (e.g. an NFT) can implement this interface
    // to provide access to the views that it supports.
    //
    pub resource interface Resolver {
        pub fun getViews(): [Type]
        pub fun resolveView(_ view: Type): AnyStruct?
    }

    // Display is a basic view that includes the name and description
    // of an object. Most objects should implement this view.
    //
    pub struct Display {
        pub let name: String
        pub let description: String

        init(
            name: String,
            description: String,
        ) {
            self.name=name
            self.description=description
        }
    }

    // Thumbnail returns a thumbnail image for an object.
    //
    // Many NFT resources implement this view to provide 
    // a simple visual representation of the NFT.
    //
    pub struct Thumbnail {
        pub let uri: String
        pub let mimetype: String

        init(
            uri: String,
            mimetype: String,
        ) {
            self.uri=uri
            self.mimetype=mimetype
        }
    }
}
