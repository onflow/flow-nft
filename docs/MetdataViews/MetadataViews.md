# Contract `MetadataViews`

```cadence
contract MetadataViews {
}
```

This contract implements the metadata standard proposed
in FLIP-0636.

Ref: https://github.com/onflow/flow/blob/master/flips/20210916-nft-metadata.md

Structs and resources can implement one or more
metadata types, called views. Each view type represents
a different kind of metadata, such as a creator biography
or a JPEG image file.
## Interfaces
    
### resource interface `Resolver`

```cadence
resource interface Resolver {
}
```
Provides access to a set of metadata views. A struct or
resource (e.g. an NFT) can implement this interface to provide access to
the views that it supports.

[More...](MetadataViews_Resolver.md)

---
    
### resource interface `ResolverCollection`

```cadence
resource interface ResolverCollection {
}
```
A group of view resolvers indexed by ID.

[More...](MetadataViews_ResolverCollection.md)

---
    
### struct interface `File`

```cadence
struct interface File {
}
```
Generic interface that represents a file stored on or off chain. Files
can be used to references images, videos and other media.

[More...](MetadataViews_File.md)

---
## Structs & Resources

### struct `NFTView`

```cadence
struct NFTView {

    id:  UInt64

    uuid:  UInt64

    display:  Display?

    externalURL:  ExternalURL?

    collectionData:  NFTCollectionData?

    collectionDisplay:  NFTCollectionDisplay?

    royalties:  Royalties?

    traits:  Traits?
}
```
NFTView wraps all Core views along `id` and `uuid` fields, and is used
to give a complete picture of an NFT. Most NFTs should implement this
view.

[More...](MetadataViews_NFTView.md)

---

### struct `Display`

```cadence
struct Display {

    name:  String

    description:  String

    thumbnail:  AnyStruct{File}
}
```
Display is a basic view that includes the name, description and
thumbnail for an object. Most objects should implement this view.

[More...](MetadataViews_Display.md)

---

### struct `HTTPFile`

```cadence
struct HTTPFile {

    url:  String
}
```
View to expose a file that is accessible at an HTTP (or HTTPS) URL.

[More...](MetadataViews_HTTPFile.md)

---

### struct `IPFSFile`

```cadence
struct IPFSFile {

    cid:  String

    path:  String?
}
```
View to expose a file stored on IPFS.
IPFS images are referenced by their content identifier (CID)
rather than a direct URI. A client application can use this CID
to find and load the image via an IPFS gateway.

[More...](MetadataViews_IPFSFile.md)

---

### struct `Edition`

```cadence
struct Edition {

    name:  String?

    number:  UInt64

    max:  UInt64?
}
```
Optional view for collections that issue multiple objects
with the same or similar metadata, for example an X of 100 set. This
information is useful for wallets and marketplaces.
An NFT might be part of multiple editions, which is why the edition
information is returned as an arbitrary sized array

[More...](MetadataViews_Edition.md)

---

### struct `Editions`

```cadence
struct Editions {

    infoList:  [Edition]
}
```
Wrapper view for multiple Edition views

[More...](MetadataViews_Editions.md)

---

### struct `Serial`

```cadence
struct Serial {

    number:  UInt64
}
```
View representing a project-defined serial number for a specific NFT
Projects have different definitions for what a serial number should be
Some may use the NFTs regular ID and some may use a different
classification system. The serial number is expected to be unique among
other NFTs within that project

[More...](MetadataViews_Serial.md)

---

### struct `Royalty`

```cadence
struct Royalty {

    receiver:  Capability<&AnyResource{FungibleToken.Receiver}>

    cut:  UFix64

    description:  String
}
```
View that defines the composable royalty standard that gives marketplaces a
unified interface to support NFT royalties.

[More...](MetadataViews_Royalty.md)

---

### struct `Royalties`

```cadence
struct Royalties {

    cutInfos:  [Royalty]
}
```
Wrapper view for multiple Royalty views.
Marketplaces can query this `Royalties` struct from NFTs
and are expected to pay royalties based on these specifications.

[More...](MetadataViews_Royalties.md)

---

### struct `Media`

```cadence
struct Media {

    file:  AnyStruct{File}

    mediaType:  String
}
```
View to represent, a file with an correspoiding mediaType.

[More...](MetadataViews_Media.md)

---

### struct `Medias`

```cadence
struct Medias {

    items:  [Media]
}
```
Wrapper view for multiple media views

[More...](MetadataViews_Medias.md)

---

### struct `License`

```cadence
struct License {

    spdxIdentifier:  String
}
```
View to represent a license according to https://spdx.org/licenses/
This view can be used if the content of an NFT is licensed.

[More...](MetadataViews_License.md)

---

### struct `ExternalURL`

```cadence
struct ExternalURL {

    url:  String
}
```
View to expose a URL to this item on an external site.
This can be used by applications like .find and Blocto to direct users
to the original link for an NFT.

[More...](MetadataViews_ExternalURL.md)

---

### struct `NFTCollectionData`

```cadence
struct NFTCollectionData {

    storagePath:  StoragePath

    publicPath:  PublicPath

    providerPath:  PrivatePath

    publicCollection:  Type

    publicLinkedType:  Type

    providerLinkedType:  Type

    createEmptyCollection:  ((): @NonFungibleToken.Collection)
}
```
View to expose the information needed store and retrieve an NFT.
This can be used by applications to setup a NFT collection with proper
storage and public capabilities.

[More...](MetadataViews_NFTCollectionData.md)

---

### struct `NFTCollectionDisplay`

```cadence
struct NFTCollectionDisplay {

    name:  String

    description:  String

    externalURL:  ExternalURL

    squareImage:  Media

    bannerImage:  Media

    socials:  {String: ExternalURL}
}
```
View to expose the information needed to showcase this NFT's
collection. This can be used by applications to give an overview and
graphics of the NFT collection this NFT belongs to.

[More...](MetadataViews_NFTCollectionDisplay.md)

---

### struct `Rarity`

```cadence
struct Rarity {

    score:  UFix64?

    max:  UFix64?

    description:  String?
}
```
View to expose rarity information for a single rarity
Note that a rarity needs to have either score or description but it can
have both

[More...](MetadataViews_Rarity.md)

---

### struct `Trait`

```cadence
struct Trait {

    name:  String

    value:  AnyStruct

    displayType:  String?

    rarity:  Rarity?
}
```
View to represent a single field of metadata on an NFT.
This is used to get traits of individual key/value pairs along with some
contextualized data about the trait

[More...](MetadataViews_Trait.md)

---

### struct `Traits`

```cadence
struct Traits {

    traits:  [Trait]
}
```
Wrapper view to return all the traits on an NFT.
This is used to return traits as individual key/value pairs along with
some contextualized data about each trait.

[More...](MetadataViews_Traits.md)

---
## Functions

### fun `getNFTView()`

```cadence
func getNFTView(id UInt64, viewResolver &{Resolver}): NFTView
```
Helper to get an NFT view

Parameters:
  - id : _The NFT id_
  - viewResolver : _A reference to the resolver resource_

Returns: A NFTView struct

---

### fun `getDisplay()`

```cadence
func getDisplay(_ &{Resolver}): Display?
```
Helper to get Display in a typesafe way

Parameters:
  - viewResolver : _A reference to the resolver resource_

Returns: An optional Display struct

---

### fun `getEditions()`

```cadence
func getEditions(_ &{Resolver}): Editions?
```
Helper to get Editions in a typesafe way

Parameters:
  - viewResolver : _A reference to the resolver resource_

Returns: An optional Editions struct

---

### fun `getSerial()`

```cadence
func getSerial(_ &{Resolver}): Serial?
```
Helper to get Serial in a typesafe way

Parameters:
  - viewResolver : _A reference to the resolver resource_

Returns: An optional Serial struct

---

### fun `getRoyalties()`

```cadence
func getRoyalties(_ &{Resolver}): Royalties?
```
Helper to get Royalties in a typesafe way

Parameters:
  - viewResolver : _A reference to the resolver resource_

Returns: A optional Royalties struct

---

### fun `getRoyaltyReceiverPublicPath()`

```cadence
func getRoyaltyReceiverPublicPath(): PublicPath
```
Get the path that should be used for receiving royalties
This is a path that will eventually be used for a generic switchboard receiver,
hence the name but will only be used for royalties for now.

Returns: The PublicPath for the generic FT receiver

---

### fun `getMedias()`

```cadence
func getMedias(_ &{Resolver}): Medias?
```
Helper to get Medias in a typesafe way

Parameters:
  - viewResolver : _A reference to the resolver resource_

Returns: A optional Medias struct

---

### fun `getLicense()`

```cadence
func getLicense(_ &{Resolver}): License?
```
Helper to get License in a typesafe way

Parameters:
  - viewResolver : _A reference to the resolver resource_

Returns: A optional License struct

---

### fun `getExternalURL()`

```cadence
func getExternalURL(_ &{Resolver}): ExternalURL?
```
Helper to get ExternalURL in a typesafe way

Parameters:
  - viewResolver : _A reference to the resolver resource_

Returns: A optional ExternalURL struct

---

### fun `getNFTCollectionData()`

```cadence
func getNFTCollectionData(_ &{Resolver}): NFTCollectionData?
```
Helper to get NFTCollectionData in a way that will return an typed Optional

Parameters:
  - viewResolver : _A reference to the resolver resource_

Returns: A optional NFTCollectionData struct

---

### fun `getNFTCollectionDisplay()`

```cadence
func getNFTCollectionDisplay(_ &{Resolver}): NFTCollectionDisplay?
```
Helper to get NFTCollectionDisplay in a way that will return a typed
Optional

Parameters:
  - viewResolver : _A reference to the resolver resource_

Returns: A optional NFTCollection struct

---

### fun `getRarity()`

```cadence
func getRarity(_ &{Resolver}): Rarity?
```
Helper to get Rarity view in a typesafe way

Parameters:
  - viewResolver : _A reference to the resolver resource_

Returns: A optional Rarity struct

---

### fun `getTraits()`

```cadence
func getTraits(_ &{Resolver}): Traits?
```
Helper to get Traits view in a typesafe way

Parameters:
  - viewResolver : _A reference to the resolver resource_

Returns: A optional Traits struct

---

### fun `dictToTraits()`

```cadence
func dictToTraits(dict {String: AnyStruct}, excludedNames [String]?): Traits
```
Helper function to easily convert a dictionary to traits. For NFT
collections that do not need either of the optional values of a Trait,
this method should suffice to give them an array of valid traits.

keys that are not wanted to become `Traits`

Parameters:
  - dict : _The dictionary to be converted to Traits_
  - excludedNames : _An optional String array specifying the `dict`_

Returns: The generated Traits view

---
