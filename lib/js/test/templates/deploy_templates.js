import { deployContractByName, shallPass } from "@onflow/flow-js-testing";

// Deploys contracts from an array of passed params
// each element of array has the form of:
//   { to: <account>, name: <contract_name> }
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
    const [result, error] = await shallPass(
        deployContractByName(params)
    );
};
