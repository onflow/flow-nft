# Contract `ExampleNFT`

```cadence
contract ExampleNFT {

    totalSupply:  UInt64

    CollectionStoragePath:  StoragePath

    CollectionPublicPath:  PublicPath

    MinterStoragePath:  StoragePath
}
```


Implemented Interfaces:
  - `NonFungibleToken`

## Interfaces
    
### resource interface `ExampleNFTCollectionPublic`

```cadence
resource interface ExampleNFTCollectionPublic {
}
```
Defines the methods that are particular to this NFT contract collection

[More...](ExampleNFT_ExampleNFTCollectionPublic.md)

---
## Structs & Resources

### resource `NFT`

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

[More...](ExampleNFT_NFT.md)

---

### resource `Collection`

```cadence
resource Collection {

    ownedNFTs:  {UInt64: NonFungibleToken.NFT}
}
```
The resource that will be holding the NFTs inside any account.
In order to be able to manage NFTs any account will need to create
an empty collection first

[More...](ExampleNFT_Collection.md)

---

### resource `NFTMinter`

```cadence
resource NFTMinter {
}
```
Resource that an admin or something similar would own to be
able to mint new NFTs

[More...](ExampleNFT_NFTMinter.md)

---
## Functions

### fun `createEmptyCollection()`

```cadence
func createEmptyCollection(): NonFungibleToken.Collection
```
Allows anyone to create a new empty collection

Returns: The new Collection resource

---
## Events

### event `ContractInitialized`

```cadence
event ContractInitialized()
```
The event that is emitted when the contract is created

---

### event `Withdraw`

```cadence
event Withdraw(id UInt64, from Address?)
```
The event that is emitted when an NFT is withdrawn from a Collection

---

### event `Deposit`

```cadence
event Deposit(id UInt64, to Address?)
```
The event that is emitted when an NFT is deposited to a Collection

---
