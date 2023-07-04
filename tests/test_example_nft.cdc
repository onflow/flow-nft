import Test

pub let blockchain = Test.newEmulatorBlockchain()
pub let admin = blockchain.createAccount()
pub let recipient = blockchain.createAccount()

pub fun setup() {
    blockchain.useConfiguration(Test.Configuration({
        "ExampleNFT": admin.address
    }))

    let code = Test.readFile("../contracts/ExampleNFT.cdc")
    let err = blockchain.deployContract(
        name: "ExampleNFT",
        code: code,
        account: admin,
        arguments: []
    )

    Test.expect(err, Test.beNil())
}

pub fun testContractInitializedEventEmitted() {
    let typ = CompositeType("A.01cf0e2f2f715450.ExampleNFT.ContractInitialized")!

    Test.assertEqual(1, blockchain.eventsOfType(typ).length)
}

pub fun testGetTotalSupply() {
    let code = Test.readFile("../scripts/get_total_supply.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        []
    )

    Test.expect(scriptResult, Test.beSucceeded())

    let totalSupply = (scriptResult.returnValue as! UInt64?)!
    Test.assertEqual(0 as UInt64, totalSupply)
}

pub fun testSetupAccount() {
    var code = Test.readFile("../transactions/setup_account.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [recipient.address],
        signers: [recipient],
        arguments: []
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())

    code = Test.readFile("../scripts/get_collection_length.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [admin.address]
    )

    Test.expect(scriptResult, Test.beSucceeded())

    let collectionLength = (scriptResult.returnValue as! Int?)!
    Test.assertEqual(0, collectionLength)
}

pub fun testMintNFT() {
    var code = Test.readFile("../transactions/setup_account_to_receive_royalty.cdc")
    var tx = Test.Transaction(
        code: code,
        authorizers: [admin.address],
        signers: [admin],
        arguments: [/storage/flowTokenVault]
    )
    var txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())

    code = Test.readFile("../transactions/mint_nft.cdc")
    tx = Test.Transaction(
        code: code,
        authorizers: [admin.address],
        signers: [admin],
        arguments: [
            recipient.address,
            "NFT Name",
            "NFT Description",
            "NFT Thumbnail",
            [0.05],
            ["Creator Royalty"],
            [admin.address]
        ]
    )
    txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())

    let typ = CompositeType("A.01cf0e2f2f715450.ExampleNFT.Deposit")!
    Test.assertEqual(1, blockchain.eventsOfType(typ).length)

    code = Test.readFile("../scripts/get_collection_ids.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [
            recipient.address,
            /public/exampleNFTCollection
        ]
    )

    Test.expect(scriptResult, Test.beSucceeded())

    let collectionIDs = (scriptResult.returnValue as! [UInt64]?)!
    Test.assertEqual([0] as [UInt64], collectionIDs)
}

pub fun testTransferNFT() {
    var code = Test.readFile("../transactions/transfer_nft.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [recipient.address],
        signers: [recipient],
        arguments: [
            admin.address,
            0 as UInt64
        ]
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())

    var typ = CompositeType("A.01cf0e2f2f715450.ExampleNFT.Withdraw")!
    Test.assertEqual(1, blockchain.eventsOfType(typ).length)

    typ = CompositeType("A.01cf0e2f2f715450.ExampleNFT.Deposit")!
    Test.assertEqual(2, blockchain.eventsOfType(typ).length)

    code = Test.readFile("../scripts/get_collection_ids.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [
            admin.address,
            /public/exampleNFTCollection
        ]
    )

    Test.expect(scriptResult, Test.beSucceeded())

    let collectionIDs = (scriptResult.returnValue as! [UInt64]?)!
    Test.assertEqual([0] as [UInt64], collectionIDs)
}

pub fun testTransferMissingNFT() {
    var code = Test.readFile("../transactions/transfer_nft.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [recipient.address],
        signers: [recipient],
        arguments: [
            admin.address,
            10 as UInt64
        ]
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beFailed())
    Test.assertEqual(
        "missing NFT",
        txResult.error!.message.slice(from: 390, upTo: 401)
    )
}

pub fun testBorrowNFT() {
    let code = Test.readFile("../scripts/borrow_nft.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [
            admin.address,
            0 as UInt64
        ]
    )

    Test.expect(scriptResult, Test.beSucceeded())
}

pub fun testBorrowMissingNFT() {
    let code = Test.readFile("../scripts/borrow_nft.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [
            admin.address,
            10 as UInt64
        ]
    )

    Test.expect(scriptResult, Test.beFailed())
}

pub fun testGetCollectionIDs() {
    let code = Test.readFile("../scripts/get_collection_ids.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [
            admin.address,
            /public/exampleNFTCollection
        ]
    )

    Test.expect(scriptResult, Test.beSucceeded())

    let collectionIDs = (scriptResult.returnValue as! [UInt64]?)!
    Test.assertEqual([0] as [UInt64], collectionIDs)
}

pub fun testGetCollectionLength() {
    let code = Test.readFile("../scripts/get_collection_length.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [admin.address]
    )

    Test.expect(scriptResult, Test.beSucceeded())

    let collectionLength = (scriptResult.returnValue as! Int?)!
    Test.assertEqual(1, collectionLength)
}

pub fun testGetContractStoragePath() {
    let code = Test.readFile("../scripts/get_contract_storage_path.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [
            admin.address,
            "ExampleNFT"
        ]
    )

    Test.expect(scriptResult, Test.beSucceeded())

    let storagePath = (scriptResult.returnValue as! StoragePath?)!
    Test.assertEqual(/storage/exampleNFTCollection, storagePath)
}

pub fun testGetMissingContractStoragePath() {
    let code = Test.readFile("../scripts/get_contract_storage_path.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [
            admin.address,
            "ContractOne"
        ]
    )

    Test.expect(scriptResult, Test.beFailed())
}

pub fun testGetNFTMetadata() {
    let code = Test.readFile("scripts/get_nft_metadata.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [
            admin.address,
            0 as UInt64
        ]
    )

    Test.expect(scriptResult, Test.beSucceeded())
}

pub fun testGetMissingNFTMetadata() {
    let code = Test.readFile("scripts/get_nft_metadata.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [
            admin.address,
            10 as UInt64
        ]
    )

    Test.expect(scriptResult, Test.beFailed())
}

pub fun testGetNFTView() {
    let code = Test.readFile("scripts/get_nft_view.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [
            admin.address,
            0 as UInt64
        ]
    )

    Test.expect(scriptResult, Test.beSucceeded())
}

pub fun testGetMissingNFTView() {
    let code = Test.readFile("scripts/get_nft_view.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [
            admin.address,
            10 as UInt64
        ]
    )

    Test.expect(scriptResult, Test.beFailed())
}

pub fun testGetViews() {
    let code = Test.readFile("scripts/get_views.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [
            admin.address,
            0 as UInt64
        ]
    )

    Test.expect(scriptResult, Test.beSucceeded())
}

pub fun testGetExampleNFTViews() {
    let code = Test.readFile("scripts/get_example_nft_views.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        []
    )

    Test.expect(scriptResult, Test.beSucceeded())
}

pub fun testResolveExampleNFTViews() {
    let code = Test.readFile("scripts/resolve_nft_views.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        []
    )

    Test.expect(scriptResult, Test.beSucceeded())
}
