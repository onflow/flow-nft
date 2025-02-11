import "ExampleNFT"
import "MetadataViews"
import "CrossVMMetadataViews"
import "ViewResolver"
import "EVM"

access(all) struct NFTView {
    access(all) let id: UInt64
    access(all) let name: String
    access(all) let symbol: String
    access(all) let nftType: Type
    access(all) let cadenceContractAddress: Address
    access(all) let nativeVM: CrossVMMetadataViews.VM
    access(all) let evmMetadata: String

    init(
        id: UInt64,
        name: String,
        symbol: String,
        nftType: Type,
        cadenceContractAddress: Address,
        nativeVM: CrossVMMetadataViews.VM,
        evmMetadata: String
    ) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.nftType = nftType
        self.cadenceContractAddress = cadenceContractAddress
        self.nativeVM = nativeVM
        self.evmMetadata = evmMetadata
    }
}

access(all) fun main(address: Address, id: UInt64): NFTView {
    let account = getAccount(address)

    let collectionData = ExampleNFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve NFTCollectionData view. The ExampleNFT contract needs to implement the NFTCollectionData Metadata view in order to execute this transaction")

    let collection = account.capabilities.borrow<&ExampleNFT.Collection>(
            collectionData.publicPath
    ) ?? panic("The account ".concat(address.toString()).concat(" does not have a NonFungibleToken Collection at ")
                .concat(collectionData.publicPath.toString())
                .concat(". The account must initialize their account with this collection first!"))

    let viewResolver = collection.borrowViewResolver(id: id) 
        ?? panic("Could not borrow resolver with given id ".concat(id.toString()))

    let evmBridgedMetadata = MetadataViews.getEVMBridgedMetadata(viewResolver)
        ?? panic("Example NFT id ".concat(id.toString()).concat(" did not resolve EVMBridgedMetadata view"))
    let evmPointer = CrossVMMetadataViews.getEVMPointer(viewResolver)
        ?? panic("Example NFT id ".concat(id.toString()).concat(" did not resolve EVMPointer view"))
    let evmBytesMetadata = CrossVMMetadataViews.getEVMBytesMetadata(viewResolver)
        ?? panic("Example NFT id ".concat(id.toString()).concat(" did not resolve EVMBytesMetadata view"))

    let decodedBytesMetadata = EVM.decodeABI(types: [Type<String>()], data: evmBytesMetadata.bytes.value)
    let bytesMetadataAsString = decodedBytesMetadata[0] as! String


    return NFTView(
        id: id,
        name: evmBridgedMetadata.name,
        symbol: evmBridgedMetadata.symbol,
        nftType: evmPointer.cadenceType,
        cadenceContractAddress: evmPointer.cadenceContractAddress,
        nativeVM: evmPointer.nativeVM,
        evmMetadata: bytesMetadataAsString
    )
}
