import {
    emulator,
    deployContractByName
} from "@onflow/flow-js-testing";
import {assertNoError} from "./assertions_template";

// Deploys contracts from an array of passed params
export async function deployContracts(params) {
    try {
        // Deploy each contract defined in the passed parameters
        for (const param of params) {
            await deployContract(param)
        }

    } catch (error) {
        throw error;
    }
};

// Deploys the passed contracts, catching & logging errors
async function deployContract(params) {
    const [result, error] = await deployContractByName(params);
    assertNoError(error);
};
