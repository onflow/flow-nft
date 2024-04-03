
transaction(code: [UInt8]) {

    prepare(acct: auth(UpdateContract) &Account) {

        acct.contracts.update__experimental(name: "NonFungibleToken", code: code)
    }
}