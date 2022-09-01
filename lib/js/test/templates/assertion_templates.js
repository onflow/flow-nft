import { expect } from "@jest/globals";
import { executeScript } from "@onflow/flow-js-testing";
import { executeGetCollectionIDs } from "./script_templates";

// Asserts whether length of account's collection matches
// the expected collection length
export async function assertCollectionLength(account, expectedCollectionLength) {
    const [actualCollectionLength, e] = await executeScript(
        "get_collection_length",
        [account]
    );
    expect(e).toBeNull();
    expect(actualCollectionLength).toBe(expectedCollectionLength.toString());
};

// Asserts that total supply of ExampleNFT matches passed expected total supply
export async function assertTotalSupply(expectedTotalSupply) {
    const [actualTotalSupply, e] = await executeScript(
        "get_total_supply"
    );
    expect(e).toBeNull();
    expect(actualTotalSupply).toBe(expectedTotalSupply.toString());
};

// Asserts whether the NFT corresponding to the id is in address's collection
export async function assertNFTInCollection(address, id, collectionPath) {
    const ids = await executeGetCollectionIDs(address, collectionPath);
    expect(ids.includes(id.toString())).toBe(true);
};
