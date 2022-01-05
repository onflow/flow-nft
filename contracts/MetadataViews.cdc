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

    // A Resolver provides access to a set of metadata views.
    //
    // A struct or resource (e.g. an NFT) can implement this interface
    // to provide access to the views that it supports.
    //
    pub resource interface Resolver {
        pub fun getViews(): [Type]
        pub fun resolveView(_ view: Type): AnyStruct?
    }

    // A ResolverCollection is a group of view resolvers index by ID.
    //
    pub resource interface ResolverCollection {
        pub fun borrowViewResolver(id: UInt64): &{Resolver}
        pub fun getIDs(): [UInt64]
    }
}
