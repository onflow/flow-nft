import Test
import BlockchainHelpers
import "test_helpers.cdc"
import "ViewResolver"
import "NonFungibleToken"

access(all) let admin = Test.getAccount(0x0000000000000007)
access(all) let forwarder = Test.createAccount()
access(all) let recipient = Test.createAccount()

access(all) let collectionStoragePath = /storage/exampleNFTCollection
access(all) let collectionPublicPath = /public/exampleNFTCollection

access(all) fun setup() {

    deploy("ViewResolver", "../contracts/ViewResolver.cdc")
    deploy("NonFungibleToken", "../contracts/NonFungibleToken.cdc")
    deploy("MetadataViews", "../contracts/MetadataViews.cdc")
    deploy("ExampleNFT", "../contracts/ExampleNFT.cdc")
    deploy("NFTForwarding", "../contracts/utility/NFTForwarding.cdc")
    
}

access(all) fun testCreateForwarderFails() {

    let expectedErrorMessage = "The Recipient has not configured their account with an NFT Collection at the given public path=/public/exampleNFTCollection"
    let expectedErrorType = ErrorType.TX_PANIC
    
    // Setup Collection in forwarder
    let forwarderCollectionSetupSuccess: Bool = txExecutor("setup_account.cdc", [forwarder], [], nil, nil)
    Test.assertEqual(true, forwarderCollectionSetupSuccess)

    // Create forwarder in forwarding account should **fail** since recipient doesn't have Collection configured
    txExecutor(
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
        ) as! Int? ?? panic("problem retrieving collection length from recipient at expected path")

    Test.assertEqual(expectedCollectionLength, actualCollectionLength)
}

access(all) fun testChangeForwarderRecipient() {

    let newRecipient = Test.createAccount()

    let newRecipientSetupSuccess: Bool = txExecutor("setup_account.cdc", [newRecipient], [], nil, nil)
    Test.assertEqual(true, newRecipientSetupSuccess)

    let changeForwardingRecipientSuccess: Bool = txExecutor(
            "nft-forwarding/change_forwarder_recipient.cdc",
            [forwarder],
            [newRecipient.address, collectionPublicPath],
            nil,
            nil
        )
    Test.assertEqual(true, changeForwardingRecipientSuccess)

    let collectionIDs = scriptExecutor(
            "get_collection_ids.cdc",
            [recipient.address, collectionPublicPath],
        ) as! [UInt64]? ?? panic("problem retrieving NFT IDs from recipient at expected path")
    let transferID = collectionIDs[0]

    let transferSuccess: Bool = txExecutor(
        "transfer_nft.cdc",
        [recipient],
        [admin.address, "ExampleNFT", forwarder.address, transferID],
        nil,
        nil
    )
    Test.assertEqual(true, transferSuccess)

    let oldRecipientCollectionLength = scriptExecutor(
            "get_collection_length.cdc",
            [recipient.address],
        ) as! Int? ?? panic("problem retrieving collection length from recipient at expected path")

    let newRecipientIDs = scriptExecutor(
            "get_collection_ids.cdc",
            [newRecipient.address, collectionPublicPath],
        ) as! [UInt64]? ?? panic("problem retrieving NFT IDs from new recipient at expected path")
    let actualTransferID = newRecipientIDs[0]

    Test.assertEqual(0, oldRecipientCollectionLength)
    Test.assertEqual(transferID, actualTransferID)
}

access(all) fun testUnlinkForwarderLinkCollection() {

    // Forwarder should not have NFTs in collection to start
    let beginForwarderCollectionLength = scriptExecutor(
            "get_collection_length_from_storage.cdc",
            [forwarder.address],
        ) as! Int? ?? panic("problem retrieving collection length from forwarder at expected path")
    Test.assertEqual(0, beginForwarderCollectionLength)

    // Unlink forwarder and relink ExampleNFT Collection
    let unlinkSuccess: Bool = txExecutor(
            "nft-forwarding/unlink_forwarder_link_collection.cdc",
            [forwarder],
            [collectionStoragePath, collectionPublicPath],
            nil,
            nil)
    Test.assertEqual(true, unlinkSuccess)

    // Minting to forwarder should now minted NFT to recipient
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

    // Confirm minted NFT went to forwarder's collection
    let endForwarderCollectionLength = scriptExecutor(
            "get_collection_length.cdc",
            [forwarder.address],
        ) as! Int? ?? panic("problem retrieving NFT IDs from new forwarder at expected path")
    Test.assertEqual(1, endForwarderCollectionLength)

}