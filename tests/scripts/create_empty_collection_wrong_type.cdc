import "ExampleNFT"

/// Attempts to create an ExampleNFT collection using an unsupported NFT type.
/// This should panic with a descriptive error from the type guard in
/// ExampleNFT.createEmptyCollection, confirming that callers cannot silently
/// receive an ExampleNFT.Collection when requesting a different type.
access(all) fun main() {
    // UInt64 is not a valid NFT type — ExampleNFT must reject it
    let collection <- ExampleNFT.createEmptyCollection(nftType: Type<UInt64>())
    destroy collection
}
