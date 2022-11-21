# Contract Interface `NonFungibleToken`

```cadence
contract interface NonFungibleToken {

    totalSupply:  UInt64
}
```

The main NFT contract interface. Other NFT contracts will
import and implement this interface
## Interfaces
    
### resource interface `INFT`

```cadence
resource interface INFT {

    id:  UInt64
}
```
Interface that the NFTs have to conform to
The metadata views methods are included here temporarily
because enforcing the metadata interfaces in the standard
would break many contracts in an upgrade. Those breaking changes
are being saved for the stable cadence milestone

[More...](NonFungibleToken_INFT.md)

---
    
### resource interface `Provider`

```cadence
resource interface Provider {
}
```
Interface to mediate withdraws from the Collection

[More...](NonFungibleToken_Provider.md)

---
    
### resource interface `Receiver`

```cadence
resource interface Receiver {
}
```
Interface to mediate deposits to the Collection

[More...](NonFungibleToken_Receiver.md)

---
    
### resource interface `CollectionPublic`

```cadence
resource interface CollectionPublic {
}
```
Interface that an account would commonly
publish for their collection

[More...](NonFungibleToken_CollectionPublic.md)

---
## Structs & Resources

### resource `NFT`

```cadence
resource NFT {

    id:  UInt64
}
```
Requirement that all conforming NFT smart contracts have
to define a resource called NFT that conforms to INFT

[More...](NonFungibleToken_NFT.md)

---

### resource `Collection`

```cadence
resource Collection {

    ownedNFTs:  {UInt64: NFT}
}
```
Requirement for the concrete resource type
to be declared in the implementing contract

[More...](NonFungibleToken_Collection.md)

---
## Functions

### fun `createEmptyCollection()`

```cadence
func createEmptyCollection(): Collection
```
Creates an empty Collection and returns it to the caller so that they can own NFTs

return A new Collection resource

---
## Events

### event `ContractInitialized`

```cadence
event ContractInitialized()
```
Event that emitted when the NFT contract is initialized

---

### event `Withdraw`

```cadence
event Withdraw(id UInt64, from Address?)
```
Event that is emitted when a token is withdrawn,
indicating the owner of the collection that it was withdrawn from.

If the collection is not in an account's storage, `from` will be `nil`.

---

### event `Deposit`

```cadence
event Deposit(id UInt64, to Address?)
```
Event that emitted when a token is deposited to a collection.

It indicates the owner of the collection that it was deposited to.

---
