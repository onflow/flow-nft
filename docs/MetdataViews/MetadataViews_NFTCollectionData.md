# Struct `NFTCollectionData`

```cadence
struct NFTCollectionData {

    storagePath:  StoragePath

    publicPath:  PublicPath

    providerPath:  PrivatePath

    publicCollection:  Type

    publicLinkedType:  Type

    providerLinkedType:  Type

    createEmptyCollection:  ((): @NonFungibleToken.Collection)
}
```

View to expose the information needed store and retrieve an NFT.
This can be used by applications to setup a NFT collection with proper
storage and public capabilities.

### Initializer

```cadence
func init(storagePath StoragePath, publicPath PublicPath, providerPath PrivatePath, publicCollection Type, publicLinkedType Type, providerLinkedType Type, createEmptyCollectionFunction ((): @NonFungibleToken.Collection))
```


