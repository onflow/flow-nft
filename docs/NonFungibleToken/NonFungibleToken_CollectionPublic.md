# Resource Interface `CollectionPublic`

```cadence
resource interface CollectionPublic {
}
```

Interface that an account would commonly
publish for their collection
## Functions

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

### fun `borrowNFTSafe()`

```cadence
func borrowNFTSafe(id UInt64): &NFT?
```

---
