# Struct `NFTView`

```cadence
pub struct NFTView {

    pub let id: UInt64

    pub let uuid: UInt64

    pub let display: Display?

    pub let externalURL: ExternalURL?

    pub let collectionData: NFTCollectionData?

    pub let collectionDisplay: NFTCollectionDisplay?

    pub let royalties: Royalties?

    pub let traits: Traits?
}
```

NFTView wraps all Core views along `id` and `uuid` fields, and is used
to give a complete picture of an NFT. Most NFTs should implement this
view.

### Initializer

```cadence
init(id: UInt64, uuid: UInt64, display: Display?, externalURL: ExternalURL?, collectionData: NFTCollectionData?, collectionDisplay: NFTCollectionDisplay?, royalties: Royalties?, traits: Traits?)
```


