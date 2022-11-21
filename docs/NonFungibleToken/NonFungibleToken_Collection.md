# Resource `Collection`

```cadence
resource Collection {

    ownedNFTs:  {UInt64: NFT}
}
```

Requirement for the concrete resource type
to be declared in the implementing contract

Implemented Interfaces:
  - `Provider`
  - `Receiver`
  - `CollectionPublic`

## Functions

### fun `withdraw()`

```cadence
func withdraw(withdrawID UInt64): NFT
```
Removes an NFT from the collection and moves it to the caller

param withdrawID: The ID of the NFT that will be withdrawn
return The resource containing the desired NFT

---

### fun `deposit()`

```cadence
func deposit(token NFT)
```

---

### fun `getIDs()`

```cadence
func getIDs(): [UInt64]
```

---

### fun `borrowNFT()`

```cadence
func borrowNFT(id UInt64): &NFT
```

---
