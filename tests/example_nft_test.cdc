import Test
import BlockchainHelpers
import "test_helpers.cdc"
import "ViewResolver"
import "NonFungibleToken"
import "ExampleNFT"
import "MetadataViews"

access(all) let admin = Test.getAccount(0x0000000000000007)
access(all) let recipient = Test.createAccount()

access(all)
fun setup() {
    deploy("ViewResolver", "../contracts/ViewResolver.cdc")
    deploy("NonFungibleToken", "../contracts/NonFungibleToken.cdc")
    deploy("MetadataViews", "../contracts/MetadataViews.cdc")
    deploy("ExampleNFT", "../contracts/ExampleNFT.cdc")
    deploy("MaliciousNFT", "../contracts/test/MaliciousNFT.cdc")
}

access(all)
fun testSetupAccount() {
    var txResult = executeTransaction(
        "../transactions/setup_account.cdc",
        [],
        recipient
    )
    Test.expect(txResult, Test.beSucceeded())

    var scriptResult = executeScript(
        "../transactions/scripts/get_collection_length.cdc",
        [admin.address]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    var collectionLength = scriptResult.returnValue! as! Int
    Test.assertEqual(0, collectionLength)

    let newAccount = Test.createAccount()
    txResult = executeTransaction(
        "../transactions/setup_account_from_address.cdc",
        [admin.address, "ExampleNFT"],
        newAccount
    )
    Test.expect(txResult, Test.beSucceeded())

    scriptResult = executeScript(
        "../transactions/scripts/get_collection_length.cdc",
        [newAccount.address]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    collectionLength = scriptResult.returnValue! as! Int
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

    let typ = Type<NonFungibleToken.Deposited>()
    let events = Test.eventsOfType(typ)
    Test.assertEqual(1, events.length)

    let depositEvent = events[0] as! NonFungibleToken.Deposited
    Test.assertEqual(recipient.address, depositEvent.to!)

    let scriptResult = executeScript(
        "../transactions/scripts/get_collection_ids.cdc",
        [
            recipient.address,
            /public/exampleNFTCollection
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let collectionIDs = scriptResult.returnValue! as! [UInt64]
    Test.assertEqual(1, collectionIDs.length)
}

access(all)
fun testTransferNFT() {
    var scriptResult = executeScript(
        "../transactions/scripts/get_collection_ids.cdc",
        [
            recipient.address,
            /public/exampleNFTCollection
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    var collectionIDs = scriptResult.returnValue! as! [UInt64]
    Test.assertEqual(1, collectionIDs.length)

    let nftID: UInt64 = collectionIDs[0]
    var txResult = executeTransaction(
        "../transactions/transfer_nft.cdc",
        [
            admin.address,
            "ExampleNFT",
            admin.address,
            nftID
        ],
        recipient
    )
    Test.expect(txResult, Test.beSucceeded())

    var typ = Type<NonFungibleToken.Withdrawn>()
    var events = Test.eventsOfType(typ)
    Test.assertEqual(1, events.length)

    let withdrawEvent = events[0] as! NonFungibleToken.Withdrawn
    Test.assertEqual(nftID, withdrawEvent.id)
    Test.assertEqual(recipient.address, withdrawEvent.from!)

    typ = Type<NonFungibleToken.Deposited>()
    events = Test.eventsOfType(typ)
    Test.assertEqual(2, events.length)

    let depositEvent = events[1] as! NonFungibleToken.Deposited
    Test.assertEqual(nftID, depositEvent.id)
    Test.assertEqual(admin.address, depositEvent.to!)

    scriptResult = executeScript(
        "../transactions/scripts/get_collection_ids.cdc",
        [
            admin.address,
            /public/exampleNFTCollection
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    collectionIDs = scriptResult.returnValue! as! [UInt64]
    Test.assertEqual([nftID] as [UInt64], collectionIDs)

    txResult = executeTransaction(
        "../transactions/generic_transfer_with_paths.cdc",
        [
            recipient.address,
            nftID,
            "exampleNFTCollection",
            "exampleNFTCollection"
        ],
        admin
    )
    Test.expect(txResult, Test.beSucceeded())

    txResult = executeTransaction(
        "../transactions/transfer_nft.cdc",
        [
            admin.address,
            "ExampleNFT",
            admin.address,
            nftID
        ],
        recipient
    )
    Test.expect(txResult, Test.beSucceeded())

    // Other generic transfer transactions should succeed
    txResult = executeTransaction(
        "../transactions/generic_transfer_with_address.cdc",
        [recipient.address, nftID, admin.address, "ExampleNFT"],
        admin
    )
    Test.expect(txResult, Test.beSucceeded())

    txResult = executeTransaction(
        "../transactions/generic_transfer_with_address_and_type.cdc",
        [admin.address, nftID, admin.address, "ExampleNFT", "NFT"],
        recipient
    )
    Test.expect(txResult, Test.beSucceeded())

    // Should not be able to transfer an NFT from a malicious contract
    // that tries to trick the generic transaction
    txResult = executeTransaction(
        "../transactions/generic_transfer_with_address.cdc",
        [recipient.address, nftID, admin.address, "MaliciousNFT"],
        admin
    )
    Test.expect(txResult, Test.beFailed())
    Test.assertError(
        txResult,
        errorMessage: "The NFT that was withdrawn to transfer is not the type that was requested!"
    )

    txResult = executeTransaction(
        "../transactions/generic_transfer_with_address_and_type.cdc",
        [recipient.address, nftID, admin.address, "MaliciousNFT", "NFT"],
        admin
    )
    Test.expect(txResult, Test.beFailed())
    Test.assertError(
        txResult,
        errorMessage: "The NFT that was withdrawn to transfer is not the type that was requested!"
    )
}

access(all)
fun testTransferMissingNFT() {
    let txResult = executeTransaction(
        "../transactions/transfer_nft.cdc",
        [
            admin.address,
            "ExampleNFT",
            admin.address,
            10 as UInt64
        ],
        recipient
    )
    Test.expect(txResult, Test.beFailed())
    Test.assertError(
        txResult,
        errorMessage: "ExampleNFT.Collection.withdraw: Could not withdraw an NFT with the ID=10. Check the submitted ID to make sure it is one that this collection owns",
    )
}

access(all)
fun testBorrowNFT() {
    var scriptResult = executeScript(
        "../transactions/scripts/get_collection_ids.cdc",
        [
            admin.address,
            /public/exampleNFTCollection
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let collectionIDs = scriptResult.returnValue! as! [UInt64]

    scriptResult = executeScript(
        "../transactions/scripts/borrow_nft.cdc",
        [
            admin.address,
            collectionIDs[0]
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())
}

access(all)
fun testBorrowMissingNFT() {
    let scriptResult = executeScript(
        "../transactions/scripts/borrow_nft.cdc",
        [
            admin.address,
            10 as UInt64
        ]
    )
    Test.expect(scriptResult, Test.beFailed())
    Test.assertError(
        scriptResult,
        errorMessage: "The NFT with id=10 does not exist in the collection!"
    )
}

access(all)
fun testGetCollectionLength() {
    let scriptResult = executeScript(
        "../transactions/scripts/get_collection_length.cdc",
        [admin.address]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let collectionLength = scriptResult.returnValue! as! Int
    Test.assertEqual(1, collectionLength)
}

access(all)
fun testGetIterator() {
    let scriptResult = executeScript(
        "../transactions/scripts/iterate_ids.cdc",
        [admin.address, 10]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let nftRefArrayLength = scriptResult.returnValue! as! Int
    Test.assertEqual(1, nftRefArrayLength)
}

access(all)
fun testGetContractStoragePath() {
    let scriptResult = executeScript(
        "../transactions/scripts/get_contract_storage_path.cdc",
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
        "../transactions/scripts/get_contract_storage_path.cdc",
        [
            admin.address,
            "ContractOne"
        ]
    )
    Test.expect(scriptResult, Test.beFailed())
    Test.assertError(
        scriptResult,
        errorMessage: "Could not borrow ViewResolver reference to the contract. Make sure the provided contract name (ContractOne) and address (0x0000000000000007) are correct!"
    )
}

access(all)
fun testGetNFTView() {
    var scriptResult = executeScript(
        "../transactions/scripts/get_collection_ids.cdc",
        [
            admin.address,
            /public/exampleNFTCollection
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())
    let collectionIDs = scriptResult.returnValue! as! [UInt64]

    scriptResult = executeScript(
        "scripts/get_nft_view.cdc",
        [
            admin.address,
            collectionIDs[0]
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
    var scriptResult = executeScript(
        "../transactions/scripts/get_collection_ids.cdc",
        [
            admin.address,
            /public/exampleNFTCollection
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())
    let collectionIDs = scriptResult.returnValue! as! [UInt64]

    scriptResult = executeScript(
        "../transactions/scripts/get_views.cdc",
        [
            admin.address,
            collectionIDs[0]
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
        Type<MetadataViews.Traits>(),
        Type<MetadataViews.EVMBridgedMetadata>()
    ]
    Test.assertEqual(expectedViews, supportedViews)
}

access(all)
fun testGetExampleNFTViews() {
    let scriptResult = executeScript(
        "../transactions/scripts/get_contract_views.cdc",
        []
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let supportedViews = scriptResult.returnValue! as! [Type]
    let expectedViews = [
        Type<MetadataViews.NFTCollectionData>(),
        Type<MetadataViews.NFTCollectionDisplay>(),
        Type<MetadataViews.EVMBridgedMetadata>()
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

access(all)
fun testBurnNFT() {
    var scriptResult = executeScript(
        "../transactions/scripts/get_collection_ids.cdc",
        [
            admin.address,
            /public/exampleNFTCollection
        ]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let collectionIDs = scriptResult.returnValue! as! [UInt64]

    let txResult = executeTransaction(
        "../transactions/destroy_nft.cdc",
        [
            collectionIDs[0]
        ],
        admin
    )
    Test.expect(txResult, Test.beSucceeded())
}
