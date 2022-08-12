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
        const expectedTokenSupply = 0;
        const expectedCollectionLength = 0;

        // Deploy all contracts
        const { _, exampleNFTAccount, contractParams } = await getTestAddressesAndContractParams();
        await deployContracts(contractParams);

        // Verify NFT contract deploys without tokens in circulation
        const [actualTokenSupply, e1] = await executeScript({
            code: readScriptFromPath(
                path.resolve(
                    basePath,
                    scriptFilenames["filenameGetTotalSupply"]
                )
            ),
            args: []
        });

        // Ensure no tokens in supply
        expect(actualTokenSupply).toStrictEqual(expectedTokenSupply.toString());
        const [actualCollectionLength, e2] = await executeScript({
            code: readScriptFromPath(
                path.resolve(
                    basePath,
                    scriptFilenames["filenameGetCollectionLength"]
                )
            ),
            args: [ exampleNFTAccount ]
        });
        // Ensure initialized collection is empty
        expect(actualCollectionLength).toStrictEqual(expectedCollectionLength.toString());
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

