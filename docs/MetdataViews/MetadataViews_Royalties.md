# Struct `Royalties`

```cadence
pub struct Royalties {

    priv let cutInfos: [Royalty]
}
```

Wrapper view for multiple Royalty views.
Marketplaces can query this `Royalties` struct from NFTs
and are expected to pay royalties based on these specifications.

### Initializer

```cadence
init(_: [Royalty])
```


## Functions

### `getRoyalties()`

```cadence
fun getRoyalties(): [Royalty]
```
Return the cutInfos list

Returns: An array containing all the royalties structs

---
