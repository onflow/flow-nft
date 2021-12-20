pub contract Views {

    pub resource interface Resolver {
        pub fun getViews(): [Type]
        pub fun resolveView(_ view: Type): AnyStruct?
    }

    pub resource interface ResolverCollection {
        pub fun borrowViewResolver(id: UInt64): &{Resolver}
        pub fun getIDs(): [UInt64]
    }

    pub struct Display {
        pub let name: String
        pub let thumbnail: String
        pub let description: String

        init(
            name: String,
            thumbnail: String,
            description: String,
        ) {
            self.name=name
            self.thumbnail=thumbnail
            self.description=description
        }
    }
}
