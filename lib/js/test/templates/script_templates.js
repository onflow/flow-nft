import { expect } from "@jest/globals";
import { executeScript } from "@onflow/flow-js-testing";

// Executes borrow_nft script with passed params
// Configured for error handling on caller side
export async function executeBorrowNFTScript(address, id) {
    const [result, err] = await executeScript(
        "borrow_nft",
        [ address, id.toString() ]
    );
    return [ result, err ];
};

// Executes get_collection_ids script with passed params,
// returning array of NFT IDs contained in the address's collection
export async function executeGetCollectionIDs(address, collectionPath) {
    const [result, err] = await executeScript(
        "get_collection_ids",
        [ address, collectionPath ]
    );
    expect(err).toBeNull();
    return result;
};

// Executes get_contract_view script with passed params,
// returning the storage path this contract wants nfts saved to.
export async function executeGetContractStoragePath(address, name) {
    const [result, err] = await executeScript(
        "get_contract_storage_path",
        [ address, name ]
    );
    expect(err).toBeNull();
    return result;
};
