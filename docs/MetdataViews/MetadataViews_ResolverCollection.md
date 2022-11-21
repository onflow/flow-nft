# Resource Interface `ResolverCollection`

```cadence
resource interface ResolverCollection {
}
```

A group of view resolvers indexed by ID.
## Functions

### fun `borrowViewResolver()`

```cadence
func borrowViewResolver(id UInt64): &{Resolver}
```

---

### fun `getIDs()`

```cadence
func getIDs(): [UInt64]
```

---
