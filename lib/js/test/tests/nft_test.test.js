import path from "path";
import { expect } from "@jest/globals";
import {
    emulator,
    getAccountAddress,
    init,
    sendTransaction,
    shallPass,
    shallRevert,
    shallThrow
} from "@onflow/flow-js-testing";
import { deployContracts } from "../templates/deploy_templates";
import {
    assertCollectionLength,
    assertNFTInCollection,
    assertTotalSupply
} from "../templates/assertion_templates";
import { mintNFT, setupAccountNFTCollection } from "../templates/transaction_templates";
import { executeBorrowNFTScript } from "../templates/script_templates";

// Set basepath of the project
const BASE_PATH = path.resolve(__dirname, "./../../../../");

describe("NonFungibleToken Contract Tests", () => {

    // Setup each test
    beforeEach(async () => {
        const logging = false;

        await init(BASE_PATH);
        return emulator.start({ logging });
    });

    // Stop the emulator after each test
    afterEach(async () => {
        return emulator.stop();
    })

    // Deploy Example NFT contract and verify deployment with
    // no tokens in circulation
    test("Should have properly initialized fields after deployment", async () => {
        // Set expected values
        const expectedTotalSupply = 0;
        const expectedCollectionLength = 0;

        // Deploy all contracts
        const { _1, exampleNFTAccount, _2, contractParams } = await getTestAddressesAndContractParams();
        await deployContracts(contractParams);

        // Verify NFT contract deploys without tokens in circulation
        await assertTotalSupply(expectedTotalSupply);

        // Ensure initialized collection is empty
        await assertCollectionLength(exampleNFTAccount, expectedCollectionLength);
    });

    // Deploy Example NFT contract and mint a token
    test("Should be able to mint a token", async () => {
        const beginExpectedCollectionLength = 0;
        const expectedFirstNFTID = 0;
        const expectedSecondNFTID = 1;
        const expectedCollectionPath = "/public/exampleNFTCollection";

        // Deploy all contracts
        const { nftAccount, exampleNFTAccount, _, contractParams } = await getTestAddressesAndContractParams();
        await deployContracts(contractParams);

        // Setup account with NFT Collection
        await setupAccountNFTCollection([ nftAccount ]);

        // New collection should be empty
        await assertCollectionLength(nftAccount, beginExpectedCollectionLength);

        // Mint a token with nftAccount as recipient
        await mintNFT(exampleNFTAccount, nftAccount);

        // Ensure total supply reflects single NFT mint
        await assertTotalSupply(1);

        // Ensure NFT of ID 0 is in nftAccount's collection
        await assertNFTInCollection(nftAccount, expectedFirstNFTID, expectedCollectionPath);

        // Make sure NFT is in the account we minted to
        await assertCollectionLength(nftAccount, 1);

        // Mint again to ensure values increment
        // Mint a token with nftAccount as recipient
        await mintNFT(exampleNFTAccount, nftAccount);

        // Ensure total supply reflects single NFT mint
        await assertTotalSupply(2);

        // Ensure NFT of ID 0 is in nftAccount's collection
        await assertNFTInCollection(nftAccount, expectedSecondNFTID, expectedCollectionPath);

        // Make sure NFT is in the account we minted to
        await assertCollectionLength(nftAccount, 2);

    });

    // Attempt to borrow a reference to a nonexistent NFT
    test("Shouldn't be able to borrow a reference to an NFT that doesn't exist", async () => {
        // Deploy all contracts
        const { nftAccount, _, contractParams } = await getTestAddressesAndContractParams();
        await deployContracts(contractParams);

        // Setup account with NFT Collection
        await setupAccountNFTCollection([ nftAccount ]);

        // Attempt to borrow a reference to an NFT - should throw
        await shallThrow(
            executeBorrowNFTScript(nftAccount, 0)
        );
    });

    // Create a new empty Collection
    test("Shouldn't be able to withdraw an NFT that doesn't exist in a collection", async () => {
        const expectedCollectionLength = 0;
        const testNFTID = 0;
        // Deploy all contracts
        const { _, exampleNFTAccount, joshAccount, contractParams } = await getTestAddressesAndContractParams();
        await deployContracts(contractParams);

        // Setup account with NFT Collection
        await setupAccountNFTCollection([ joshAccount ]);

        // Attempt to transfer an NFT that doesn't exist - should fail
        const [txn, err] = await shallRevert(
            sendTransaction(
                "transfer_nft",
                [exampleNFTAccount],
                [joshAccount, testNFTID.toString()]
            )
        );

        // Check that transaction reverted due to missing NFT
        expect(txn).toBeNull();
        expect(err.toString()).toEqual(
            expect.stringMatching(/missing NFT/)
        );

        // Ensure joshAccount didn't receive an NFT
        await assertCollectionLength(joshAccount, expectedCollectionLength);
    });

    // Transfer successfully
    test("Should be able to withdraw an NFT and deposit to another accounts collection", async () => {
        const expectedEmptyCollectionLength = 0;
        const senderExpectedCollectionLength = expectedEmptyCollectionLength;
        const recipientExpectedCollectionLength = 1;
        const expectedNFTID = 0;
        const expectedCollectionPath = "/public/exampleNFTCollection";

        // Deploy all contracts
        const { nftAccount, exampleNFTAccount, joshAccount, contractParams } = await getTestAddressesAndContractParams();
        await deployContracts(contractParams);

        // Setup account with NFT Collection
        await setupAccountNFTCollection([ nftAccount, joshAccount ]);

        // Both collections should be empty
        await assertCollectionLength(nftAccount, expectedEmptyCollectionLength);
        await assertCollectionLength(joshAccount, expectedEmptyCollectionLength);

        // Mint a token with nftAccount as recipient
        await mintNFT(exampleNFTAccount, nftAccount);

        // Ensure collection lengths for each account
        await assertCollectionLength(nftAccount, 1);
        await assertCollectionLength(joshAccount, expectedEmptyCollectionLength);

        // NFT in nftAccount should have id of 0
        await assertNFTInCollection(nftAccount, expectedNFTID, expectedCollectionPath);

        // Transfer NFT to joshAccount
        await shallPass(
            sendTransaction(
                "transfer_nft",
                [nftAccount],
                [joshAccount, expectedNFTID.toString()]
            )
        );

        // Ensure NFT now in joshAccount's collection
        await assertCollectionLength(nftAccount, senderExpectedCollectionLength);
        await assertCollectionLength(joshAccount, recipientExpectedCollectionLength);

        // NFT id in joshAccount's collection should have id of 0
        await assertNFTInCollection(joshAccount, expectedNFTID, expectedCollectionPath);
    });

    // Destroy NFT
    test("Should be able to withdraw an NFT and destroy it, not reducing the supply", async () => {
        const expectedEmptyCollectionLength = 0;
        const expectedNFTID = 0;
        const expectedTotalSupply = 1;

        // Deploy all contracts
        const { nftAccount, exampleNFTAccount, _, contractParams } = await getTestAddressesAndContractParams();
        await deployContracts(contractParams);

        // Setup account with NFT Collection
        await setupAccountNFTCollection([ nftAccount ]);

        // Collection should be empty
        await assertCollectionLength(nftAccount, expectedEmptyCollectionLength);

        // Mint a token with nftAccount as recipient
        await mintNFT(exampleNFTAccount, nftAccount);

        // Ensure collection length & total supply == 1
        await assertCollectionLength(nftAccount, 1);
        await assertTotalSupply(expectedTotalSupply);

        // Destroy NFT
        await shallPass(
            sendTransaction(
                "destroy_nft",
                [nftAccount],
                [expectedNFTID.toString()]
            )
        );

        // Ensure NFT not in joshAccount's collection
        await assertCollectionLength(nftAccount, expectedEmptyCollectionLength);

        // Total supply of NFTs should still be 1
        await assertTotalSupply(expectedTotalSupply);
    });


});

// Generate accounts and contract deployment parameters for each account
// relevant to the above test cases
async function getTestAddressesAndContractParams() {
    const _nftAccount = await getAccountAddress("NFTAddress");
    const _exampleNFTAccount = await getAccountAddress("ExampleNFTAddress");
    const _joshAccount = await getAccountAddress("JoshAddress");
    const _contractParams = [
        {
            to: _nftAccount,
            name: "NonFungibleToken"
        },
        {
            to: _nftAccount,
            name: "MetadataViews"
        },
        {
            to: _exampleNFTAccount,
            name: "ExampleNFT"
        }
    ];

    return {
        nftAccount: _nftAccount,
        exampleNFTAccount: _exampleNFTAccount,
        joshAccount: _joshAccount,
        contractParams: _contractParams
    };
};

