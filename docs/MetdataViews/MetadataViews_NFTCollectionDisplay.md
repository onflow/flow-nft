# Struct `NFTCollectionDisplay`

```cadence
pub struct NFTCollectionDisplay {

    pub let name: String

    pub let description: String

    pub let externalURL: ExternalURL

    pub let squareImage: Media

    pub let bannerImage: Media

    pub let socials: {String: ExternalURL}
}
```

View to expose the information needed to showcase this NFT's
collection. This can be used by applications to give an overview and
graphics of the NFT collection this NFT belongs to.

### Initializer

```cadence
init(name: String, description: String, externalURL: ExternalURL, squareImage: Media, bannerImage: Media, socials: {String: ExternalURL})
```


