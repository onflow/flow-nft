package contracts_test

import (
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/onflow/flow-go-sdk/test"

	"github.com/onflow/flow-nft/lib/go/contracts"
)

const addrA = "0A"

func TestNonFungibleTokenContract(t *testing.T) {
	contract := contracts.NonFungibleToken(addrA)
	assert.NotNil(t, contract)
}

func TestExampleNFTContract(t *testing.T) {
	addresses := test.AddressGenerator()
	addressA := addresses.New()
	addressB := addresses.New()
	addressC := addresses.New()

	contract := contracts.ExampleNFT(addressA, addressB, addressC)
	assert.NotNil(t, contract)

	assert.Contains(t, string(contract), addressA.String())
	assert.Contains(t, string(contract), addressB.String())
	assert.Contains(t, string(contract), addressC.String())
}

func TestMetadataViewsContract(t *testing.T) {
	contract := contracts.MetadataViews(addrA, addrA, addrA)
	assert.NotNil(t, contract)
}
