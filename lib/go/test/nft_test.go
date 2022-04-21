package test

import (
	"testing"

	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/onflow/flow-go-sdk/test"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/onflow/flow-nft/lib/go/contracts"
	"github.com/onflow/flow-nft/lib/go/templates"
)

func TestNFTDeployment(t *testing.T) {
	b := newBlockchain()

	nftAddress := deploy(t, b, "NonFungibleToken", contracts.NonFungibleToken())
	metadataAddress := deploy(t, b, "MetadataViews", contracts.MetadataViews())

	_ = deploy(
		t, b,
		"ExampleNFT",
		contracts.ExampleNFT(nftAddress, metadataAddress),
	)
}

func TestCreateNFT(t *testing.T) {
	b := newBlockchain()

	nftAddress := deploy(t, b, "NonFungibleToken", contracts.NonFungibleToken())
	metadataAddress := deploy(t, b, "MetadataViews", contracts.MetadataViews())

	accountKeys := test.AccountKeyGenerator()

	exampleNFTAccountKey, exampleNFTSigner := accountKeys.NewWithSigner()
	exampleNFTAddress := deploy(
		t, b,
		"ExampleNFT",
		contracts.ExampleNFT(nftAddress, metadataAddress),
		exampleNFTAccountKey,
	)

	script := templates.GenerateGetTotalSupplyScript(nftAddress, exampleNFTAddress)
	supply := executeScriptAndCheck(t, b, script, nil)
	assert.Equal(t, cadence.NewUInt64(0), supply)

	script = templates.GenerateGetCollectionLengthScript(nftAddress, exampleNFTAddress)
	length := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(exampleNFTAddress))})
	assert.Equal(t, cadence.NewInt(0), length)

	t.Run("Should be able to mint a token", func(t *testing.T) {

		beneficiaryAccountKey1, _ := accountKeys.NewWithSigner()
		beneficiaryAddress1, err := b.CreateAccount([]*flow.AccountKey{beneficiaryAccountKey1}, nil)
		require.NoError(t, err)
		beneficiaryAccountKey2, _ := accountKeys.NewWithSigner()
		beneficiaryAddress2, err := b.CreateAccount([]*flow.AccountKey{beneficiaryAccountKey2}, nil)
		require.NoError(t, err)

		script := templates.GenerateMintNFTScript(nftAddress, exampleNFTAddress, metadataAddress)

		tx := createTxWithTemplateAndAuthorizer(b, script, exampleNFTAddress)

		cut1, err := cadence.NewUFix64("0.25")
		require.NoError(t, err)
		cut2, err := cadence.NewUFix64("0.40")
		require.NoError(t, err)

		cuts := []cadence.Value{cut1, cut2}
		royaltyDescriptions := []cadence.Value{cadence.String("Minter royalty"), cadence.String("Creator royalty")}
		royaltyBeneficiaries := []cadence.Value{cadence.NewAddress(beneficiaryAddress1), cadence.NewAddress(beneficiaryAddress2)}

		tx.AddArgument(cadence.NewAddress(exampleNFTAddress))
		tx.AddArgument(cadence.String("Example NFT 0"))
		tx.AddArgument(cadence.String("This is an example NFT"))
		tx.AddArgument(cadence.String("example.jpeg"))
		tx.AddArgument(cadence.NewArray(cuts))
		tx.AddArgument(cadence.NewArray(royaltyDescriptions))
		tx.AddArgument(cadence.NewArray(royaltyBeneficiaries))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				exampleNFTAddress,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				exampleNFTSigner,
			},
			false,
		)

		script = templates.GenerateBorrowNFTScript(nftAddress, exampleNFTAddress)
		executeScriptAndCheck(
			t, b,
			script,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewAddress(exampleNFTAddress)),
				jsoncdc.MustEncode(cadence.NewUInt64(0)),
			},
		)

		script = templates.GenerateGetTotalSupplyScript(nftAddress, exampleNFTAddress)
		supply := executeScriptAndCheck(t, b, script, nil)
		assert.Equal(t, cadence.NewUInt64(1), supply)

		script = templates.GenerateGetCollectionLengthScript(nftAddress, exampleNFTAddress)
		length := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(exampleNFTAddress))})
		assert.Equal(t, cadence.NewInt(1), length)
	})

	t.Run("Shouldn't be able to borrow a reference to an NFT that doesn't exist", func(t *testing.T) {
		script = templates.GenerateBorrowNFTScript(nftAddress, exampleNFTAddress)

		result, err := b.ExecuteScript(
			script,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewAddress(exampleNFTAddress)),
				jsoncdc.MustEncode(cadence.NewUInt64(5)),
			},
		)
		require.NoError(t, err)

		assert.True(t, result.Reverted())
	})
}

func TestTransferNFT(t *testing.T) {
	b := newBlockchain()

	nftAddress := deploy(t, b, "NonFungibleToken", contracts.NonFungibleToken())
	metadataAddress := deploy(t, b, "MetadataViews", contracts.MetadataViews())

	accountKeys := test.AccountKeyGenerator()

	exampleNFTAccountKey, exampleNFTSigner := accountKeys.NewWithSigner()
	exampleNFTAddress := deploy(
		t, b,
		"ExampleNFT",
		contracts.ExampleNFT(nftAddress, metadataAddress),
		exampleNFTAccountKey,
	)

	joshAccountKey, joshSigner := accountKeys.NewWithSigner()
	joshAddress, err := b.CreateAccount([]*flow.AccountKey{joshAccountKey}, nil)
	require.NoError(t, err)

	beneficiaryAccountKey1, _ := accountKeys.NewWithSigner()
	beneficiaryAddress1, err := b.CreateAccount([]*flow.AccountKey{beneficiaryAccountKey1}, nil)
	require.NoError(t, err)
	beneficiaryAccountKey2, _ := accountKeys.NewWithSigner()
	beneficiaryAddress2, err := b.CreateAccount([]*flow.AccountKey{beneficiaryAccountKey2}, nil)
	require.NoError(t, err)

	script := templates.GenerateMintNFTScript(nftAddress, exampleNFTAddress, metadataAddress)

	tx := flow.NewTransaction().
		SetScript(script).
		SetGasLimit(100).
		SetProposalKey(
			b.ServiceKey().Address,
			b.ServiceKey().Index,
			b.ServiceKey().SequenceNumber,
		).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(exampleNFTAddress)

	cut1, err := cadence.NewUFix64("0.25")
	require.NoError(t, err)
	cut2, err := cadence.NewUFix64("0.40")
	require.NoError(t, err)

	cuts := []cadence.Value{cut1, cut2}
	royaltyDescriptions := []cadence.Value{cadence.String("Minter royalty"), cadence.String("Creator royalty")}
	royaltyBeneficiaries := []cadence.Value{cadence.NewAddress(beneficiaryAddress1), cadence.NewAddress(beneficiaryAddress2)}

	tx.AddArgument(cadence.NewAddress(exampleNFTAddress))
	tx.AddArgument(cadence.String("Example NFT 0"))
	tx.AddArgument(cadence.String("This is an example NFT"))
	tx.AddArgument(cadence.String("example.jpeg"))
	tx.AddArgument(cadence.NewArray(cuts))
	tx.AddArgument(cadence.NewArray(royaltyDescriptions))
	tx.AddArgument(cadence.NewArray(royaltyBeneficiaries))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{
			b.ServiceKey().Address,
			exampleNFTAddress,
		},
		[]crypto.Signer{
			b.ServiceKey().Signer(),
			exampleNFTSigner,
		},
		false,
	)

	// create a new Collection
	t.Run("Should be able to create a new empty NFT Collection", func(t *testing.T) {

		script := templates.GenerateSetupAccountScript(nftAddress, exampleNFTAddress)
		tx := createTxWithTemplateAndAuthorizer(b, script, joshAddress)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				joshAddress,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				joshSigner,
			},
			false,
		)

		script = templates.GenerateGetCollectionLengthScript(nftAddress, exampleNFTAddress)
		length := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(joshAddress))})
		assert.Equal(t, cadence.NewInt(0), length)
	})

	t.Run("Shouldn't be able to withdraw an NFT that doesn't exist in a collection", func(t *testing.T) {

		script := templates.GenerateTransferNFTScript(nftAddress, exampleNFTAddress)
		tx := createTxWithTemplateAndAuthorizer(b, script, exampleNFTAddress)

		tx.AddArgument(cadence.NewAddress(joshAddress))
		tx.AddArgument(cadence.NewUInt64(3))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				exampleNFTAddress,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				exampleNFTSigner,
			},
			true,
		)

		script = templates.GenerateGetCollectionLengthScript(nftAddress, exampleNFTAddress)
		length := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(joshAddress))})
		assert.Equal(t, cadence.NewInt(0), length)

		script = templates.GenerateGetCollectionLengthScript(nftAddress, exampleNFTAddress)
		length = executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(exampleNFTAddress))})
		assert.Equal(t, cadence.NewInt(1), length)
	})

	// transfer an NFT
	t.Run("Should be able to withdraw an NFT and deposit to another accounts collection", func(t *testing.T) {
		script := templates.GenerateTransferNFTScript(nftAddress, exampleNFTAddress)
		tx := createTxWithTemplateAndAuthorizer(b, script, exampleNFTAddress)

		tx.AddArgument(cadence.NewAddress(joshAddress))
		tx.AddArgument(cadence.NewUInt64(0))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				exampleNFTAddress,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				exampleNFTSigner,
			},
			false,
		)

		script = templates.GenerateBorrowNFTScript(nftAddress, exampleNFTAddress)
		executeScriptAndCheck(
			t, b,
			script,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewAddress(joshAddress)),
				jsoncdc.MustEncode(cadence.NewUInt64(0)),
			},
		)

		script = templates.GenerateGetCollectionLengthScript(nftAddress, exampleNFTAddress)
		length := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(joshAddress))})
		assert.Equal(t, cadence.NewInt(1), length)

		script = templates.GenerateGetCollectionLengthScript(nftAddress, exampleNFTAddress)
		length = executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(exampleNFTAddress))})
		assert.Equal(t, cadence.NewInt(0), length)
	})

	// transfer an NFT
	t.Run("Should be able to withdraw an NFT and destroy it, not reducing the supply", func(t *testing.T) {

		script := templates.GenerateDestroyNFTScript(nftAddress, exampleNFTAddress)

		tx := createTxWithTemplateAndAuthorizer(b, script, joshAddress)

		tx.AddArgument(cadence.NewUInt64(0))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				joshAddress,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				joshSigner,
			},
			false,
		)

		script = templates.GenerateGetCollectionLengthScript(nftAddress, exampleNFTAddress)
		length := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(joshAddress))})
		assert.Equal(t, cadence.NewInt(0), length)

		script = templates.GenerateGetCollectionLengthScript(nftAddress, exampleNFTAddress)
		length = executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(exampleNFTAddress))})
		assert.Equal(t, cadence.NewInt(0), length)

		script = templates.GenerateGetTotalSupplyScript(nftAddress, exampleNFTAddress)
		supply := executeScriptAndCheck(t, b, script, nil)
		assert.Equal(t, cadence.NewUInt64(1), supply)
	})
}
