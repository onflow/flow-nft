import path from "path";
import {
    emulator,
    init,
    shallPass,
    shallRevert,
    getAccountAddress,
    sendTransaction,
} from "@onflow/flow-js-testing";
import { deployContracts } from "../templates/deploy_template";
import {
    mintNFT,
    readTransactionFromPath,
    setupAccountNFTCollection, setupForwarding,
    transactionFilenames
} from "../templates/transaction_template";
import { assertCollectionLength } from "../templates/assertions_template";

// Increase timeout if your tests failing due to timeout
jest.setTimeout(10000);

// Set basepath of the project
const BASE_PATH = path.resolve(__dirname, "./../../../../");

describe("NFTForwarding Contract Tests", () => {

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

    // Deploy contracts & test forwarding
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
        await setupAccountNFTCollection(
            BASE_PATH,
            [ thirdPartyAccount, forwarderAccount, recipientAccount ]
        );

        // Mint NFT from ExampleNFTAccount and send to thirdPartyAccount
        await mintNFT(BASE_PATH, exampleNFTAccount, thirdPartyAccount);

        // Setup forwarding from forwarderAccount to recipientAccount
        await setupForwarding(BASE_PATH, forwarderAccount, recipientAccount);

        // Transfer NFT from thirdPartyAccount to forwarderAccount
        const [transferTxn, e3] = await shallPass(
            sendTransaction({
                code: readTransactionFromPath(
                    path.resolve(
                        BASE_PATH,
                        transactionFilenames["filenameTransferNFTToReceiver"]
                    )
                ),
                args: [ forwarderAccount, "0" ],
                signers: [ thirdPartyAccount ]
            })
        );

        // Make sure the NFT is in the forwarding recipient account and no other
        // following the path of thirdPartyAccount -> forwarderAccount -> recipientAccount
        // with a single transfer transaction
        await assertCollectionLength(BASE_PATH, thirdPartyAccount, 0);
        await assertCollectionLength(BASE_PATH, recipientAccount, 1);

    });

    test("Setup then change forwarding recipient", async () => {
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
        await setupAccountNFTCollection(
            BASE_PATH,
            [exampleNFTAccount, thirdPartyAccount, forwarderAccount, recipientAccount]
        );

        // Mint NFT from ExampleNFTAccount and send to thirdPartyAccount
        await mintNFT(BASE_PATH, exampleNFTAccount, thirdPartyAccount);

        // Setup forwarding from forwarderAccount to recipientAccount
        await setupForwarding(BASE_PATH, forwarderAccount, recipientAccount);

        // Change forwarding recipient to be exampleNFTAccount
        const [changeRecipientTxn, e1] = await shallPass(
            sendTransaction({
                code: readTransactionFromPath(
                    path.resolve(
                        BASE_PATH,
                        transactionFilenames["filenameChangeForwarderRecipient"]
                    )
                ),
                args: [ exampleNFTAccount ],
                signers: [ forwarderAccount ]
            })
        );

        // Transfer NFT to forwarderAccount
        const [transferTxn2, e2] = await shallPass(
            sendTransaction({
                code: readTransactionFromPath(
                    path.resolve(
                        BASE_PATH,
                        transactionFilenames["filenameTransferNFTToReceiver"]
                    )
                ),
                args: [ forwarderAccount, "0" ],
                signers: [ thirdPartyAccount ]
            })
        );
        // Verify NFT is now in exampleNFTAccount's collection
        await assertCollectionLength(BASE_PATH, thirdPartyAccount, 0);
        await assertCollectionLength(BASE_PATH, exampleNFTAccount, 1);
    });

    test("Setup NFTForwarder then unlink recipient's collection. Forwarding should fail.", async () => {

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
        await setupAccountNFTCollection(
            BASE_PATH,
            [exampleNFTAccount, thirdPartyAccount, forwarderAccount, recipientAccount]
        );

        // Mint NFT from ExampleNFTAccount and send to thirdPartyAccount
        await mintNFT(BASE_PATH, exampleNFTAccount, thirdPartyAccount);

        // Setup forwarding from forwarderAccount to recipientAccount
        await setupForwarding(BASE_PATH, forwarderAccount, recipientAccount);

        // Unlink collection in recipientAccount
        const [unlinkTxn, e] = await shallPass(
            sendTransaction({
                code: readTransactionFromPath(
                    path.resolve(
                        BASE_PATH,
                        transactionFilenames["filenameUnlinkCollection"]
                    )
                ),
                args: [ ],
                signers: [ recipientAccount ]
            })
        );

        // Transfer NFT, but attempt to forward should fail
        const [transferTxn3, e8] = await shallRevert(
            sendTransaction({
                code: readTransactionFromPath(
                    path.resolve(
                        BASE_PATH,
                        transactionFilenames["filenameTransferNFTToReceiver"]
                    )
                ),
                args: [ forwarderAccount, "1" ],
                signers: [ thirdPartyAccount ]
            })
        );
        // NFT should still be in thirdPartyAccount's collection
        await assertCollectionLength(BASE_PATH, thirdPartyAccount, 1);

    });

    test("Setup NFTForwarder then unlink and restore collection in forwarder's account", async () => {
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
        await setupAccountNFTCollection(
            BASE_PATH,
            [exampleNFTAccount, thirdPartyAccount, forwarderAccount, recipientAccount]
        );

        // Mint NFT from ExampleNFTAccount and send to thirdPartyAccount
        await mintNFT(BASE_PATH, exampleNFTAccount, thirdPartyAccount);

        // Setup forwarding from forwarderAccount to recipientAccount
        await setupForwarding(BASE_PATH, forwarderAccount, recipientAccount);

        // Unlink forwarding & restore link to collection
        const [unlinkForwarderTxn, e] = await shallPass(
            sendTransaction({
                code: readTransactionFromPath(
                    path.resolve(
                        BASE_PATH,
                        transactionFilenames["filenameUnlinkForwarderLinkCollection"]
                    )
                ),
                args: [ ],
                signers: [ forwarderAccount ]
            })
        );

        // Transfer NFT to forwarderAccount
        const [transferTxn4, e10] = await shallPass(
            sendTransaction({
                code: readTransactionFromPath(
                    path.resolve(
                        BASE_PATH,
                        transactionFilenames["filenameTransferNFT"]
                    )
                ),
                args: [ forwarderAccount, "0" ],
                signers: [ thirdPartyAccount ]
            })
        );

        // Verify NFT is now in forwarderAccount's collection
        await assertCollectionLength(BASE_PATH, thirdPartyAccount, 0);
        await assertCollectionLength(BASE_PATH, forwarderAccount, 1);
    });
});

// Generate accounts and contract deployment parameters for each account
// relevant to the above test cases
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
