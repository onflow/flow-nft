# Resource `NFTMinter`

```cadence
resource NFTMinter {
}
```

Resource that an admin or something similar would own to be
able to mint new NFTs
## Functions

### fun `mintNFT()`

```cadence
func mintNFT(recipient &{NonFungibleToken.CollectionPublic}, name String, description String, thumbnail String, royalties [MetadataViews.Royalty])
```
Mints a new NFT with a new ID and deposit it in the
recipients collection using their collection reference

Parameters:
  - recipient : _A capability to the collection where the new NFT will be deposited_
  - name : _The name for the NFT metadata_
  - description : _The description for the NFT metadata_
  - thumbnail : _The thumbnail for the NFT metadata_
  - royalties : _An array of Royalty structs, see MetadataViews docs_

---
