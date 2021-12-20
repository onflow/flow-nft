package test

import (
	"testing"

	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	sdktemplates "github.com/onflow/flow-go-sdk/templates"
	"github.com/onflow/flow-go-sdk/test"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/onflow/flow-nft/lib/go/contracts"
	"github.com/onflow/flow-nft/lib/go/templates"
)

func TestNFTDeployment(t *testing.T) {
	b := newBlockchain()

	// Deploy NonFungibleToken.cdc
	nftCode := contracts.NonFungibleToken()
	nftAddress, err := b.CreateAccount(
		nil,
		[]sdktemplates.Contract{
			{
				Name:   "NonFungibleToken",
				Source: string(nftCode),
			},
		},
	)
	assert.NoError(t, err)

	// Deploy Views.cdc
	viewsCode := contracts.Views()
	viewsAddress, err := b.CreateAccount(
		nil,
		[]sdktemplates.Contract{
			{
				Name:   "Views",
				Source: string(viewsCode),
			},
		},
	)
	assert.NoError(t, err)

	// Deploy ExampleNFT.cdc
	tokenCode := contracts.ExampleNFT(nftAddress, viewsAddress)
	_, err = b.CreateAccount(
		nil,
		[]sdktemplates.Contract{
			{
				Name:   "ExampleNFT",
				Source: string(tokenCode),
			},
		},
	)
	assert.NoError(t, err)
}

func TestCreateNFT(t *testing.T) {
	b := newBlockchain()

	accountKeys := test.AccountKeyGenerator()

	// Deploy NonFungibleToken.cdc
	nftCode := contracts.NonFungibleToken()
	nftAddress, err := b.CreateAccount(
		nil,
		[]sdktemplates.Contract{
			{
				Name:   "NonFungibleToken",
				Source: string(nftCode),
			},
		},
	)
	assert.NoError(t, err)

	// Deploy Views.cdc
	viewsCode := contracts.Views()
	viewsAddress, err := b.CreateAccount(
		nil,
		[]sdktemplates.Contract{
			{
				Name:   "Views",
				Source: string(viewsCode),
			},
		},
	)
	assert.NoError(t, err)

	// Deploy ExampleNFT.cdc
	tokenCode := contracts.ExampleNFT(nftAddress, viewsAddress)
	tokenAccountKey, tokenSigner := accountKeys.NewWithSigner()
	tokenAddr, err := b.CreateAccount(
		[]*flow.AccountKey{tokenAccountKey},
		[]sdktemplates.Contract{
			{
				Name:   "ExampleNFT",
				Source: string(tokenCode),
			},
		},
	)
	assert.NoError(t, err)

	script := templates.GenerateGetTotalSupplyScript(nftAddress, tokenAddr)
	supply := executeScriptAndCheck(t, b, script, nil)
	assert.Equal(t, cadence.NewUInt64(0), supply)

	script = templates.GenerateGetCollectionLengthScript(nftAddress, tokenAddr)
	length := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(tokenAddr))})
	assert.Equal(t, cadence.NewInt(0), length)

	t.Run("Should be able to mint a token", func(t *testing.T) {

		script := templates.GenerateMintNFTScript(nftAddress, tokenAddr)

		tx := createTxWithTemplateAndAuthorizer(b, script, tokenAddr)

		tx.AddArgument(cadence.NewAddress(tokenAddr))
		tx.AddArgument(cadence.String("Example NFT 0"))
		tx.AddArgument(cadence.String("This is an example NFT"))
		tx.AddArgument(cadence.String("example.jpeg"))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				tokenAddr,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				tokenSigner,
			},
			false,
		)

		script = templates.GenerateBorrowNFTScript(nftAddress, tokenAddr)
		executeScriptAndCheck(
			t, b,
			script,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewAddress(tokenAddr)),
				jsoncdc.MustEncode(cadence.NewUInt64(0)),
			},
		)

		script = templates.GenerateGetTotalSupplyScript(nftAddress, tokenAddr)
		supply := executeScriptAndCheck(t, b, script, nil)
		assert.Equal(t, cadence.NewUInt64(1), supply)

		script = templates.GenerateGetCollectionLengthScript(nftAddress, tokenAddr)
		length := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(tokenAddr))})
		assert.Equal(t, cadence.NewInt(1), length)
	})

	t.Run("Shouldn't be able to borrow a reference to an NFT that doesn't exist", func(t *testing.T) {
		script = templates.GenerateBorrowNFTScript(nftAddress, tokenAddr)

		result, err := b.ExecuteScript(
			script,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewAddress(tokenAddr)),
				jsoncdc.MustEncode(cadence.NewUInt64(5)),
			},
		)
		require.NoError(t, err)

		assert.True(t, result.Reverted())
	})
}

func TestTransferNFT(t *testing.T) {
	b := newBlockchain()

	accountKeys := test.AccountKeyGenerator()

	// Deploy NonFungibleToken.cdc
	nftCode := contracts.NonFungibleToken()
	nftAddress, err := b.CreateAccount(
		nil,
		[]sdktemplates.Contract{
			{
				Name:   "NonFungibleToken",
				Source: string(nftCode),
			},
		},
	)
	assert.NoError(t, err)

	// Deploy Views.cdc
	viewsCode := contracts.Views()
	viewsAddress, err := b.CreateAccount(
		nil,
		[]sdktemplates.Contract{
			{
				Name:   "Views",
				Source: string(viewsCode),
			},
		},
	)
	assert.NoError(t, err)

	// Deploy ExampleNFT.cdc
	tokenCode := contracts.ExampleNFT(nftAddress, viewsAddress)
	tokenAccountKey, tokenSigner := accountKeys.NewWithSigner()
	tokenAddr, err := b.CreateAccount(
		[]*flow.AccountKey{tokenAccountKey},
		[]sdktemplates.Contract{
			{
				Name:   "ExampleNFT",
				Source: string(tokenCode),
			},
		},
	)
	assert.NoError(t, err)

	joshAccountKey, joshSigner := accountKeys.NewWithSigner()
	joshAddress, err := b.CreateAccount([]*flow.AccountKey{joshAccountKey}, nil)

	script := templates.GenerateMintNFTScript(nftAddress, tokenAddr)

	tx := flow.NewTransaction().
		SetScript(script).
		SetGasLimit(100).
		SetProposalKey(
			b.ServiceKey().Address,
			b.ServiceKey().Index,
			b.ServiceKey().SequenceNumber,
		).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(tokenAddr)

	tx.AddArgument(cadence.NewAddress(tokenAddr))
	tx.AddArgument(cadence.String("Example NFT 0"))
	tx.AddArgument(cadence.String("This is an example NFT"))
	tx.AddArgument(cadence.String("example.jpeg"))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{
			b.ServiceKey().Address,
			tokenAddr,
		},
		[]crypto.Signer{
			b.ServiceKey().Signer(),
			tokenSigner,
		},
		false,
	)

	// create a new Collection
	t.Run("Should be able to create a new empty NFT Collection", func(t *testing.T) {

		script := templates.GenerateSetupAccountScript(nftAddress, tokenAddr)
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

		script = templates.GenerateGetCollectionLengthScript(nftAddress, tokenAddr)
		length := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(joshAddress))})
		assert.Equal(t, cadence.NewInt(0), length)
	})

	t.Run("Shouldn't be able to withdraw an NFT that doesn't exist in a collection", func(t *testing.T) {

		script := templates.GenerateTransferNFTScript(nftAddress, tokenAddr)
		tx := createTxWithTemplateAndAuthorizer(b, script, tokenAddr)

		tx.AddArgument(cadence.NewAddress(joshAddress))
		tx.AddArgument(cadence.NewUInt64(3))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				tokenAddr,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				tokenSigner,
			},
			true,
		)

		script = templates.GenerateGetCollectionLengthScript(nftAddress, tokenAddr)
		length := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(joshAddress))})
		assert.Equal(t, cadence.NewInt(0), length)

		script = templates.GenerateGetCollectionLengthScript(nftAddress, tokenAddr)
		length = executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(tokenAddr))})
		assert.Equal(t, cadence.NewInt(1), length)
	})

	// transfer an NFT
	t.Run("Should be able to withdraw an NFT and deposit to another accounts collection", func(t *testing.T) {
		script := templates.GenerateTransferNFTScript(nftAddress, tokenAddr)
		tx := createTxWithTemplateAndAuthorizer(b, script, tokenAddr)

		tx.AddArgument(cadence.NewAddress(joshAddress))
		tx.AddArgument(cadence.NewUInt64(0))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				tokenAddr,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				tokenSigner,
			},
			false,
		)

		script = templates.GenerateBorrowNFTScript(nftAddress, tokenAddr)
		executeScriptAndCheck(
			t, b,
			script,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewAddress(joshAddress)),
				jsoncdc.MustEncode(cadence.NewUInt64(0)),
			},
		)

		script = templates.GenerateGetCollectionLengthScript(nftAddress, tokenAddr)
		length := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(joshAddress))})
		assert.Equal(t, cadence.NewInt(1), length)

		script = templates.GenerateGetCollectionLengthScript(nftAddress, tokenAddr)
		length = executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(tokenAddr))})
		assert.Equal(t, cadence.NewInt(0), length)
	})

	// transfer an NFT
	t.Run("Should be able to withdraw an NFT and destroy it, not reducing the supply", func(t *testing.T) {

		script := templates.GenerateDestroyNFTScript(nftAddress, tokenAddr)

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

		script = templates.GenerateGetCollectionLengthScript(nftAddress, tokenAddr)
		length := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(joshAddress))})
		assert.Equal(t, cadence.NewInt(0), length)

		script = templates.GenerateGetCollectionLengthScript(nftAddress, tokenAddr)
		length = executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.NewAddress(tokenAddr))})
		assert.Equal(t, cadence.NewInt(0), length)

		script = templates.GenerateGetTotalSupplyScript(nftAddress, tokenAddr)
		supply := executeScriptAndCheck(t, b, script, nil)
		assert.Equal(t, cadence.NewUInt64(1), supply)
	})
}
