/// This script uses the NFTMinter resource to mint a new NFT
/// It must be run with the account that has the minter resource
/// stored in /storage/NFTMinter
///
/// The royalty arguments indicies must be aligned

import "NonFungibleToken"
import "ExampleNFT"
import "MetadataViews"
import "FungibleToken"

transaction(
    recipient: Address,
    name: String,
    description: String,
    thumbnail: String,
    cuts: [UFix64],
    royaltyDescriptions: [String],
    royaltyBeneficiaries: [Address]
) {

    /// local variable for storing the minter reference
    let minter: &ExampleNFT.NFTMinter

    /// Reference to the receiver's collection
    let recipientCollectionRef: &{NonFungibleToken.Receiver}

    prepare(signer: auth(BorrowValue) &Account) {

        let collectionData = ExampleNFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve NFTCollectionData view. The ExampleNFT contract needs to implement the NFTCollectionData Metadata view in order to execute this transaction")
        
        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.storage.borrow<&ExampleNFT.NFTMinter>(from: ExampleNFT.MinterStoragePath)
            ?? panic("The signer does not store an ExampleNFT.Minter object at the path "
                     .concat(ExampleNFT.MinterStoragePath.toString())
                     .concat("The signer must initialize their account with this minter resource first!"))

        // Borrow the recipient's public NFT collection reference
        self.recipientCollectionRef = getAccount(recipient).capabilities.borrow<&{NonFungibleToken.Receiver}>(collectionData.publicPath)
            ?? panic("The recipient does not have a NonFungibleToken Receiver at "
                    .concat(collectionData.publicPath.toString())
                    .concat(" that is capable of receiving an NFT.")
                    .concat("The recipient must initialize their account with this collection and receiver first!"))
    }

    pre {
        cuts.length == royaltyDescriptions.length && cuts.length == royaltyBeneficiaries.length: "Array length should be equal for royalty related details"
    }

    execute {

        // Create the royalty details
        var count = 0
        var royalties: [MetadataViews.Royalty] = []
        while royaltyBeneficiaries.length > count {
            let beneficiary = royaltyBeneficiaries[count]
            let beneficiaryCapability = getAccount(beneficiary).capabilities.get<&{FungibleToken.Receiver}>(
                MetadataViews.getRoyaltyReceiverPublicPath()
            )

            if !beneficiaryCapability.check() {
                panic("The royalty beneficiary "
                       .concat(beneficiary.toString())
                       .concat(" does not have a FungibleToken Receiver configured at ")
                       .concat(MetadataViews.getRoyaltyReceiverPublicPath().toString())
                       .concat(". They should set up a FungibleTokenSwitchboard Receiver at this path to receive any type of Fungible Token"))
            }

            royalties.append(
                MetadataViews.Royalty(
                    receiver: beneficiaryCapability,
                    cut: cuts[count],
                    description: royaltyDescriptions[count]
                )
            )
            count = count + 1
        }


        // Mint the NFT and deposit it to the recipient's collection
        let mintedNFT <- self.minter.mintNFT(
            name: name,
            description: description,
            thumbnail: thumbnail,
            royalties: royalties
        )
        self.recipientCollectionRef.deposit(token: <-mintedNFT)
    }

}
