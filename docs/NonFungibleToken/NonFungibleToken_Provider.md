# Resource Interface `Provider`

```cadence
pub resource interface Provider {
}
```

Interface to mediate withdraws from the Collection
## Functions

### `withdraw()`

```cadence
fun withdraw(withdrawID: UInt64): NFT
```
Removes an NFT from the resource implementing it and moves it to the caller

Parameters:
  - withdrawID : _The ID of the NFT that will be removed_

Returns: The NFT resource removed from the implementing resource

---
