# Resource Interface `CollectionPublic`

```cadence
pub resource interface CollectionPublic {
}
```

Interface that an account would commonly
publish for their collection
## Functions

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

### `borrowNFTSafe()`

```cadence
fun borrowNFTSafe(id: UInt64): &NFT?
```

---
