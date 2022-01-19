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

    // Display is a basic view that includes the name, description and
    // thumbnail for an object. Most objects should implement this view.
    //
    pub struct Display {

        // The name of the object. 
        //
        // This field will be displayed in lists and therefore should
        // be short an concise.
        //
        pub let name: String

        // A written description of the object. 
        //
        // This field will be displayed in a detailed view of the object,
        // so can be more verbose (e.g. a paragraph instead of a single line).
        //
        pub let description: String

        // A small thumbnail representation of the object.
        //
        // This field should be a web-friendly file (i.e JPEG, PNG)
        // that can be displayed in lists, link previews, etc.
        //
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

    // File is a generic interface that represents a file stored on or off chain.
    //
    // Files can be used to references images, videos and other media.
    //
    pub struct interface File {
        pub fun uri(): String
    }

    // HTTPFile is a file that is accessible at an HTTP (or HTTPS) URL. 
    //
    pub struct HTTPFile: File {
        pub let url: String

        init(url: String) {
            self.url = url
        }

        pub fun uri(): String {
            return self.url
        }
    }

    // IPFSThumbnail returns a thumbnail image for an object
    // stored as an image file in IPFS.
    //
    // IPFS images are referenced by their content identifier (CID)
    // rather than a direct URI. A client application can use this CID
    // to find and load the image via an IPFS gateway.
    //
    pub struct IPFSFile: File {

        // CID is the content identifier for this IPFS file.
        //
        // Ref: https://docs.ipfs.io/concepts/content-addressing/
        //
        pub let cid: String

        // Path is an optional path to the file resource in an IPFS directory.
        //
        // This field is only needed if the file is inside a directory.
        //
        // Ref: https://docs.ipfs.io/concepts/file-systems/
        //
        pub let path: String?

        init(cid: String, path: String?) {
            self.cid = cid
            self.path = path
        }

        // This function returns the IPFS native URL for this file.
        //
        // Ref: https://docs.ipfs.io/how-to/address-ipfs-on-web/#native-urls
        //
        pub fun uri(): String {
            if let path = self.path {
                return "ipfs://".concat(self.cid).concat("/").concat(path)
            }
            
            return "ipfs://".concat(self.cid)
        }
    }
}
