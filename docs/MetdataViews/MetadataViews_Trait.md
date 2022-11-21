# Struct `Trait`

```cadence
struct Trait {

    name:  String

    value:  AnyStruct

    displayType:  String?

    rarity:  Rarity?
}
```

View to represent a single field of metadata on an NFT.
This is used to get traits of individual key/value pairs along with some
contextualized data about the trait

### Initializer

```cadence
func init(name String, value AnyStruct, displayType String?, rarity Rarity?)
```


