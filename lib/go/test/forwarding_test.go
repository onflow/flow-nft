package test

import (
	"log"
	"testing"

	"github.com/onflow/cadence"
	"github.com/onflow/flow-go-sdk/crypto"
	sdktemplates "github.com/onflow/flow-go-sdk/templates"
	"github.com/onflow/flow-go-sdk/test"

	"github.com/onflow/flow-nft/lib/go/contracts"
	"github.com/onflow/flow-nft/lib/go/templates"

	"github.com/stretchr/testify/assert"
	//	"github.com/stretchr/testify/require"

	"github.com/onflow/flow-go-sdk"
)

func TestNFTForwarding(t *testing.T) {
	b := newBlockchain()

	accountKeys := test.AccountKeyGenerator()

	// deploy nft contract
	nftCode := contracts.NonFungibleToken()
	nftAddr, err := b.CreateAccount(
		nil,
		[]sdktemplates.Contract{
			{
				Name:   "NonFungibleToken",
				Source: string(nftCode),
			},
		},
	)
	assert.NoError(t, err)

	// deploy example token contract
	exampleNftCode := contracts.ExampleNFT(nftAddr.String())
	exampleNftAccountKey, exampleNftTokenSigner := accountKeys.NewWithSigner()
	exampleNftAddr, err := b.CreateAccount(
		[]*flow.AccountKey{exampleNftAccountKey},
		[]sdktemplates.Contract{
			{
				Name:   "ExampleNFT",
				Source: string(exampleNftCode),
			},
		},
	)
	assert.NoError(t, err)
	log.Print(exampleNftTokenSigner)
	log.Print(exampleNftAddr)

	// deploy forwarding contract
	forwarderContractCode := contracts.NFTForwarding(nftAddr.String())
	forwarderAccountKey, forwarderTokenSigner := accountKeys.NewWithSigner()
	forwarderAddr, err := b.CreateAccount(
		[]*flow.AccountKey{forwarderAccountKey},
		[]sdktemplates.Contract{
			{
				Name:   "NFTForwarding",
				Source: string(forwarderContractCode),
			},
		},
	)
	assert.NoError(t, err)
	log.Print(forwarderTokenSigner)
	log.Print(forwarderAddr)

	// mint a couple of new NFT and verify they exist
	mintScript := templates.GenerateMintNFTScript(nftAddr, exampleNftAddr, exampleNftAddr)
	tx := createTxWithTemplateAndAuthorizer(b, mintScript, exampleNftAddr)

	signAndSubmit(
		t, b, tx,
		[]flow.Address{
			b.ServiceKey().Address,
			exampleNftAddr,
		},
		[]crypto.Signer{
			b.ServiceKey().Signer(),
			exampleNftTokenSigner,
		},
		false,
	)

	checkScript := templates.GenerateInspectCollectionScript(
		nftAddr,
		exampleNftAddr,
		exampleNftAddr,
		"ExampleNFT",
		"NFTCollection",
		0,
	)
	executeScriptAndCheck(t, b, checkScript, nil)

	t.Run("Forwarder should forward NFT to original recipient.", func(t *testing.T) {
		// setup forwarder recipient and forwarder owner
		forwarderRecipientKey, forwarderRecipientSigner := accountKeys.NewWithSigner()
		forwarderRecipientAddr, err := b.CreateAccount([]*flow.AccountKey{forwarderRecipientKey}, nil)
		assert.NoError(t, err)
		log.Print(forwarderRecipientSigner, forwarderRecipientAddr)

		forwarderOwnerKey, forwarderOwnerSigner := accountKeys.NewWithSigner()
		forwarderOwnerAddr, err := b.CreateAccount([]*flow.AccountKey{forwarderOwnerKey}, nil)
		assert.NoError(t, err)
		log.Print(forwarderOwnerSigner, forwarderOwnerAddr)

		// forwarder recipient requires a valid NFT collection
		createCol := templates.GenerateCreateCollectionScript(
			nftAddr.String(),
			exampleNftAddr.String(),
			"ExampleNFT",
			"NFTCollection",
		)
		createColTx := createTxWithTemplateAndAuthorizer(b, createCol, forwarderRecipientAddr)
		signAndSubmit(
			t, b, createColTx,
			[]flow.Address{
				b.ServiceKey().Address,
				forwarderRecipientAddr,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				forwarderRecipientSigner,
			},
			false,
		)

		// create forwarder transaction, set owner and recipient
		genFwdrScript := templates.GenerateCreateForwarderTransaction(nftAddr.String(), exampleNftAddr.String(), forwarderAddr.String())

		genFwdrTx := flow.NewTransaction().
			SetScript(genFwdrScript).
			SetGasLimit(9999).
			SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
			SetPayer(b.ServiceKey().Address).
			AddAuthorizer(forwarderOwnerAddr)

		err = genFwdrTx.AddArgument(cadence.BytesToAddress(forwarderRecipientAddr.Bytes()))
		assert.NoError(t, err)

		signAndSubmit(
			t, b, genFwdrTx,
			[]flow.Address{
				b.ServiceKey().Address,
				forwarderOwnerAddr,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				forwarderOwnerSigner,
			},
			false,
		)

		// initiate transfer from minter -> forwarder owner
		transferScript := templates.GenerateTransferScript(
			nftAddr,
			exampleNftAddr,
			"ExampleNFT",
			"NFTCollection",
			forwarderOwnerAddr,
			0,
		)
		transferTx := createTxWithTemplateAndAuthorizer(b, transferScript, exampleNftAddr)
		signAndSubmit(
			t, b, transferTx,
			[]flow.Address{
				b.ServiceKey().Address,
				exampleNftAddr,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				exampleNftTokenSigner,
			},
			false,
		)

		// minter should no longer have NFT
		checkScript := templates.GenerateInspectCollectionLenScript(
			nftAddr,
			exampleNftAddr,
			exampleNftAddr,
			"ExampleNFT",
			"NFTCollection",
			0,
		)
		executeScriptAndCheck(t, b, checkScript, nil)

		// forwarder recipient should own NFT, id: 0
		checkScript = templates.GenerateInspectCollectionScript(
			nftAddr,
			exampleNftAddr,
			forwarderRecipientAddr,
			"ExampleNFT",
			"NFTCollection",
			0,
		)
	})

}
