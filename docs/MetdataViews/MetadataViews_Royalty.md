# Struct `Royalty`

```cadence
pub struct Royalty {

    pub let receiver: Capability<&AnyResource{FungibleToken.Receiver}>

    pub let cut: UFix64

    pub let description: String
}
```

View that defines the composable royalty standard that gives marketplaces a
unified interface to support NFT royalties.

### Initializer

```cadence
init(receiver: Capability<&AnyResource{FungibleToken.Receiver}>, cut: UFix64, description: String)
```


