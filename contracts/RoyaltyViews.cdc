/// Royalty views is the contract which tells about the composable royalty standard
/// that gives a unified interface to the marketplaces to provide support for the NFT royalties
///
/// Royalty is a voluntary action can be performed by the marketplace to support the artists and make
/// NFT community vaibrant. It can't be forced as a standard because there is a no way to know whether a
/// transfer of NFT is a trade or just a movement from one wallet to another.
pub contract RoyaltyViews {
    
    /// Struct to store details of the royalty for a given recepient.
    pub struct RoyaltyDetails {
        /// Beneficiary of the royalty, It can be the address of the artist, minter or anyone whom
        /// royalty get transferred to.
        ///
        /// Using Address here is intentional to support the receival of different fungible tokens as a sale token.
        /// beacuse capability can only support one type of vault to receive the funds in. Another approach here to 
        /// use the proxy contract that would act as the resolver of capabilities for a given vault.
        pub let recepient: Address

        /// Percentage of sale price in the basis points.
        /// Ex - if the sale price is 100 units and the `royaltyCut` is 2500 then
        /// recepient would receive 25 units as the royalty.
        pub let royaltyCut: UInt64

        /// Optional description to know about the cause of paying the royalty or what is the
        /// relationship between the `recepient` and the NFT.
        pub let description: String?

        init(recepient: Address, royaltyCut: UInt64, description: String?) {
            self.recepient = recepient
            self.royaltyCut = royaltyCut
            self.description = description
        }
    }

    /// Struct to return the royalty.
    /// It is not too much different from the `RoyaltyDetails` struct beside `Royalties.royaltyCut` here is not
    /// in the basis points.
    pub struct Royalties {
        /// Beneficiary of the royalty.
        pub let recepient: Address
        /// Number of units of sale vault entitled to pay as the royalty.
        pub let royaltyCut: UFix64
        /// Optional description.
        pub let description: String?

        init(recepient: Address, royaltyCut: UFix64, description: String?) {
            self.recepient = recepient
            self.royaltyCut = royaltyCut
            self.description = description
        }
    }

    /// Interface to provide details of the royalty.
    pub resource interface Royalty {
        /// Returns the list of the royalties that need to deducted from the sale price and distributed to
        /// the respective recepients.
        pub fun royaltyFor(salePrice: UFix64): [Royalties]
    }

}
 