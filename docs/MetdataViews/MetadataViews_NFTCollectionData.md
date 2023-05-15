# Struct `NFTCollectionData`

```cadence
pub struct NFTCollectionData {

    pub let storagePath: StoragePath

    pub let publicPath: PublicPath

    pub let providerPath: PrivatePath

    pub let publicCollection: Type

    pub let publicLinkedType: Type

    pub let providerLinkedType: Type

    pub let createEmptyCollection: ((): @NonFungibleToken.Collection)
}
```

View to expose the information needed store and retrieve an NFT.
This can be used by applications to setup a NFT collection with proper
storage and public capabilities.

### Initializer

```cadence
init(storagePath: StoragePath, publicPath: PublicPath, providerPath: PrivatePath, publicCollection: Type, publicLinkedType: Type, providerLinkedType: Type, createEmptyCollectionFunction: ((): @NonFungibleToken.Collection))
```


