import fs from "fs";
import path from "path";
import {executeScript} from "@onflow/flow-js-testing";

export const scriptFilenames = {
    filenameBorrowNFT: "transactions/scripts/borrow_nft.cdc",
    filenameGetCollectionLength: "transactions/scripts/get_collection_length.cdc",
    filenameGetTotalSupply: "transactions/scripts/get_total_supply.cdc",
    filenameGetNFTMetadata: "transactions/scripts/get_nft_metadata.cdc",
    filenameGetNFTView: "transactions/scripts/get_nft_view.cdc"
};

export function readScriptFromPath(path) {
    return fs.readFileSync(path, { encoding:'utf8', flag:'r' })
};
