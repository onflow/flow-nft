# Struct `Royalty`

```cadence
struct Royalty {

    receiver:  Capability<&AnyResource{FungibleToken.Receiver}>

    cut:  UFix64

    description:  String
}
```

View that defines the composable royalty standard that gives marketplaces a
unified interface to support NFT royalties.

### Initializer

```cadence
func init(receiver Capability<&AnyResource{FungibleToken.Receiver}>, cut UFix64, description String)
```


