// Taken from the NFT Metadata standard, this contract exposes an interface to let 
// anyone borrow a contract and resolve views on it.
//
// This will allow you to obtain information about a contract without necessarily knowing anything about it.
// All you need is its address and name and you're good to go!
pub contract interface ViewResolver {
    /// Function that returns all the Metadata Views implemented by the resolving contract
    ///
    /// @return An array of Types defining the implemented views. This value will be used by
    ///         developers to know which parameter to pass to the resolveView() method.
    ///
    pub fun getViews(): [Type] {
        return []
    }

    /// Function that resolves a metadata view for this token.
    ///
    /// @param view: The Type of the desired view.
    /// @return A structure representing the requested view.
    ///
    pub fun resolveView(_ view: Type): AnyStruct? {
        return nil
    }

    /// Provides access to a set of metadata views. A struct or 
    /// resource (e.g. an NFT) can implement this interface to provide access to 
    /// the views that it supports.
    ///
    pub resource interface Resolver {
        pub fun getViews(): [Type]
        pub fun resolveView(_ view: Type): AnyStruct?
    }

    /// A group of view resolvers indexed by ID.
    ///
    pub resource interface ResolverCollection {
        pub fun borrowViewResolver(id: UInt64): &{Resolver}?
        pub fun getIDs(): [UInt64]
    }
}
 