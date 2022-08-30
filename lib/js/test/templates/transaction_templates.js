import { sendTransaction, shallPass } from "@onflow/flow-js-testing";

// Sets up each account in passed array with an NFT Collection resource,
// reading the transaction code relative to the passed base path
export async function setupAccountNFTCollection(accounts) {
    for (const account of accounts) {
        const [txn, e] = await shallPass(
            sendTransaction("setup_account", [account], [])
        );
    };
};

// Mints an NFT to nftRecipient, signed by signer,
// reading the transaction code relative to the passed base path
export async function mintNFT(signer, nftRecipient) {
    // Mint a token to nftRecipient's collection
    const [mintTxn, e] = await shallPass(
        sendTransaction(
            "mint_nft",
            [ signer ],
            [
                nftRecipient,
                "TestNFT",
                "Test Description",
                "testNFT.jpeg",
                [],
                [],
                []
            ]
        )
    );
};

// Sets up NFTForwarder resource in forwarder's account, directing
// NFT deposits to recipient account's collection
export async function setupForwarding(forwarder, recipient) {
    const [setupForwardingTxn, e] = await shallPass(
        sendTransaction("NFTForwarding/create_forwarder", [ forwarder ], [ recipient ])
    );
};
