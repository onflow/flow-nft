package contracts_test

import (
	"testing"

	"github.com/onflow/flow-go-sdk"
	"github.com/stretchr/testify/assert"

	"github.com/onflow/flow-nft/contracts"
)

var addrA = flow.HexToAddress("0A")

func TestNonFungibleTokenContract(t *testing.T) {
	contract := contracts.NonFungibleToken()
	assert.NotNil(t, contract)
}

func TestExampleNFTContract(t *testing.T) {
	contract := contracts.ExampleNFT(addrA.Hex())
	assert.NotNil(t, contract)
	assert.Contains(t, string(contract), addrA.Hex())
}
