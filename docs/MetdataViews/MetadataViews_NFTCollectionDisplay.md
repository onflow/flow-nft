# Struct `NFTCollectionDisplay`

```cadence
struct NFTCollectionDisplay {

    name:  String

    description:  String

    externalURL:  ExternalURL

    squareImage:  Media

    bannerImage:  Media

    socials:  {String: ExternalURL}
}
```

View to expose the information needed to showcase this NFT's
collection. This can be used by applications to give an overview and
graphics of the NFT collection this NFT belongs to.

### Initializer

```cadence
func init(name String, description String, externalURL ExternalURL, squareImage Media, bannerImage Media, socials {String: ExternalURL})
```


