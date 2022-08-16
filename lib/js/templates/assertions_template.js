import path from "path";
import { emulator, executeScript } from "@onflow/flow-js-testing";
import { readScriptFromPath, scriptFilenames } from "./script_template";

export async function assertCollectionLength(basePath, account, expectedCollectionLength) {
    const [actualCollectionLength, e] = await executeScript({
            code: readScriptFromPath(
                path.resolve(
                    basePath,
                    scriptFilenames["filenameGetCollectionLength"]
                )
            ),
            args: [ account ]
        });
    assertNoError(e)
    expect(actualCollectionLength).toBe(expectedCollectionLength.toString())
};

export async function assertTotalSupply(basePath, expectedTotalSupply) {
    const [actualTotalSupply, e] = await executeScript({
        code: readScriptFromPath(
            path.resolve(
                basePath,
                scriptFilenames["filenameGetTotalSupply"]
            )
        ),
        args: []
    });
    assertNoError(e)
    expect(actualTotalSupply).toBe(expectedTotalSupply.toString())
};

export function assertNoError(error) {
    if (error != null) {
        console.log(`Error in deployment - ${error}`);
        emulator.stop();
        process.exit(1);
    };
};
