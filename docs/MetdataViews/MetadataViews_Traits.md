# Struct `Traits`

```cadence
struct Traits {

    traits:  [Trait]
}
```

Wrapper view to return all the traits on an NFT.
This is used to return traits as individual key/value pairs along with
some contextualized data about each trait.

### Initializer

```cadence
func init(_ [Trait])
```


## Functions

### fun `addTrait()`

```cadence
func addTrait(_ Trait)
```
Adds a single Trait to the Traits view

Parameters:
  - Trait : _The trait struct to be added_

---
