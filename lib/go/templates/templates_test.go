package templates_test

import (
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/onflow/flow-nft/lib/go/templates"
)

func TestCreateCollection(t *testing.T) {
	template := templates.GenerateCreateCollectionScript("0A", "0B", "ExampleToken", "NFTCollection")
	assert.NotNil(t, template)
}
