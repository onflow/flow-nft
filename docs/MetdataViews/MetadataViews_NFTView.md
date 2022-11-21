# Struct `NFTView`

```cadence
struct NFTView {

    id:  UInt64

    uuid:  UInt64

    display:  Display?

    externalURL:  ExternalURL?

    collectionData:  NFTCollectionData?

    collectionDisplay:  NFTCollectionDisplay?

    royalties:  Royalties?

    traits:  Traits?
}
```

NFTView wraps all Core views along `id` and `uuid` fields, and is used
to give a complete picture of an NFT. Most NFTs should implement this
view.

### Initializer

```cadence
func init(id UInt64, uuid UInt64, display Display?, externalURL ExternalURL?, collectionData NFTCollectionData?, collectionDisplay NFTCollectionDisplay?, royalties Royalties?, traits Traits?)
```


