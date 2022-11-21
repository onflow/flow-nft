# Struct `Rarity`

```cadence
struct Rarity {

    score:  UFix64?

    max:  UFix64?

    description:  String?
}
```

View to expose rarity information for a single rarity
Note that a rarity needs to have either score or description but it can
have both

### Initializer

```cadence
func init(score UFix64?, max UFix64?, description String?)
```


