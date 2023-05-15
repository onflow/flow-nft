# Struct `Edition`

```cadence
pub struct Edition {

    pub let name: String?

    pub let number: UInt64

    pub let max: UInt64?
}
```

Optional view for collections that issue multiple objects
with the same or similar metadata, for example an X of 100 set. This
information is useful for wallets and marketplaces.
An NFT might be part of multiple editions, which is why the edition
information is returned as an arbitrary sized array

### Initializer

```cadence
init(name: String?, number: UInt64, max: UInt64?)
```


