pub contract Metadata {

    pub resource interface ViewResolver {
        pub fun getViews(): [Type]
        pub fun resolveView(_ view: Type): AnyStruct?
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
