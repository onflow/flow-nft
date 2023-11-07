// Helper functions. All of the following were taken from
// https://github.com/onflow/Offers/blob/fd380659f0836e5ce401aa99a2975166b2da5cb0/lib/cadence/test/Offers.cdc
// - deploy
// - scriptExecutor
// - txExecutor
// - getErrorMessagePointer

import Test

access(all) let blockchain = Test.newEmulatorBlockchain()

/// Deploys a contract to the given account, sourcing the contract code from the specified path
access(all) fun deploy(_ contractName: String, _ account: Test.TestAccount, _ path: String) {
    let err = blockchain.deployContract(
        name: contractName,
        code: Test.readFile(path),
        account: account,
        arguments: [],
    )

    Test.expect(err, Test.beNil())
    if err != nil {
        panic(err!.message)
    }
}

/// Deploys a contract to the given account, sourcing the contract code from the specified path, passing the given
/// arguments to the contract's initializer
access(all) fun deployWithArgs(_ contractName: String, _ account: Test.TestAccount, _ path: String, args: [AnyStruct]) {
    let err = blockchain.deployContract(
        name: contractName,
        code: Test.readFile(path),
        account: account,
        arguments: args,
    )

    Test.expect(err, Test.beNil())
    if err != nil {
        panic(err!.message)
    }
}

/// Executes a script with the given arguments, sourcing the script code from the root/scripts directory.
/// Assumes no error on execution
access(all) fun scriptExecutor(_ scriptName: String, _ arguments: [AnyStruct]): AnyStruct? {
    let scriptCode = loadCode(scriptName, "scripts")
    let scriptResult = blockchain.executeScript(scriptCode, arguments)

    if let failureError = scriptResult.error {
        panic("Failed to execute the script because -:  ".concat(failureError.message))
    }

    return scriptResult.returnValue
}

/// Executes a script with the given arguments, sourcing the script code from the root/test/scripts directory.
/// Assumes no error on execution
access(all) fun executeTestScript(_ scriptName: String, _ arguments: [AnyStruct]): AnyStruct? {
    let scriptCode = Test.readFile("./scripts/".concat(scriptName))
    let scriptResult = blockchain.executeScript(scriptCode, arguments)

    if let failureError = scriptResult.error {
        panic(
            "Failed to execute the script because -:  ".concat(failureError.message)
        )
    }

    return scriptResult.returnValue
}

/// Executes a script with the given arguments, sourcing the script code from the root/scripts directory.
/// Assumes failed execution
access(all) fun expectScriptFailure(_ scriptName: String, _ arguments: [AnyStruct]): String {
    let scriptCode = loadCode(scriptName, "scripts")
    let scriptResult = blockchain.executeScript(scriptCode, arguments)

    assert(scriptResult.error != nil, message: "script error was expected but there is no error message")
    return scriptResult.error!.message
}

/// Executes a transaction with the given arguments, sourcing the transaction code from the root/transactions directory
/// Expected errors should be passed as a string while error type defined as enums in this file
access(all) fun txExecutor(_ txName: String, _ signers: [Test.TestAccount], _ arguments: [AnyStruct], _ expectedError: String?, _ expectedErrorType: ErrorType?): Bool {
    let txCode = loadCode(txName, "transactions")

    let authorizers: [Address] = []
    for signer in signers {
        authorizers.append(signer.address)
    }

    let tx = Test.Transaction(
        code: txCode,
        authorizers: authorizers,
        signers: signers,
        arguments: arguments,
    )

    let txResult = blockchain.executeTransaction(tx)
    if let err = txResult.error {
        if let expectedErrorMessage = expectedError {
            let ptr = getErrorMessagePointer(errorType: expectedErrorType!)
            let errMessage = err.message
            let hasEmittedCorrectMessage = contains(errMessage, expectedErrorMessage)
            let failureMessage = "Expecting - "
                .concat(expectedErrorMessage)
                .concat("\n")
                .concat("But received - ")
                .concat(err.message)
            assert(hasEmittedCorrectMessage, message: failureMessage)
            return true
        }
        panic(err.message)
    } else {
        if let expectedErrorMessage = expectedError {
            panic("Expecting error - ".concat(expectedErrorMessage).concat(". While no error triggered"))
        }
    }

    return txResult.status == Test.ResultStatus.succeeded
}

/// Loads code from the given path
access(all) fun loadCode(_ fileName: String, _ baseDirectory: String): String {
    return Test.readFile("../".concat(baseDirectory).concat("/").concat(fileName))
}

/// Defines three different error types
access(all) enum ErrorType: UInt8 {
    /// Panic within transaction
    access(all) case TX_PANIC
    /// Failed assertion
    access(all) case TX_ASSERT
    /// Failed pre-condition
    access(all) case TX_PRE
}

/// Returns the error message pointer for the given error type
access(all) fun getErrorMessagePointer(errorType: ErrorType): Int {
    switch errorType {
        case ErrorType.TX_PANIC: return 159
        case ErrorType.TX_ASSERT: return 170
        case ErrorType.TX_PRE: return 174
        default: panic("Invalid error type")
    }
}

/// Builds a type identifier for the given account and contract name and type suffix
access(all) fun buildTypeIdentifier(_ acct: Test.TestAccount, _ contractName: String, _ suffix: String): String {
    let addrString = acct.address.toString()
    return "A.".concat(addrString.slice(from: 2, upTo: addrString.length)).concat(".").concat(contractName).concat(".").concat(suffix)
}

// Copied functions from flow-utils so we can assert on error conditions
// https://github.com/green-goo-dao/flow-utils/blob/main/cadence/contracts/StringUtils.cdc
access(all) fun contains(_ s: String, _ substr: String): Bool {
    if let index = index(s, substr, 0) {
        return true
    }
    return false
}

// https://github.com/green-goo-dao/flow-utils/blob/main/cadence/contracts/StringUtils.cdc
access(all) fun index(_ s: String, _ substr: String, _ startIndex: Int): Int? {
    for i in range(startIndex, s.length - substr.length + 1) {
        if s[i] == substr[0] && s.slice(from: i, upTo: i + substr.length) == substr {
            return i
        }
    }
    return nil
}

// https://github.com/green-goo-dao/flow-utils/blob/main/cadence/contracts/ArrayUtils.cdc
access(all) fun rangeFunc(_ start: Int, _ end: Int, _ f: (fun (Int): Void)) {
    var current = start
    while current < end {
        f(current)
        current = current + 1
    }
}

access(all) fun range(_ start: Int, _ end: Int): [Int] {
    let res: [Int] = []
    rangeFunc(start, end, fun (i: Int) {
        res.append(i)
    })
    return res
}
