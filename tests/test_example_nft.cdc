import Test
import BlockchainHelpers
import "ExampleNFT"
import "MetadataViews"

access(all) let admin = Test.getAccount(0x0000000000000007)
access(all) let recipient = Test.createAccount()

access(all)
fun setup() {
    let err = Test.deployContract(
        name: "ExampleNFT",
        path: "../contracts/ExampleNFT.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())
}

access(all)
fun testContractInitializedEventEmitted() {
    let typ = Type<ExampleNFT.ContractInitialized>()
    Test.assertEqual(1, Test.eventsOfType(typ).length)
}

access(all)
fun testGetTotalSupply() {
    let scriptResult = executeScript(
        "../scripts/get_total_supply.cdc",
        []
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let totalSupply = scriptResult.returnValue! as! UInt64
    Test.assertEqual(0 as UInt64, totalSupply)
}

access(all)
fun testSetupAccount() {
    let txResult = executeTransaction(
        "../transactions/setup_account.cdc",
        [],
        recipient
    )
    Test.expect(txResult, Test.beSucceeded())

    let scriptResult = executeScript(
        "../scripts/get_collection_length.cdc",
        [admin.address]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let collectionLength = scriptResult.returnValue! as! Int
    Test.assertEqual(0, collectionLength)
}

access(all)
fun testMintNFT() {
    var txResult = executeTransaction(
        "../transactions/setup_account_to_receive_royalty.cdc",
        [/storage/flowTokenVault],
        admin
    )
    Test.expect(txResult, Test.beSucceeded())

    txResult = executeTransaction(
        "../transactions/mint_nft.cdc",
        [
            recipient.address,
            "NFT Name",
            "NFT Description",
            "NFT Thumbnail",
            [0.05],
            ["Creator Royalty"],
            [admin.address]
        ],
        admin
    )
    Test.expect(txResult, Test.beSucceeded())

    let typ = Type<ExampleNFT.Deposit>()
    let events = Test.eventsOfType(typ)
    Test.assertEqual(1, events.length)

    let depositEvent = events[0] as! ExampleNFT.Deposit
    Test.assertEqual(0 as UInt64, depositEvent.id)
    Test.assertEqual(recipient.address, depositEvent.to!)

    let scriptResult = executeScript(
        "../scripts/get_collection_ids.cdc",
        [
            recipient.address,
            /public/exampleNFTCollection
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let collectionIDs = scriptResult.returnValue! as! [UInt64]
    Test.assertEqual([0] as [UInt64], collectionIDs)
}

access(all)
fun testTransferNFT() {
    let nftID: UInt64 = 0
    let txResult = executeTransaction(
        "../transactions/transfer_nft.cdc",
        [
            admin.address,
            nftID
        ],
        recipient
    )
    Test.expect(txResult, Test.beSucceeded())

    var typ = Type<ExampleNFT.Withdraw>()
    var events = Test.eventsOfType(typ)
    Test.assertEqual(1, events.length)

    let withdrawEvent = events[0] as! ExampleNFT.Withdraw
    Test.assertEqual(nftID, withdrawEvent.id)
    Test.assertEqual(recipient.address, withdrawEvent.from!)

    typ = Type<ExampleNFT.Deposit>()
    events = Test.eventsOfType(typ)
    Test.assertEqual(2, events.length)

    let depositEvent = events[1] as! ExampleNFT.Deposit
    Test.assertEqual(nftID, depositEvent.id)
    Test.assertEqual(admin.address, depositEvent.to!)

    let scriptResult = executeScript(
        "../scripts/get_collection_ids.cdc",
        [
            admin.address,
            /public/exampleNFTCollection
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let collectionIDs = scriptResult.returnValue! as! [UInt64]
    Test.assertEqual([0] as [UInt64], collectionIDs)
}

access(all)
fun testTransferMissingNFT() {
    let txResult = executeTransaction(
        "../transactions/transfer_nft.cdc",
        [
            admin.address,
            10 as UInt64
        ],
        recipient
    )
    Test.expect(txResult, Test.beFailed())
    Test.assertError(
        txResult,
        errorMessage: "missing NFT",
    )
}

access(all)
fun testBorrowNFT() {
    let scriptResult = executeScript(
        "../scripts/borrow_nft.cdc",
        [
            admin.address,
            0 as UInt64
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())
}

access(all)
fun testBorrowMissingNFT() {
    let scriptResult = executeScript(
        "../scripts/borrow_nft.cdc",
        [
            admin.address,
            10 as UInt64
        ]
    )
    Test.expect(scriptResult, Test.beFailed())
    Test.assertError(
        scriptResult,
        errorMessage: "NFT does not exist in the collection!"
    )
}

access(all)
fun testGetCollectionIDs() {
    let scriptResult = executeScript(
        "../scripts/get_collection_ids.cdc",
        [
            admin.address,
            /public/exampleNFTCollection
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let collectionIDs = scriptResult.returnValue! as! [UInt64]
    Test.assertEqual([0] as [UInt64], collectionIDs)
}

access(all)
fun testGetCollectionLength() {
    let scriptResult = executeScript(
        "../scripts/get_collection_length.cdc",
        [admin.address]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let collectionLength = scriptResult.returnValue! as! Int
    Test.assertEqual(1, collectionLength)
}

access(all)
fun testGetContractStoragePath() {
    let scriptResult = executeScript(
        "../scripts/get_contract_storage_path.cdc",
        [
            admin.address,
            "ExampleNFT"
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let storagePath = scriptResult.returnValue! as! StoragePath
    Test.assertEqual(/storage/exampleNFTCollection, storagePath)
}

access(all)
fun testGetMissingContractStoragePath() {
    let scriptResult = executeScript(
        "../scripts/get_contract_storage_path.cdc",
        [
            admin.address,
            "ContractOne"
        ]
    )
    Test.expect(scriptResult, Test.beFailed())
    Test.assertError(
        scriptResult,
        errorMessage: "contract could not be borrowed"
    )
}

access(all)
fun testGetNFTMetadata() {
    let scriptResult = executeScript(
        "scripts/get_nft_metadata.cdc",
        [
            admin.address,
            0 as UInt64
        ]
    )

    Test.expect(scriptResult, Test.beSucceeded())
}

access(all)
fun testGetMissingNFTMetadata() {
    let scriptResult = executeScript(
        "scripts/get_nft_metadata.cdc",
        [
            admin.address,
            10 as UInt64
        ]
    )
    Test.expect(scriptResult, Test.beFailed())
    Test.assertError(
        scriptResult,
        errorMessage: "unexpectedly found nil while forcing an Optional value"
    )
}

access(all)
fun testGetNFTView() {
    let scriptResult = executeScript(
        "scripts/get_nft_view.cdc",
        [
            admin.address,
            0 as UInt64
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())
}

access(all)
fun testGetMissingNFTView() {
    let scriptResult = executeScript(
        "scripts/get_nft_view.cdc",
        [
            admin.address,
            10 as UInt64
        ]
    )

    Test.expect(scriptResult, Test.beFailed())
    Test.assertError(
        scriptResult,
        errorMessage: "unexpectedly found nil while forcing an Optional value"
    )
}

access(all)
fun testGetViews() {
    let scriptResult = executeScript(
        "scripts/get_views.cdc",
        [
            admin.address,
            0 as UInt64
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let supportedViews = scriptResult.returnValue! as! [Type]
    let expectedViews = [
        Type<MetadataViews.Display>(),
        Type<MetadataViews.Royalties>(),
        Type<MetadataViews.Editions>(),
        Type<MetadataViews.ExternalURL>(),
        Type<MetadataViews.NFTCollectionData>(),
        Type<MetadataViews.NFTCollectionDisplay>(),
        Type<MetadataViews.Serial>(),
        Type<MetadataViews.Traits>()
    ]
    Test.assertEqual(expectedViews, supportedViews)
}

access(all)
fun testGetExampleNFTViews() {
    let scriptResult = executeScript(
        "scripts/get_example_nft_views.cdc",
        []
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let supportedViews = scriptResult.returnValue! as! [Type]
    let expectedViews = [
        Type<MetadataViews.NFTCollectionData>(),
        Type<MetadataViews.NFTCollectionDisplay>()
    ]
    Test.assertEqual(expectedViews, supportedViews)
}

access(all)
fun testResolveExampleNFTViews() {
    let scriptResult = executeScript(
        "scripts/resolve_nft_views.cdc",
        []
    )
    Test.expect(scriptResult, Test.beSucceeded())
}
