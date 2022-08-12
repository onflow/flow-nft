import fs from "fs";

export const transactionFilenames = {
    filenameDestroyNFT: "transactions/destroy_nft.cdc",
    filenameMintNFT: "transactions/mint_nft.cdc",
    filenameSetupAccount: "transactions/setup_account.cdc",
    filenameSetupAccountFromNFTReference: "transactions/setup_account_from_nft_reference.cdc",
    filenameSetupAccountToReceiveRoyalty: "transactions/setup_account_to_receive_royalty.cdc",
    filenameSetupForwarding: "transactions/setup_forwarding.cdc",
    filenameTransferNFT: "transactions/transfer_nft.cdc"
};

export function readTransactionFromPath(path) {
    return fs.readFileSync(path, { encoding:'utf8', flag:'r' })
}