import path from "path";
import {
    emulator,
    init,
    getAccountAddress,
} from "@onflow/flow-js-testing";
import { deployContracts } from "../templates/deploy_template";
import { assertCollectionLength, assertTotalSupply } from "../templates/assertions_template";
import {
    mintNFT,
    setupAccountNFTCollection,
} from "../templates/transaction_template";

// Increase timeout if your tests failing due to timeout
jest.setTimeout(10000);

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
        const { _, exampleNFTAccount, contractParams } = await getTestAddressesAndContractParams();
        await deployContracts(contractParams);

        // Verify NFT contract deploys without tokens in circulation
        await assertTotalSupply(BASE_PATH, expectedTotalSupply)

        // Ensure initialized collection is empty
        await assertCollectionLength(BASE_PATH, exampleNFTAccount, expectedCollectionLength)
    });

    // Deploy Example NFT contract and mint a token
    test("Should be able to mint a token", async () => {

        // Deploy all contracts
        const { nftAccount, exampleNFTAccount, contractParams } = await getTestAddressesAndContractParams();
        await deployContracts(contractParams);

        // Setup account with NFT Collection
        await setupAccountNFTCollection(BASE_PATH, [ nftAccount ])

        // Mint a token with nftAccount as recipient
        await mintNFT(BASE_PATH, exampleNFTAccount, nftAccount);

        // Make sure NFT is in the account we minted to
        await assertCollectionLength(BASE_PATH, nftAccount, 1);
    });
});

// Generate accounts and contract deployment parameters for each account
// relevant to the above test cases
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

