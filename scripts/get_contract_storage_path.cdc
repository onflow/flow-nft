import MetadataViews from "../../contracts/MetadataViews.cdc"
import Resolver from "../../contracts/Resolver.cdc"

pub fun main(addr: Address, name: String): AnyStruct? {
    let t = Type<MetadataViews.NFTCollectionData>()
    let borrowedContract = getAccount(addr).contracts.borrow<&Resolver>(name: name) ?? panic("contract could not be borrowed")

    let view = borrowedContract.resolveView(t)
    if view == nil {
      return nil
    }

    let cd = view! as! MetadataViews.NFTCollectionData
    return cd.storagePath
}
