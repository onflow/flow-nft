# Struct `EVMBridgedMetadata`

```cadence
pub struct EVMBridgedMetadata {

    pub let name: String

    pub let symbol: String

    pub let uri: {File}
}
```

This view may be used by Cadence-native projects to define contract-
and token-level metadata according to EVM-compatible formats. Several
ERC standards (e.g. ERC20, ERC721, etc.) expose name and symbol values
to define assets as well as contract- & token-level metadata view
`tokenURI(uint256)` and `contractURI()` methods. This view enables
Cadence projects to define in their own contracts how they would like
their metadata to be defined when bridged to EVM.

### Initializer

```cadence
init(name: String, symbol: String, uri: {File}) 
```

---
