import FungibleToken from "./utility/FungibleToken.cdc"
/// Royalty views is the contract which tells about the composable royalty standard
/// that gives a unified interface to the marketplaces to provide support for the NFT royalties
///
/// Royalty is a voluntary action can be performed by the marketplace to support the artists and make
/// NFT community vaibrant. It can't be forced as a standard because there is a no way to know whether a
/// transfer of NFT is a trade or just a movement from one wallet to another.
///
/// Note - It is a wider consensus that the payment of royalties should happen in the royalty view and 
/// should be taken care by the marketplace. If the concern is how do the NFT know whether the royalty 
/// get paid or not, To resolve it user can use custom fungible token receivers to emit the events from
/// the NFT and update some state if required.
pub contract RoyaltyViews {
    
    /// Struct to store details of the royalty for a given wallet.
    pub struct Royalty {
        /// Beneficiary of the royalty, It can be the wallet of the artist, minter or anyone whom
        /// royalty get transferred to.
        ///
        /// Using capability to recieve the royalty.
        /// 
        /// Capability would not tell which vault type it would recieve to resolve that we can have a utility function
        /// alongside the Royalty view that checks to see if the receiver is a type that the buyer expects & that
        /// function can be accessed via scripts that the marketplace app can run before listing sales in order to
        /// avoid the issue of users trying to purchase a sale where the royalty receivers do not accept the token they want to purchase it with.
        ///
        /// Recommendation - 
        /// In future we may use the switchboard contract to support multiple vaults. 
        /// Bellow capability should not be the typical `FlowToken` receiver public path.
        /// It should be a new path that temporarily holds a `FlowToken.Receiver` capability so that later,
        /// when the switchboard contract is alive on mainnet, user can easily replace the link with a link
        /// to the switchboard contract without having to update any of the royalty views of our NFTs, which would likely be impossible to do.
        pub let wallet: Capability<&AnyResource{FungibleToken.Receiver}>

        /// It is a multiplier used to calculate the amount of sale value transferred to royalty receiver i.e wallet.
        /// Note - It should lies between 0.0 and 1.0 
        /// Ex - If the sale value is x and multiplier is 0.56 then the royalty value would be 0.56 * x.
        ///
        /// Generally percentage get represented in terms of basis points in solidity based smart contracts while cadence offers `UFix64` that already supports
        /// the basis points use case because its operations are entirely deterministic integer operations and support up to 8 points of precision.
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

    /// Interface to provide details of the royalty.
    pub struct Royalties {

        /// Array to keep the cutInfos 
        access(self) let cutInfos: [Royalty]

        /// Initialize the `Royalties` struct
        pub init(cutInfos: [Royalty]) {
            // Validate that sum of all cut multiplier should not be greater than 1.0
            var totalCut = 0.0
            for royalty in cutInfos {
                totalCut = totalCut + royalty.cut
            }
            assert(totalCut <= 1.0, message: "Sum of cutInfos multiplier cut should not greater than 1.0")
            // Assign the cutInfos
            self.cutInfos = cutInfos
        }

        /// Return the cutInfos list
        pub fun getRoyalties(): [Royalty] {
            return self.cutInfos
        }
    }
}
 