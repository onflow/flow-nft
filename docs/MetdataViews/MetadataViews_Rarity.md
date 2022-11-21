# Struct `Rarity`

```cadence
pub struct Rarity {

    pub let score: UFix64?

    pub let max: UFix64?

    pub let description: String?
}
```

View to expose rarity information for a single rarity
Note that a rarity needs to have either score or description but it can
have both

### Initializer

```cadence
init(score: UFix64?, max: UFix64?, description: String?)
```


