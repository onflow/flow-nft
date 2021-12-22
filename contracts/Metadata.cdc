pub contract Metadata {

    pub resource interface ViewResolver {
        pub fun getViews(): [Type]
        pub fun resolveView(_ view: Type): AnyStruct?
    }

    pub struct Display {
        pub let name: String
        pub let description: String

        init(
            name: String,
            description: String,
        ) {
            self.name=name
            self.description=description
        }
    }

    pub struct Thumbnail {
        pub let uri: String
        pub let mimetype: String

        init(
            uri: String,
            mimetype: String,
        ) {
            self.uri=uri
            self.mimetype=mimetype
        }
    }
}
