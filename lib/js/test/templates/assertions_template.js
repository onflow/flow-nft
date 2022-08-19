import { emulator, executeScript } from "@onflow/flow-js-testing";

export async function assertCollectionLength(account, expectedCollectionLength) {
    const [actualCollectionLength, e] = await executeScript(
        "get_collection_length",
        [account]
    );
    assertNoError(e);
    expect(actualCollectionLength).toBe(expectedCollectionLength.toString())
};

export async function assertTotalSupply(expectedTotalSupply) {
    const [actualTotalSupply, e] = await executeScript(
        "get_total_supply"
    );
    assertNoError(e);
    expect(actualTotalSupply).toBe(expectedTotalSupply.toString())
};

function assertNoError(error) {
    if (error != null) {
        console.log(`Error in deployment - ${error}`);
        emulator.stop();
        process.exit(1);
    };
};
