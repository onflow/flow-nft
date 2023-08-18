// Taken from the NFT Metadata standard, this contract exposes an interface to let 
// anyone borrow a contract and resolve views on it.
//
// This will allow you to obtain information about a contract without necessarily knowing anything about it.
// All you need is its address and name and you're good to go!
access(all) contract interface ViewResolver {
    /// Function that returns all the Metadata Views implemented by the resolving contract
    ///
    /// @return An array of Types defining the implemented views. This value will be used by
    ///         developers to know which parameter to pass to the resolveView() method.
    ///
    access(all) view fun getViews(): [Type] {
        return []
    }

    /// Function that resolves a metadata view for this token.
    ///
    /// @param view: The Type of the desired view.
    /// @return A structure representing the requested view.
    ///
    access(all) fun resolveView(_ view: Type): AnyStruct? {
        return nil
    }

    /// Provides access to a set of metadata views. A struct or 
    /// resource (e.g. an NFT) can implement this interface to provide access to 
    /// the views that it supports.
    ///
    access(all) resource interface Resolver {
        access(all) view fun getViews(): [Type] {
            return []
        }
        access(all) fun resolveView(_ view: Type): AnyStruct? {
            return nil
        }
    }

    /// A group of view resolvers indexed by ID.
    ///
    access(all) resource interface ResolverCollection {
        access(all) view fun borrowViewResolver(id: UInt64): &{Resolver}? {
            pre { true: "dummy" }
        }
        access(all) view fun getIDs(): [UInt64] {
            pre { true: "dummy" }
        }
    }
}
 