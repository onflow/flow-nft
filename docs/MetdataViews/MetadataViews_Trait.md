# Struct `Trait`

```cadence
pub struct Trait {

    pub let name: String

    pub let value: AnyStruct

    pub let displayType: String?

    pub let rarity: Rarity?
}
```

View to represent a single field of metadata on an NFT.
This is used to get traits of individual key/value pairs along with some
contextualized data about the trait

### Initializer

```cadence
init(name: String, value: AnyStruct, displayType: String?, rarity: Rarity?)
```


