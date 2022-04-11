
// This transaction is a template for a transaction
// to add a Vault resource to their account
// so that they can use the exampleToken

import FungibleToken from 0xFUNGIBLETOKENADDRESS
import MetadataViews from "../../contracts/MetadataViews.cdc"

transaction {

    prepare(signer: AuthAccount, vaultPath: StoragePath) {

        // Return early if the account doesn't have a FungibleToken Vault
        if signer.borrow<&FungibleToken.Vault>(from: vaultPath) == nil {
            return
        }

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        signer.link<&FungibleToken.Vault{FungibleToken.Receiver, FungibleToken.Balance}>(
            MetadataViews.getRoyaltyReceiverPublicPath(),
            target: vaultPath
        )
    }
}