
import Test

access(all) fun deploy(_ contractName: String, _ path: String) {
    let err = Test.deployContract(
        name: contractName,
        path: path,
        arguments: [],
    )

    Test.expect(err, Test.beNil())
}

access(all) fun deployWithArgs(_ contractName: String, _ path: String, args: [AnyStruct]) {
    let err = Test.deployContract(
        name: contractName,
        path: path,
        arguments: args,
    )

    Test.expect(err, Test.beNil())
}

access(all) fun scriptExecutor(_ scriptName: String, _ arguments: [AnyStruct]): AnyStruct? {
    let scriptCode = loadCode(scriptName, "transactions/scripts")
    let scriptResult = Test.executeScript(scriptCode, arguments)

    if let failureError = scriptResult.error {
        panic(
            "Failed to execute the script because -:  ".concat(failureError.message)
        )
    }

    return scriptResult.returnValue
}

access(all) fun expectScriptFailure(_ scriptName: String, _ arguments: [AnyStruct]): String {
    let scriptCode = loadCode(scriptName, "transactions/scripts")
    let scriptResult = Test.executeScript(scriptCode, arguments)

    assert(scriptResult.error != nil, message: "script error was expected but there is no error message")
    return scriptResult.error!.message
}

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

    let txResult = Test.executeTransaction(tx)
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

access(all) fun loadCode(_ fileName: String, _ baseDirectory: String): String {
    return Test.readFile("../".concat(baseDirectory).concat("/").concat(fileName))
}

access(all) enum ErrorType: UInt8 {
    access(all) case TX_PANIC
    access(all) case TX_ASSERT
    access(all) case TX_PRE
}

access(all) fun getErrorMessagePointer(errorType: ErrorType): Int {
    switch errorType {
        case ErrorType.TX_PANIC: return 159
        case ErrorType.TX_ASSERT: return 170
        case ErrorType.TX_PRE: return 174
        default: panic("Invalid error type")
    }
}

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
