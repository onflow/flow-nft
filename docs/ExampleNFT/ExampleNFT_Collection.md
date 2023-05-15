# Resource `Collection`

```cadence
resource Collection {

    ownedNFTs:  {UInt64: NonFungibleToken.NFT}
}
```

The resource that will be holding the NFTs inside any account.
In order to be able to manage NFTs any account will need to create
an empty collection first

Implemented Interfaces:
  - `ExampleNFTCollectionPublic`
  - `NonFungibleToken.Provider`
  - `NonFungibleToken.Receiver`
  - `NonFungibleToken.CollectionPublic`
  - `MetadataViews.ResolverCollection`


### Initializer

```cadence
func init()
```


## Functions

### fun `withdraw()`

```cadence
func withdraw(withdrawID UInt64): NonFungibleToken.NFT
```
Removes an NFT from the collection and moves it to the caller

Parameters:
  - withdrawID : _The ID of the NFT that wants to be withdrawn_

Returns: The NFT resource that has been taken out of the collection

---

### fun `deposit()`

```cadence
func deposit(token NonFungibleToken.NFT)
```
Adds an NFT to the collections dictionary and adds the ID to the id array

Parameters:
  - token : _The NFT resource to be included in the collection_

---

### fun `getIDs()`

```cadence
func getIDs(): [UInt64]
```
Helper method for getting the collection IDs

Returns: An array containing the IDs of the NFTs in the collection

---

### fun `borrowNFT()`

```cadence
func borrowNFT(id UInt64): &NonFungibleToken.NFT
```
Gets a reference to an NFT in the collection so that
the caller can read its metadata and call its methods

Parameters:
  - id : _The ID of the wanted NFT_

Returns: A reference to the wanted NFT resource

---

### fun `borrowExampleNFT()`

```cadence
func borrowExampleNFT(id UInt64): &ExampleNFT.NFT?
```
Gets a reference to an NFT in the collection so that
the caller can read its metadata and call its methods

Parameters:
  - id : _The ID of the wanted NFT_

Returns: A reference to the wanted NFT resource

---

### fun `borrowViewResolver()`

```cadence
func borrowViewResolver(id UInt64): &AnyResource{MetadataViews.Resolver}
```
Gets a reference to the NFT only conforming to the `{MetadataViews.Resolver}`
interface so that the caller can retrieve the views that the NFT
is implementing and resolve them

Parameters:
  - id : _The ID of the wanted NFT_

Returns: The resource reference conforming to the Resolver interface

---
