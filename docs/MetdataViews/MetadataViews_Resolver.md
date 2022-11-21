# Resource Interface `Resolver`

```cadence
resource interface Resolver {
}
```

Provides access to a set of metadata views. A struct or
resource (e.g. an NFT) can implement this interface to provide access to
the views that it supports.
## Functions

### fun `getViews()`

```cadence
func getViews(): [Type]
```

---

### fun `resolveView()`

```cadence
func resolveView(_ Type): AnyStruct?
```

---
