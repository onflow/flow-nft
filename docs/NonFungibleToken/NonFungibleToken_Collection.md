# Resource `Collection`

```cadence
pub resource Collection {

    pub var ownedNFTs: {UInt64: NFT}
}
```

Requirement for the concrete resource type
to be declared in the implementing contract

Implemented Interfaces:
  - `Provider`
  - `Receiver`
  - `CollectionPublic`

## Functions

### `withdraw()`

```cadence
fun withdraw(withdrawID: UInt64): NFT
```
Removes an NFT from the collection and moves it to the caller

Parameters:
  - withdrawID : _The ID of the NFT that will be withdrawn_

Returns: The resource containing the desired NFT

---

### `deposit()`

```cadence
fun deposit(token: NFT)
```

---

### `getIDs()`

```cadence
fun getIDs(): [UInt64]
```

---

### `borrowNFT()`

```cadence
fun borrowNFT(id: UInt64): &NFT
```

---
