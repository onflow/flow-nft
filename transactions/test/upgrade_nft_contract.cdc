
transaction(code: [UInt8]) {

    prepare(acct: AuthAccount) {

        acct.contracts.update__experimental(name: "NonFungibleToken", code: code)
    }
}