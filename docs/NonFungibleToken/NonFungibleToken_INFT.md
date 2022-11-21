# Resource Interface `INFT`

```cadence
resource interface INFT {

    id:  UInt64
}
```

Interface that the NFTs have to conform to
The metadata views methods are included here temporarily
because enforcing the metadata interfaces in the standard
would break many contracts in an upgrade. Those breaking changes
are being saved for the stable cadence milestone
## Functions

### fun `getViews()`

```cadence
func getViews(): [Type]
```
Function that returns all the Metadata Views implemented by a Non Fungible Token

developers to know which parameter to pass to the resolveView() method.

Returns: An array of Types defining the implemented views. This value will be used by

---

### fun `resolveView()`

```cadence
func resolveView(_ Type): AnyStruct?
```
Function that resolves a metadata view for this token.

Parameters:
  - view : _The Type of the desired view._

Returns: A structure representing the requested view.

---
