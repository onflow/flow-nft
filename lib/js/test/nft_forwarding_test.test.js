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
    readTransactionFromPath,
    setupAccountNFTCollection,
    transactionFilenames
} from "../templates/transaction_template";
import { assertCollectionLength, assertNoError } from "../templates/assertions_template";

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

        // Deploy all contracts
        const {
            _,
            exampleNFTAccount,
            forwarderAccount,
            recipientAccount,
            thirdPartyAccount,
            contractParams
        } = await getTestAddressesAndContractParams();
        await deployContracts(contractParams);

        // Setup accounts with ExampleNFT collections
        await setupAccountNFTCollection(basePath, [thirdPartyAccount, forwarderAccount, recipientAccount]);
        await assertCollectionLength(basePath, thirdPartyAccount, 0);
        await assertCollectionLength(basePath, forwarderAccount, 0);
        await assertCollectionLength(basePath, recipientAccount, 0);

        // Mint NFT from ExampleNFTAccount and send to thirdPartyAccount
        const [mintTxn, e1] = await sendTransaction({
            code: readTransactionFromPath(
                path.resolve(
                    basePath,
                    transactionFilenames["filenameMintNFT"]
                )
            ),
            args: [
                thirdPartyAccount,
                "testNFT",
                "description",
                "test.jpg",
                [ ],
                [ ],
                [ ]
            ],
            signers: [ exampleNFTAccount ]
        });
        assertNoError(e1);

        // Make sure NFT is in the account we minted to
        await assertCollectionLength(basePath, thirdPartyAccount, 1);

        // Setup forwarding
        const [setupForwardingTxn, e2] = await sendTransaction({
            code: readTransactionFromPath(
                path.resolve(
                    basePath,
                    transactionFilenames["filenameCreateForwarder"]
                )
            ),
            args: [ recipientAccount ],
            signers: [ forwarderAccount ]
        });
        assertNoError(e2);

        // Transfer NFT from thirdPartyAccount to forwarderAccount
        const [transferTxn, e3] = await sendTransaction({
            code: readTransactionFromPath(
                path.resolve(
                    basePath,
                    transactionFilenames["filenameTransferNFTToReceiver"]
                )
            ),
            args: [ forwarderAccount, 0 ],
            signers: [ thirdPartyAccount ]
        });
        assertNoError(e3);

        // Make sure the NFT is in the forwarding recipient account and no other
        await assertCollectionLength(basePath, thirdPartyAccount, 0);
        // await assertCollectionLength(basePath, forwarderAccount, 0);
        await assertCollectionLength(basePath, recipientAccount, 1);

    });

    // TODO - test changeRecipient
    // TODO - test unlinking and ensure forwarding to recipient disabled
});

async function getTestAddressesAndContractParams() {
    const _nftAccount = await getAccountAddress("NFTAddress");
    const _exampleNFTAccount = await getAccountAddress("ExampleNFTAddress");
    const _forwarderAccount = await getAccountAddress("ForwarderAddress");
    const _recipientAccount = await getAccountAddress("RecipientAddress");
    const _thirdPartyAccount = await getAccountAddress("ThirdPartyAddress");

    const _contractParams = [{
            to: _nftAccount,
            name: "NonFungibleToken"
        }, {
            to: _nftAccount,
            name: "MetadataViews"
        }, {
            to: _exampleNFTAccount,
            name: "ExampleNFT"
        }, {
            to: _forwarderAccount,
            name: "utility/NFTForwarding"
    }];

    return {
        nftAccount: _nftAccount,
        exampleNFTAccount: _exampleNFTAccount,
        forwarderAccount: _forwarderAccount,
        recipientAccount: _recipientAccount,
        thirdPartyAccount: _thirdPartyAccount,
        contractParams: _contractParams
    };
};
