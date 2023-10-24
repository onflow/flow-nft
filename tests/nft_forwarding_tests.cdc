import Test
import "test_helpers.cdc"

access(all) let admin = blockchain.createAccount()
access(all) let forwarder = blockchain.createAccount()
access(all) let recipient = blockchain.createAccount()

access(all) let collectionPublicPath = /public/cadenceExampleNFTCollection

access(all) fun setup() {

    blockchain.useConfiguration(
        Test.Configuration(
            addresses: {
                "ViewResolver": admin.address,
                "NonFungibleToken": admin.address,
                "MetadataViews": admin.address,
                "MultipleNFT": admin.address,
                "ExampleNFT": admin.address,
                "NFTForwarding": admin.address
            }
        )
    )

    deploy("ViewResolver", admin, "../contracts/ViewResolver.cdc")
    deploy("NonFungibleToken", admin, "../contracts/NonFungibleToken-v2.cdc")
    deploy("MetadataViews", admin, "../contracts/MetadataViews.cdc")
    deploy("MultipleNFT", admin, "../contracts/MultipleNFT.cdc")
    deploy("ExampleNFT", admin, "../contracts/ExampleNFT-v2.cdc")
    deploy("NFTForwarding", admin, "../contracts/utility/NFTForwarding.cdc")
}

access(all) fun testCreateForwarderFails() {

    let expectedErrorMessage = "Recipient is not configured with NFT Collection at the given path"
    let expectedErrorType = ErrorType.TX_PANIC

    // Create forwarder in forwarding account should fail since recipient doesn't have Collection configured
    let forwarderSetupSuccess: Bool = txExecutor(
            "nft-forwarding/create_forwarder.cdc",
            [forwarder],
            [recipient.address, collectionPublicPath],
            expectedErrorMessage,
            expectedErrorType
        )
}

access(all) fun testCreateForwarder() {
    // Setup Collection in recipient
    let recipientSetupSuccess: Bool = txExecutor("setup_account.cdc", [recipient], [], nil, nil)

    // Create forwarder in forwarding account
    let forwarderSetupSuccess: Bool = txExecutor(
            "nft-forwarding/create_forwarder.cdc",
            [forwarder],
            [recipient.address, collectionPublicPath],
            nil,
            nil
        )

    Test.assertEqual(true, recipientSetupSuccess)
    Test.assertEqual(true, forwarderSetupSuccess)
}

access(all) fun testMintNFT() {

    let expectedCollectionLength: Int = 1

    let royaltySetupSuccess: Bool = txExecutor(
            "setup_account_to_receive_royalty.cdc",
            [admin],
            [/storage/flowTokenVault],
            nil,
            nil
        )
    Test.assertEqual(true, royaltySetupSuccess)

    // Minting to forwarder should forward minted NFT to recipient
    let mintSuccess: Bool = txExecutor(
            "mint_nft.cdc",
            [admin],
            [
                forwarder.address,
                "NFT Name",
                "NFT Description",
                "NFT Thumbnail",
                [0.05],
                ["Creator Royalty"],
                [admin.address]
            ],
            nil,
            nil
        )
    Test.assertEqual(true, mintSuccess)

    // TODO: Uncomment once TestAccount bug fixed
    // let forwardEventType = CompositeType(buildTypeIdentifier(admin, "NFTForwarding", "ForwardedNFTDeposit"))!
    // Test.assertEqual(1, blockchain.eventsOfType(forwardEventType).length)

    let actualCollectionLength = scriptExecutor(
            "get_collection_length.cdc",
            [recipient.address],
        ) as! Int? ?? panic("problem retrieving NFT IDs from recipient at expected path")

    Test.assertEqual(expectedCollectionLength, actualCollectionLength)
}
