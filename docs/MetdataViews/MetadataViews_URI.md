# Struct `URI`

```cadence
pub struct URI {

    pub let baseURI: String?

    access(self) let value: String
}
```

View to represent a generic URI. May be used to represent the URI of
the NFT where the type of URI is not able to be determined (i.e. HTTP,
IPFS, etc.)

Implemented Interfaces:
  - `File`


### Initializer

```cadence
init(baseURI: String?, value: String?)
```


## Functions

### `uri()`

```cadence
view fun uri(): String
```
This function returns the uri for this file. If the `baseURI` is set,
this will be a concatenation of the `baseURI` and the `value`. If the
`baseURI` is not set, this will return the `value`.

Returns: The string containing the file uri

---
