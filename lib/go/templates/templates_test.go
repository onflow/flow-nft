package templates_test

import (
	"testing"

	"github.com/onflow/flow-go-sdk/test"
	"github.com/stretchr/testify/assert"

	"github.com/onflow/flow-nft/lib/go/templates"
)

func TestGenerateSetupAccountScript(t *testing.T) {
	addresses := test.AddressGenerator()
	addressA := addresses.New()
	addressB := addresses.New()
	addressC := addresses.New()

	template := templates.GenerateSetupAccountScript(addressA, addressB, addressC)
	assert.NotNil(t, template)
}
