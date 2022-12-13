# Resource `NFT`

```cadence
resource NFT {

    id:  UInt64

    name:  String

    description:  String

    thumbnail:  String

    royalties:  [MetadataViews.Royalty]

    metadata:  {String: AnyStruct}
}
```

The core resource that represents a Non Fungible Token.
New instances will be created using the NFTMinter resource
and stored in the Collection resource

Implemented Interfaces:
  - `NonFungibleToken.INFT`
  - `MetadataViews.Resolver`


### Initializer

```cadence
func init(id UInt64, name String, description String, thumbnail String, royalties [MetadataViews.Royalty], metadata {String: AnyStruct})
```


## Functions

### fun `getViews()`

```cadence
func getViews(): [Type]
```
Function that returns all the Metadata Views implemented by a Non Fungible Token

developers to know which parameter to pass to the resolveView() method.

Returns: An array of Types defining the implemented views. This value will be used by

---

### fun `resolveView()`

```cadence
func resolveView(_ Type): AnyStruct?
```
Function that resolves a metadata view for this token.

Parameters:
  - view : _The Type of the desired view._

Returns: A structure representing the requested view.

---
