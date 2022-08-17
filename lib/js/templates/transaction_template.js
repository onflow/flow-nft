import fs from "fs";
import path from "path";
import { sendTransaction, shallPass } from "@onflow/flow-js-testing";

export const transactionFilenames = {
    filenameChangeForwarderRecipient: "transactions/change_forwarder_recipient.cdc",
    filenameCreateForwarder: "transactions/create_forwarder.cdc",
    filenameDestroyNFT: "transactions/destroy_nft.cdc",
    filenameMintNFT: "transactions/mint_nft.cdc",
    filenameSetupAccount: "transactions/setup_account.cdc",
    filenameSetupAccountFromNFTReference: "transactions/setup_account_from_nft_reference.cdc",
    filenameSetupAccountToReceiveRoyalty: "transactions/setup_account_to_receive_royalty.cdc",
    filenameTransferNFT: "transactions/transfer_nft.cdc",
    filenameTransferNFTToReceiver: "transactions/transfer_nft_to_receiver.cdc",
    filenameUnlinkCollection: "transactions/unlink_collection.cdc",
    filenameUnlinkForwarderLinkCollection: "transactions/unlink_forwarder_link_collection.cdc"
};

// Reads a transaction from a filepath
export function readTransactionFromPath(path) {
    return fs.readFileSync(path, { encoding:'utf8', flag:'r' })
};

// Sets up each account in passed array with an NFT Collection resource,
// reading the transaction code relative to the passed base path
export async function setupAccountNFTCollection(basePath, accounts) {
    for (const account of accounts) {
        const [txn, e] = await shallPass(
            sendTransaction({
                code: readTransactionFromPath(
                    path.resolve(
                        basePath,
                        transactionFilenames["filenameSetupAccount"]
                    )
                ),
                args: [],
                signers: [ account ]
            })
        );
    };
};

// Mints an NFT to nftRecipient, signed by signer,
// reading the transaction code relative to the passed base path
export async function mintNFT(basePath, signer, nftRecipient) {
    // Mint a token with nftAccount as recipient
    const [mintTxn, e] = await shallPass(
        sendTransaction({
            code: readTransactionFromPath(
                path.resolve(
                    basePath,
                    transactionFilenames["filenameMintNFT"]
                )
            ),
            args: [
                nftRecipient,
                "testNFT",
                "description",
                "test.jpg",
                [ ],
                [ ],
                [ ]
            ],
            signers: [ signer ]
        })
    );
};

// Sets up NFTForwarder resource in forwarder's account, directing
// NFT deposits to recipient account's collection
export async function setupForwarding(basePath, forwarder, recipient) {
    const [setupForwardingTxn, e] = await shallPass(
        sendTransaction({
            code: readTransactionFromPath(
                path.resolve(
                    basePath,
                    transactionFilenames["filenameCreateForwarder"]
                )
            ),
            args: [ recipient ],
            signers: [ forwarder ]
        })
    );
};
