# Struct `Display`

```cadence
pub struct Display {

    pub let name: String

    pub let description: String

    pub let thumbnail: AnyStruct{File}
}
```

Display is a basic view that includes the name, description and
thumbnail for an object. Most objects should implement this view.

### Initializer

```cadence
init(name: String, description: String, thumbnail: AnyStruct{File})
```


