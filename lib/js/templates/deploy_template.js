import {
    emulator,
    getAccountAddress,
    deployContractByName
} from "@onflow/flow-js-testing";

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
    if (error != null) {
        console.log(`Error in deployment - ${error}`);
        emulator.stop();
        process.exit(1);
    }
}