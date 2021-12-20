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

	template := templates.GenerateSetupAccountScript(addressA, addressB)
	assert.NotNil(t, template)
}
