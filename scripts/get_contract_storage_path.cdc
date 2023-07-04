import MetadataViews from "MetadataViews"
import ViewResolver from "ViewResolver"

pub fun main(addr: Address, name: String): StoragePath? {
    let t = Type<MetadataViews.NFTCollectionData>()
    let borrowedContract = getAccount(addr).contracts.borrow<&ViewResolver>(name: name)
        ?? panic("contract could not be borrowed")

    let view = borrowedContract.resolveView(t)
    if view == nil {
        return nil
    }

    let cd = view! as! MetadataViews.NFTCollectionData
    return cd.storagePath
}
