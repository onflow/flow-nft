# Struct `Pack`

```cadence
pub struct Pack {
    pub let status: PackStatus

}
```

View to return the status of an nft if it is a pack.

NOTE: **This view should only be supported if it is a pack**

### Initializer

```cadence
init(_ status: PackStatus)
```


## Functions

### `isOpened()`

```cadence
pub fun isOpen(): Bool
```
Returns a boolean marking whether this pack has been opened or not

Parameters: None

---
