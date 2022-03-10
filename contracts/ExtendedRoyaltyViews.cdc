import FungibleToken from "./utility/FungibleToken.cdc"
/// This is a version of the royalty views that has been extended with potantial utility functions
/// It is a work in progress
pub contract MetadataViews {

    /// Optional interface to provide the helper functions
    /// for better integration of the royalty standard with the marketplace
    /// smart contract or provide help to provide better UI/UX.

    //////////////////////////////////////////////////////////////////
    /// Optional helper functions to facilitate the royalty integration 
    //////////////////////////////////////////////////////////////////

    /// Allow the sale lister to validate whether the beneficary of the royalty
    /// is using the compatible capability with what buyer accepts.
    pub fun checkWalletType(royalties: Royalties, typeToCheck: Type): Bool {
        var hasCorrectType = true
        for royalty in self.cutInfos {
            if !royalty.receiver.isInstance(typeToCheck) {
                hasCorrectType = false
                break
            }
        }
        return hasCorrectType
    }

    /// Specification of the AMOUNT of tokens to send to a specific receiver
    pub struct RoyaltyFor {

        pub let wallet: Capability<&AnyResource{FungibleToken.Receiver}>

        /// The amount of the given token that would get transferred to the beneficiary
        pub let cut: UFix64
        pub let description: String

        init(recepient: Capability<&AnyResource{FungibleToken.Receiver}>, cut: UFix64, description: String) {
            self.wallet = recepient
            self.cut = cut
            self.description = description
        }
    }

    /// Returns the list of the royalties that need to deducted from the sale price and distributed to
    /// the respective recepients.
    /// This method will be useful to support different algorithms to derive the royalty value using `Royalty.cut`, `salePrice` and
    /// other variants (ex- block timestamp) that depends on the implementer of the algorithm.
    pub fun royaltyFor(royalties: Royalties, salePrice: UFix64): [RoyaltyFor] {
        var royaltyValues: [RoyaltyFor] = []
        for royalty in royalties.cutInfos {
            royaltyValues.append(RoyaltyFor(recepient: royalty.wallet, cut: royalty.cut * salePrice, description: royalty.description))
        }
        return royaltyValues
    }
}
 