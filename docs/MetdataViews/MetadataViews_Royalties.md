# Struct `Royalties`

```cadence
struct Royalties {

    cutInfos:  [Royalty]
}
```

Wrapper view for multiple Royalty views.
Marketplaces can query this `Royalties` struct from NFTs
and are expected to pay royalties based on these specifications.

### Initializer

```cadence
func init(_ [Royalty])
```


## Functions

### fun `getRoyalties()`

```cadence
func getRoyalties(): [Royalty]
```
Return the cutInfos list

Returns: An array containing all the royalties structs

---
