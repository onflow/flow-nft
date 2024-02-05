/// This transaction is a template for a transaction
/// to create a new link in their account to be used for receiving royalties
/// This transaction can be used for any fungible token, which is specified by the `vaultPath` argument
///
/// If the account wants to receive royalties in FLOW, they'll use `/storage/flowTokenVault`
/// If they want to receive it in USDC, they would use FiatToken.VaultStoragePath
/// and so on.
/// The path used for the public link is a new path that in the future, is expected to receive
/// and generic token, which could be forwarded to the appropriate vault

import "FungibleToken"
import "MetadataViews"

transaction(vaultPath: StoragePath) {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, UnpublishCapability) &Account) {

        // Return early if the account doesn't have a FungibleToken Vault
        if signer.storage.borrow<&{FungibleToken.Receiver}>(from: vaultPath) == nil {
            panic("A vault for the specified fungible token path does not exist")
        }

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        signer.capabilities.unpublish(MetadataViews.getRoyaltyReceiverPublicPath())
        let vaultCap = signer.capabilities.storage.issue<&{FungibleToken.Receiver}>(vaultPath)
        signer.capabilities.publish(vaultCap, at: MetadataViews.getRoyaltyReceiverPublicPath())

    }
}
