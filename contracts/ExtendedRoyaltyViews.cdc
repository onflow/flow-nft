import FungibleToken from "./utility/FungibleToken.cdc"
/// Royalty views is the contract which tells about the composable royalty standard
/// that gives a unified interface to the marketplaces to provide support for the NFT royalties
///
/// Royalty is a voluntary action can be performed by the marketplace to support the artists and make
/// NFT community vaibrant. It can't be forced as a standard because there is a no way to know whether a
/// transfer of NFT is a trade or just a movement from one wallet to another.
pub contract RoyaltyViews {
    
    /// Struct to store details of the royalty for a given wallet.
    pub struct Royalty {
        /// Beneficiary of the royalty, It can be the wallet of the artist, minter or anyone whom
        /// royalty get transferred to.
        ///
        /// Using capability to recieve the royalty.
        pub let wallet: Capability<&AnyResource{FungibleToken.Receiver}>

        /// It is a multiplier used to calculate the amount of sale value transferred to royalty receiver i.e wallet.
        /// Note - It should lies between 0.0 and 1.0 
        /// Ex - If the sale value is x and multiplier is 0.56 then the royalty value would be 0.56 * x.
        pub let cut: UFix64

        /// Description to know about the cause of paying the royalty or what is the
        /// relationship between the `wallet` and the NFT.
        pub let description: String

        init(recepient: Capability<&AnyResource{FungibleToken.Receiver}>, cut: UFix64, description: String) {
            pre {
                cut >= 0.0 && cut <= 1.0 : "Cut value should be in valid range i.e [0,1]"
                recepient.check() : "Couldn't able to borrow the capability"
            }
            self.wallet = recepient
            self.cut = cut
            self.description = description
        }
    }

    pub struct RoyaltyFor {
        /// Beneficiary of the royalty, It can be the wallet of the artist, minter or anyone whom
        /// royalty get transferred to.
        ///
        /// Using capability to recieve the royalty.
        pub let wallet: Capability<&AnyResource{FungibleToken.Receiver}>

        /// It is the value that would get transferred to the beneficiary
        pub let cut: UFix64

        /// Description to know about the cause of paying the royalty or what is the
        /// relationship between the `wallet` and the NFT.
        pub let description: String

        init(recepient: Capability<&AnyResource{FungibleToken.Receiver}>, cut: UFix64, description: String) {
            pre {
                recepient.check() : "Couldn't able to borrow the capability"
            }
            self.wallet = recepient
            self.cut = cut
            self.description = description
        }
    }

    /// Optional interface to provide the helper functions
    /// for better integration of the royalty standard with the marketplace
    /// smart contract or provide help to provide better UI/UX.
    pub struct interface RoyaltyHelpers {

        /// Allow the sale lister to validate whether the beneficary of the royalty
        /// is using the compatible capability with what buyer accepts.
        pub fun checkWalletType(typeToCheck: Type): Bool

        /// Returns the list of the royalties that need to deducted from the sale price and distributed to
        /// the respective recepients.
        /// This method will be useful to support different algorithms to derive the royalty value using `Royalty.cut`, `salePrice` and
        /// other variants (ex- block timestamp) that depends on the implementer of the algorithm.
        pub fun royaltyFor(salePrice: UFix64): [RoyaltyFor]
    }

    /// Interface to provide details of the royalty.
    pub struct Royalties : RoyaltyHelpers {

        /// Array to keep the royalties 
        access(contract) let royalties: [Royalty]

        /// Initialize the `Royalties` struct
        pub init(royalties: [Royalty]) {
            // Validate that sum of all cut multiplier should not be greater than 1.0
           var totalCut = 0.0
            for royalty in royalties {
                totalCut = totalCut + royalty.cut
            }
            assert(totalCut <= 1.0, message: "Sum of royalties multiplier cut should not greater than 1.0")
            // Assign the royalties
            self.royalties = royalties
        }

        //////////////////////////////////////////////////////////////////
        /// Optional helper function to facilitate the royalty integration 
        //////////////////////////////////////////////////////////////////

        /// Allow the sale lister to validate whether the beneficary of the royalty
        /// is using the compatible capability with what buyer accepts.
        pub fun checkWalletType(typeToCheck: Type): Bool {
            var hasCorrectType = true
            for royalty in self.royalties {
                if !royalty.wallet.isInstance(typeToCheck) {
                    hasCorrectType = false
                    break
                }
            }
            return hasCorrectType
        }

        /// Returns the list of the royalties that need to deducted from the sale price and distributed to
        /// the respective recepients.
        /// This method will be useful to support different algorithms to derive the royalty value using `Royalty.cut`, `salePrice` and
        /// other variants (ex- block timestamp) that depends on the implementer of the algorithm.
        pub fun royaltyFor(salePrice: UFix64): [RoyaltyFor] {
            var royaltyValues: [RoyaltyFor] = []
            for royalty in self.royalties {
                royaltyValues.append(RoyaltyFor(recepient: royalty.wallet, cut: royalty.cut * salePrice, description: royalty.description))
            }
            return royaltyValues
        }
    }
}
 