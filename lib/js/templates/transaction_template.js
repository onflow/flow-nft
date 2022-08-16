import fs from "fs";
import path from "path";
import { sendTransaction, shallPass } from "@onflow/flow-js-testing";
import { assertNoError } from "./assertions_template";

export const transactionFilenames = {
    filenameDestroyNFT: "transactions/destroy_nft.cdc",
    filenameMintNFT: "transactions/mint_nft.cdc",
    filenameSetupAccount: "transactions/setup_account.cdc",
    filenameSetupAccountFromNFTReference: "transactions/setup_account_from_nft_reference.cdc",
    filenameSetupAccountToReceiveRoyalty: "transactions/setup_account_to_receive_royalty.cdc",
    filenameCreateForwarder: "transactions/create_forwarder.cdc",
    filenameTransferNFT: "transactions/transfer_nft.cdc",
    filenameTransferNFTToReceiver: "transactions/transfer_nft_to_receiver.cdc"
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
        assertNoError(e);
    };
};
