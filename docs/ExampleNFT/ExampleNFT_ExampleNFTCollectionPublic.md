# Resource Interface `ExampleNFTCollectionPublic`

```cadence
resource interface ExampleNFTCollectionPublic {
}
```

Defines the methods that are particular to this NFT contract collection
## Functions

### fun `deposit()`

```cadence
func deposit(token NonFungibleToken.NFT)
```

---

### fun `getIDs()`

```cadence
func getIDs(): [UInt64]
```

---

### fun `borrowNFT()`

```cadence
func borrowNFT(id UInt64): &NonFungibleToken.NFT
```

---

### fun `borrowExampleNFT()`

```cadence
func borrowExampleNFT(id UInt64): &ExampleNFT.NFT?
```

---
