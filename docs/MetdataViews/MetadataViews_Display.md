# Struct `Display`

```cadence
struct Display {

    name:  String

    description:  String

    thumbnail:  AnyStruct{File}
}
```

Display is a basic view that includes the name, description and
thumbnail for an object. Most objects should implement this view.

### Initializer

```cadence
func init(name String, description String, thumbnail AnyStruct{File})
```


