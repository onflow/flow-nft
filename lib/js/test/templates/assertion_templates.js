import { emulator, executeScript } from "@onflow/flow-js-testing";
import { executeGetCollectionIDs } from "./script_templates";

// Asserts whether length of account's collection matches
// the expected collection length
export async function assertCollectionLength(account, expectedCollectionLength) {
    const [actualCollectionLength, e] = await executeScript(
        "get_collection_length",
        [account]
    );
    assertNoError(e);
    expect(actualCollectionLength).toBe(expectedCollectionLength.toString());
};

// Asserts that total supply of ExampleNFT matches passed expected total supply
export async function assertTotalSupply(expectedTotalSupply) {
    const [actualTotalSupply, e] = await executeScript(
        "get_total_supply"
    );
    assertNoError(e);
    expect(actualTotalSupply).toBe(expectedTotalSupply.toString());
};

// Asserts whether length of account's collection matches
// the expected collection length
export async function assertNFTInCollection(address, id, collectionPath) {
    const ids = await executeGetCollectionIDs(address, collectionPath);
    assert(true, ids.includes(id.toString()));
};

// Asserts that passed error is null
// Exits emulator on failure
export function assertNoError(error) {
    if (error != null) {
        console.log(`Error in deployment - ${error}`);
        emulator.stop();
        process.exit(1);
    };
};

// Simple function that asserts passed condition is satisfied
// by given expression
export function assert(condition, expression) {
    if (expression != condition) {
        throw Error("Assertion failed");
    };
};
