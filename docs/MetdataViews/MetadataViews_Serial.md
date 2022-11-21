# Struct `Serial`

```cadence
struct Serial {

    number:  UInt64
}
```

View representing a project-defined serial number for a specific NFT
Projects have different definitions for what a serial number should be
Some may use the NFTs regular ID and some may use a different
classification system. The serial number is expected to be unique among
other NFTs within that project

### Initializer

```cadence
func init(_ UInt64)
```


