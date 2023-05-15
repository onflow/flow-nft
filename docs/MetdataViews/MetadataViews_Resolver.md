# Resource Interface `Resolver`

```cadence
pub resource interface Resolver {
}
```

Provides access to a set of metadata views. A struct or
resource (e.g. an NFT) can implement this interface to provide access to
the views that it supports.
## Functions

### `getViews()`

```cadence
fun getViews(): [Type]
```

---

### `resolveView()`

```cadence
fun resolveView(_: Type): AnyStruct?
```

---
