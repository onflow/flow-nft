import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79

transaction(receiver: Address, amount: UFix64) {
    prepare(account: AuthAccount) {
        let flowVault = account.borrow<&FlowToken.Vault>(
            from: /storage/flowTokenVault
        ) ?? panic("Could not borrow BlpToken.Vault reference")

        let receiverRef = getAccount(receiver)
            .getCapability(/public/flowTokenReceiver)
            .borrow<&FlowToken.Vault{FungibleToken.Receiver}>()
            ?? panic("Could not borrow FungibleToken.Receiver reference")

        let tokens <- flowVault.withdraw(amount: amount)
        receiverRef.deposit(from: <- tokens)
    }
}
