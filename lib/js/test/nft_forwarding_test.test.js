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

describe("NFTForwarding Contract Tests", () => {

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

    // Deploy contracts and verify proper deployment
    test("Should forward NFT to designated forwarding recipient", async () => {
        /**
         * TODO: High Level Steps
         * [X] Deploy contracts
         *      - NonFungibleToken
         *      - MetadataViews
         *      - ExampleNFT
         *      - NFTForwarding
         * [ ] Setup accounts
         *      - Setup forwarderAccount with a collection
         *      - Setup recipientAccount with a collection
         *      - Setup nftSenderAccount with a collection
         *      - Setup forwarderAccount with NFTForwarder
         *          * Designate recipientAccount as forwardingRecipient
         * [ ] Mint NFT from ExampleNFT account, minting to nftSenderAccount
         * [ ] Transfer NFT from nftSenderAccount to forwarderAccount
         * [ ] Verify
         *      - NFT no longer exists in nftSenderAccount
         *      - NFT is not in forwarderAccount
         *      - NFT is in recipientAccount
         *      - NFT ID matches ID that was originally in nftSenderAccount
         *
         * Missing Pieces
         * [ ] Transaction: Setup NFTForwarder resource with receiverAccount's Receiver capability
         *      - Dependent on having recipientAccount's Receiver Capability
         * [ ] Transaction: Get recipient account's Receiver Capability
         */

        // Deploy all contracts
        const {
            nftAccount,
            exampleNFTAccount,
            forwarderAccount,
            recipientAccount,
            thirdPartyAccount,
            contractParams
        } = await getTestAddressesAndContractParams();
        await deployContracts(contractParams);

        // Setup accounts with ExampleNFT collections
        //   - forwarderAccount (might not have to do this since Forwarder is same CollectionPublic interface)
        //   - recipientAccount
        //   - thirdPartyAccount

        // Mint NFTs from ExampleNFTAccount to thirdPartyAccount
        //   - save NFT id to compare in recipientAccount's collection after forwarding

        // Transfer NFT from thirdPartyAccount to forwarderAccount

        // Verify
        //   - forwarderAccount collection is empty (length == 0.toString())
        //   - thirdPartyAccount collection is empty (length == 0.toString())
        //   - recipientAccount collection contains an NFT && id matches on sent by thirdPartyAccount to forwarderAccount

        expect(0).toStrictEqual(0)
    });
});

async function getTestAddressesAndContractParams() {
    const _nftAccount = await getAccountAddress("NFTAddress");
    const _exampleNFTAccount = await getAccountAddress("ExampleNFTAddress");
    const _forwarderAccount = await getAccountAddress("ForwarderAddress");
    const _recipientAccount = await getAccountAddress("RecipientAddress");
    const _thirdPartyAccount = await getAccountAddress("ThirdPartyAddress");

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
        },
        {
            to: _forwarderAccount,
            name: "utility/NFTForwarding"
        }
    ];

    return {
        nftAccount: _nftAccount,
        exampleNFTAccount: _exampleNFTAccount,
        forwarderAccount: _forwarderAccount,
        recipientAccount: _recipientAccount,
        thirdPartyAccount: _thirdPartyAccount,
        contractParams: _contractParams
    };
};