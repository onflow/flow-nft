import NonFungibleToken from 0xNFTADDRESS
import ExampleNFT from 0x0xNFTCONTRACTADDRESS

// This transaction returns an array of all the nft ids in the collection

pub fun main(account: Address): [UInt64] {
    let acct = getAccount(account)
    let collectionRef = acct.getCapability(/public/%s)!.borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs()
}
 