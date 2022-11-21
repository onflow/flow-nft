# Struct `IPFSFile`

```cadence
struct IPFSFile {

    cid:  String

    path:  String?
}
```

View to expose a file stored on IPFS.
IPFS images are referenced by their content identifier (CID)
rather than a direct URI. A client application can use this CID
to find and load the image via an IPFS gateway.

Implemented Interfaces:
  - `File`


### Initializer

```cadence
func init(cid String, path String?)
```


## Functions

### fun `uri()`

```cadence
func uri(): String
```
This function returns the IPFS native URL for this file.
Ref: https://docs.ipfs.io/how-to/address-ipfs-on-web/#native-urls

Returns: The string containing the file uri

---
