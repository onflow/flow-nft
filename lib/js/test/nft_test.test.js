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
        // Deploy all contracts
        const accounts = await deploy();

        const expectedTokenSupply = 0;
        const expectedCollectionLength = 0;

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
            args: [accounts["exampleNFTAddress"]]
        });
        expect(actualCollectionLength).toStrictEqual(expectedCollectionLength.toString());
    });
});

/*** Test helper functions ***/

// Deploys the passed contracts, catching & logging errors
async function deployContract(params) {
    const [result, error] = await deployContractByName(params);
    if (error != null) {
        console.log(`Error in deployment - ${error}`);
        emulator.stop();
        process.exit(1);
    }
}

// Deploys NFT related contracts related to the above tests
const deploy = async () => {
  try {
      const nftAccount = await getAccountAddress("NFTAddress");
      const exampleNFTAccount = await getAccountAddress("ExampleNFTAddress");

      await deployContract({
              to: nftAccount,
              name: "NonFungibleToken"
      });

      await deployContract({
          to: nftAccount,
          name: "MetadataViews"
      });

      await deployContract({
          to: exampleNFTAccount,
          name: "ExampleNFT"
      });
      return {
          "nftAddress": nftAccount,
          "exampleNFTAddress": exampleNFTAccount
      };
  } catch (error) {
      throw error;
  }
};

