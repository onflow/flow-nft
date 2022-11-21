# Resource Interface `Provider`

```cadence
resource interface Provider {
}
```

Interface to mediate withdraws from the Collection
## Functions

### fun `withdraw()`

```cadence
func withdraw(withdrawID UInt64): NFT
```
Removes an NFT from the resource implementing it and moves it to the caller

param withdrawID: The ID of the NFT that will be removed
return The NFT resource removed from the implementing resource

---
