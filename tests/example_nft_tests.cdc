import Test
import "test_helpers.cdc"

access(all) let admin = blockchain.createAccount()
access(all) let recipient = blockchain.createAccount()

access(all) fun setup() {
    blockchain.useConfiguration(
        Test.Configuration(
            addresses: {
                "ViewResolver": admin.address,
                "NonFungibleToken": admin.address,
                "MetadataViews": admin.address,
                "MultipleNFT": admin.address,
                "ExampleNFT": admin.address
            }
        )
    )

    deploy("ViewResolver", admin, "../contracts/ViewResolver.cdc")
    deploy("NonFungibleToken", admin, "../contracts/NonFungibleToken-v2.cdc")
    deploy("MetadataViews", admin, "../contracts/MetadataViews.cdc")
    deploy("MultipleNFT", admin, "../contracts/MultipleNFT.cdc")
    deploy("UniversalCollection", admin, "../contracts/UniversalCollection.cdc")
    deploy("ExampleNFT", admin, "../contracts/ExampleNFT-v2.cdc")
}

access(all) fun testContractInitializedEventEmitted() {
    let typ = CompositeType(buildTypeIdentifier(admin, "ExampleNFT", "ContractInitialized"))!

    Test.assertEqual(1, blockchain.eventsOfType(typ).length)
}

access(all) fun testSetupAccount() {
    let expectedCollectionLength = 0

    txExecutor("setup_account.cdc", [recipient], [], nil, nil)

    let actualCollectionLength = scriptExecutor("get_collection_length.cdc", [admin.address]) as! Int?
        ?? panic("Could not get collection IDs from admin")

    Test.assertEqual(expectedCollectionLength, actualCollectionLength)
}

access(all) fun testMintNFT() {

    let expectedCollectionLength = 1

    txExecutor("setup_account_to_receive_royalty.cdc", [admin], [/storage/flowTokenVault], nil, nil)

    txExecutor(
        "mint_nft.cdc",
        [admin], [
            recipient.address,
            "NFT Name",
            "NFT Description",
            "NFT Thumbnail",
            [0.05],
            ["Creator Royalty"],
            [admin.address]
        ], nil,
        nil
    )

    let typ = CompositeType(buildTypeIdentifier(admin, "NonFungibleToken", "Deposit"))!
    Test.assertEqual(1, blockchain.eventsOfType(typ).length)

    let actualCollectionIDs = scriptExecutor("get_collection_ids.cdc", [
            recipient.address,
            /public/cadenceExampleNFTCollection
        ]) as! [UInt64]? ?? panic("Could not get collection IDs from admin")

    Test.assertEqual(expectedCollectionLength, actualCollectionIDs.length)
}

access(all) fun testTransferNFT() {

    let nftIDs = scriptExecutor("get_collection_ids.cdc", [
            recipient.address,
            /public/cadenceExampleNFTCollection
        ]) as! [UInt64]? ?? panic("Could not get collection IDs from admin")
    let expectedTransferID = nftIDs[0]

    txExecutor("transfer_nft.cdc", [recipient], [admin.address, "ExampleNFT", admin.address, expectedTransferID], nil, nil)

    var typ = CompositeType(buildTypeIdentifier(admin, "NonFungibleToken", "Transfer"))!
    Test.assertEqual(1, blockchain.eventsOfType(typ).length)

    let adminIDs = scriptExecutor("get_collection_ids.cdc", [
            admin.address,
            /public/cadenceExampleNFTCollection
        ]) as! [UInt64]? ?? panic("Could not get collection IDs from admin")
    let actualTransferID = adminIDs[0]

    Test.assertEqual(expectedTransferID, actualTransferID)
}

access(all) fun testTransferMissingNFT() {
    let expectedErrorMessage = "The collection does not contain the specified ID"
    let expectedErrorType = ErrorType.TX_PRE

    txExecutor(
        "transfer_nft.cdc",
        [recipient],
        [admin.address, "ExampleNFT", admin.address, 10 as UInt64],
        expectedErrorMessage,
        expectedErrorType
    )
}

access(all) fun testBorrowNFT() {
    txExecutor(
        "mint_nft.cdc",
        [admin], [
            recipient.address,
            "NFT Name",
            "NFT Description",
            "NFT Thumbnail",
            [0.05],
            ["Creator Royalty"],
            [admin.address]
        ], nil,
        nil
    )
    let nftIDs = scriptExecutor("get_collection_ids.cdc", [
            recipient.address,
            /public/cadenceExampleNFTCollection
        ]) as! [UInt64]? ?? panic("Could not get collection IDs")
    let mintedID = nftIDs[0]

    // Panics if not successful - enough to run the script here
    let scriptResult = scriptExecutor("borrow_nft.cdc", [recipient.address, mintedID])
}

access(all) fun testBorrowMissingNFT() {
    expectScriptFailure("borrow_nft.cdc", [admin.address, 10 as UInt64])
}

access(all) fun testGetCollectionIDs() {
    let expectedCollectionLength = 1
    
    let actualNFTIDs = scriptExecutor("get_collection_ids.cdc", [
            recipient.address,
            /public/cadenceExampleNFTCollection
        ]) as! [UInt64]? ?? panic("Could not get collection IDs")

    Test.assertEqual(expectedCollectionLength, actualNFTIDs.length)
}

access(all) fun testGetCollectionLength() {
    let expectedCollectionLength = 1

    let actualCollectionLength = scriptExecutor("get_collection_length.cdc", [admin.address]) as! Int?
        ?? panic("Could not get collection length")

    Test.assertEqual(expectedCollectionLength, actualCollectionLength)
}

access(all) fun testGetContractStoragePath() {
    let expectedStoragePath = /storage/cadenceExampleNFTCollection

    let actualStoragePath = scriptExecutor("get_contract_storage_path.cdc", [admin.address, "ExampleNFT"]) as! StoragePath?
        ?? panic("Could not get storage path from NFT contract")

    Test.assertEqual(expectedStoragePath, actualStoragePath)
}

access(all) fun testGetMissingContractStoragePath() {
    expectScriptFailure("get_contract_storage_path.cdc", [admin.address, "ContractOne"])
}

access(all) fun testGetNFTMetadata() {
    let actualCollectionIDs = scriptExecutor("get_collection_ids.cdc", [
            admin.address,
            /public/cadenceExampleNFTCollection
        ]) as! [UInt64]? ?? panic("Could not get collection IDs from admin")

    let result = executeTestScript("get_nft_metadata.cdc", [admin.address, actualCollectionIDs[0]]) as! Bool?
        ?? panic("Problem executing test script")

    Test.assertEqual(true, result)
}

access(all) fun testGetMissingNFTMetadata() {
    expectScriptFailure("get_nft_metadata.cdc", [admin.address, 10 as UInt64])
}

access(all) fun testGetNFTView() {
    let actualCollectionIDs = scriptExecutor("get_collection_ids.cdc", [
            admin.address,
            /public/cadenceExampleNFTCollection
        ]) as! [UInt64]? ?? panic("Could not get collection IDs from admin")

    let result = executeTestScript("get_nft_view.cdc", [admin.address, actualCollectionIDs[0]]) as! Bool?
        ?? panic("Problem executing test script")

    Test.assertEqual(true, result)
}

access(all) fun testGetMissingNFTView() {
    expectScriptFailure("get_nft_view.cdc", [admin.address, 10 as UInt64])
}

access(all) fun testGetViews() {
    let actualCollectionIDs = scriptExecutor("get_collection_ids.cdc", [
            admin.address,
            /public/cadenceExampleNFTCollection
        ]) as! [UInt64]? ?? panic("Could not get collection IDs from admin")

    let result = executeTestScript("get_views.cdc", [admin.address, actualCollectionIDs[0]]) as! Bool?
        ?? panic("Problem executing test script")

    Test.assertEqual(true, result)
}

access(all) fun testGetExampleNFTViews() {
    let result = executeTestScript("get_example_nft_views.cdc", []) as! Bool?
        ?? panic("Problem executing test script")

    Test.assertEqual(true, result)
}

access(all) fun testResolveExampleNFTViews() {
    let result = executeTestScript("resolve_nft_views.cdc", []) as! Bool?
        ?? panic("Problem executing test script")

    Test.assertEqual(true, result)
}
