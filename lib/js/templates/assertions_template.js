import path from "path";
import { executeScript } from "@onflow/flow-js-testing";
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

    expect(actualCollectionLength).toStrictEqual(expectedCollectionLength.toString())
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

    expect(actualTotalSupply).toStrictEqual(expectedTotalSupply.toString())
};
