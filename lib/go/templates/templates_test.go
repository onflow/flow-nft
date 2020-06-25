package templates_test

import (
	"testing"

	"github.com/onflow/flow-go-sdk"
	"github.com/stretchr/testify/assert"

	"github.com/onflow/flow-nft/lib/go/templates"
)

var addrA = flow.HexToAddress("0A")

func TestCreateCollection(t *testing.T) {
	template := templates.GenerateCreateCollectionScript("0A", "0B", "ExampleToken", "NFTCollection")
	assert.NotNil(t, template)
}
