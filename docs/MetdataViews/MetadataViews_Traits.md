# Struct `Traits`

```cadence
pub struct Traits {

    pub let traits: [Trait]
}
```

Wrapper view to return all the traits on an NFT.
This is used to return traits as individual key/value pairs along with
some contextualized data about each trait.

### Initializer

```cadence
init(_: [Trait])
```


## Functions

### `addTrait()`

```cadence
fun addTrait(_: Trait)
```
Adds a single Trait to the Traits view

Parameters:
  - Trait : _The trait struct to be added_

---
