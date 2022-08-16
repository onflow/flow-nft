import path from "path";
import {
    emulator,
    init,
    shallPass,
    shallRevert,
    executeScript,
    getAccountAddress,
    sendTransaction,
    mintFlow,
    deployContractByName,
    shallThrow,
} from "@onflow/flow-js-testing";
import { readScriptFromPath, scriptFilenames } from "../templates/script_template";
import { deployContracts } from "../templates/deploy_template";
import {
    assertCollectionLength,
    assertNoError,
    assertTotalSupply
} from "../templates/assertions_template";
import {
    readTransactionFromPath,
    setupAccountNFTCollection,
    transactionFilenames
} from "../templates/transaction_template";

// Increase timeout if your tests failing due to timeout
jest.setTimeout(10000);

// Set basepath of the project
const basePath = path.resolve(__dirname, "./../../../");

describe("NonFungibleToken Contract Tests", () => {

    // Setup each test
    beforeEach(async () => {
        const logging = false;

        await init(basePath);
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
        const { _, exampleNFTAccount, contractParams } = await getTestAddressesAndContractParams();
        await deployContracts(contractParams);

        // Verify NFT contract deploys without tokens in circulation
        await assertTotalSupply(basePath, expectedTotalSupply)

        // Ensure initialized collection is empty
        await assertCollectionLength(basePath, exampleNFTAccount, expectedCollectionLength)
    });

    // Deploy Example NFT contract and mint a token
    test("Should be able to mint a token", async () => {

        // Deploy all contracts
        const { nftAccount, exampleNFTAccount, contractParams } = await getTestAddressesAndContractParams();
        await deployContracts(contractParams);

        // Setup account with NFT Collection
        await setupAccountNFTCollection(basePath, [ nftAccount ])

        // Mint a token with nftAccount as recipient
        const [mintTxn, e] = await sendTransaction({
            code: readTransactionFromPath(
                path.resolve(
                    basePath,
                    transactionFilenames["filenameMintNFT"]
                )
            ),
            args: [
                nftAccount,
                "testNFT",
                "description",
                "test.jpg",
                [ ],
                [ ],
                [ ]
            ],
            signers: [ exampleNFTAccount ]
        });
        assertNoError(e)

        // Make sure NFT is in the account we minted to
        await assertCollectionLength(basePath, nftAccount, 1);
    });
});

async function getTestAddressesAndContractParams() {
    const _nftAccount = await getAccountAddress("NFTAddress");
    const _exampleNFTAccount = await getAccountAddress("ExampleNFTAddress");
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
        contractParams: _contractParams
    };
};

