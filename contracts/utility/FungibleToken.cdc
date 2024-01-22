/**

# The Flow Fungible Token standard

## `FungibleToken` contract

The Fungible Token standard is no longer an interface
that all fungible token contracts would have to conform to.

If a users wants to deploy a new token contract, their contract
does not need to implement the FungibleToken interface, but their tokens
do need to implement the interfaces defined in this contract.

## `Vault` resource interface

Each fungible token resource type needs to implement the `Vault` resource interface.

## `Provider`, `Receiver`, and `Balance` resource interfaces

These interfaces declare pre-conditions and post-conditions that restrict
the execution of the functions in the Vault.

They are separate because it gives the user the ability to share
a reference to their Vault that only exposes the fields functions
in one or more of the interfaces.

It also gives users the ability to make custom resources that implement
these interfaces to do various things with the tokens.
For example, a faucet can be implemented by conforming
to the Provider interface.

*/

import ViewResolver from "ViewResolver"

/// FungibleToken
///
/// Fungible Token implementations are no longer required to implement the fungible token
/// interface. We still have it as an interface here because there are some useful
/// utility methods that many projects will still want to have on their contracts,
/// but they are by no means required. all that is required is that the token
/// implements the `Vault` interface
access(all) contract interface FungibleToken: ViewResolver {

    // An entitlement for allowing the withdrawal of tokens from a Vault
    access(all) entitlement Withdraw

    /// The event that is emitted when tokens are withdrawn from a Vault
    access(all) event Withdrawn(amount: UFix64, type: String, from: Address?, fromUUID: UInt64, withdrawnUUID: UInt64)

    /// The event that is emitted when tokens are deposited to a Vault
    access(all) event Deposited(amount: UFix64, type: String, to: Address?, toUUID: UInt64, depositedUUID: UInt64)

    /// Event that is emitted when the global burn method is called with a non-zero balance
    access(all) event Burned(amount: UFix64, type: String, fromUUID: UInt64)

    /// Balance
    ///
    /// The interface that provides standard functions\
    /// for getting balance information
    ///
    access(all) resource interface Balance {
        /// Get the balance of the vault
        access(all) view fun getBalance(): UFix64
    }

    /// Provider
    ///
    /// The interface that enforces the requirements for withdrawing
    /// tokens from the implementing type.
    ///
    /// It does not enforce requirements on `balance` here,
    /// because it leaves open the possibility of creating custom providers
    /// that do not necessarily need their own balance.
    ///
    access(all) resource interface Provider {

        /// withdraw subtracts tokens from the implementing resource
        /// and returns a Vault with the removed tokens.
        ///
        /// The function's access level is `access(Withdraw)`
        /// So in order to access it, one would either need the object itself
        /// or an entitled reference with `Withdraw`.
        ///
        access(Withdraw) fun withdraw(amount: UFix64): @{Vault} {
            post {
                // `result` refers to the return value
                result.getBalance() == amount:
                    "Withdrawal amount must be the same as the balance of the withdrawn Vault"
                emit Withdrawn(amount: amount, type: self.getType().identifier, from: self.owner?.address, fromUUID: self.uuid, withdrawnUUID: result.uuid)
            }
        }
    }

    /// Receiver
    ///
    /// The interface that enforces the requirements for depositing
    /// tokens into the implementing type.
    ///
    /// We do not include a condition that checks the balance because
    /// we want to give users the ability to make custom receivers that
    /// can do custom things with the tokens, like split them up and
    /// send them to different places.
    ///
    access(all) resource interface Receiver {

        /// deposit takes a Vault and deposits it into the implementing resource type
        ///
        access(all) fun deposit(from: @{Vault})

        /// getSupportedVaultTypes optionally returns a list of vault types that this receiver accepts
        access(all) view fun getSupportedVaultTypes(): {Type: Bool}

        /// Returns whether or not the given type is accepted by the Receiver
        /// A vault that can accept any type should just return true by default
        access(all) view fun isSupportedVaultType(type: Type): Bool
    }

    /// Vault
    ///
    /// Ideally, this interface would also conform to Receiver, Balance, Transferor, Provider, and Resolver
    /// but that is not supported yet
    ///
    access(all) resource interface Vault: Receiver, Provider, Balance, ViewResolver.Resolver {

        /// Field that tracks the balance of a vault
        access(all) var balance: UFix64

        /// Get the balance of the vault
        access(all) view fun getBalance(): UFix64

        /// getSupportedVaultTypes optionally returns a list of vault types that this receiver accepts
        /// The default implementation is included here because vaults are expected
        /// to only accepted their own type, so they have no need to provide an implementation
        /// for this function
        access(all) view fun getSupportedVaultTypes(): {Type: Bool} {
            // Below check is implemented to make sure that run-time type would
            // only get returned when the parent resource conforms with `FungibleToken.Vault`. 
            if self.getType().isSubtype(of: Type<@{FungibleToken.Vault}>()) {
                return {self.getType(): true}
            } else {
                // Return an empty dictionary as the default value for resource who don't
                // implement `FungibleToken.Vault`, such as `FungibleTokenSwitchboard`, `TokenForwarder` etc.
                return {}
            }
        }

        /// Checks if the given type is supported by this Vault
        access(all) view fun isSupportedVaultType(type: Type): Bool {
            return self.getSupportedVaultTypes()[type] ?? false
        }

        /// withdraw subtracts `amount` from the Vault's balance
        /// and returns a new Vault with the subtracted balance
        ///
        access(Withdraw) fun withdraw(amount: UFix64): @{Vault} {
            pre {
                self.getBalance() >= amount:
                    "Amount withdrawn must be less than or equal than the balance of the Vault"
            }
            post {
                // use the special function `before` to get the value of the `balance` field
                // at the beginning of the function execution
                //
                self.getBalance() == before(self.getBalance()) - amount:
                    "New Vault balance must be the difference of the previous balance and the withdrawn Vault balance"
            }
        }

        /// deposit takes a Vault and adds its balance to the balance of this Vault
        ///
        access(all) fun deposit(from: @{FungibleToken.Vault}) {
            // Assert that the concrete type of the deposited vault is the same
            // as the vault that is accepting the deposit
            pre {
                from.isInstance(self.getType()): 
                    "Cannot deposit an incompatible token type"
                emit Deposited(amount: from.getBalance(), type: from.getType().identifier, to: self.owner?.address, toUUID: self.uuid, depositedUUID: from.uuid)
            }
            post {
                self.getBalance() == before(self.getBalance()) + before(from.getBalance()):
                    "New Vault balance must be the sum of the previous balance and the deposited Vault"
            }
        }

        /// createEmptyVault allows any user to create a new Vault that has a zero balance
        ///
        access(all) fun createEmptyVault(): @{Vault} {
            post {
                result.getBalance() == 0.0: "The newly created Vault must have zero balance"
            }
        }
    }

    /// createEmptyVault allows any user to create a new Vault that has a zero balance
    ///
    access(all) fun createEmptyVault(vaultType: Type): @{FungibleToken.Vault} {
        post {
            result.getType() == vaultType: "The returned vault does not match the desired type"
            result.getBalance() == 0.0: "The newly created Vault must have zero balance"
        }
    }

    /// Method to burn a FungibleToken Vault
    /// contract implementations should provide an implementation for this function
    /// that subtracts the vault balance from the token's total supply
    access(all) fun burn(_ vault: @{FungibleToken.Vault}) {
        pre {
            self.getVaultTypes().contains(vault.getType())
            vault.balance > 0.0: "Do not use the burn method unless the vault balance is greater than zero!"
            emit Burned(amount: vault.balance, type: vault.getType().identifier, fromUUID: vault.uuid)
        }
    }
}