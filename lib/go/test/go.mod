module github.com/onflow/flow-nft/lib/go/test

go 1.16

require (
	github.com/onflow/cadence v0.28.0
	github.com/onflow/flow-emulator v0.38.1
	github.com/onflow/flow-go-sdk v0.29.0
	github.com/onflow/flow-nft/lib/go/contracts v0.0.0-20220727161549-d59b1e547ac4
	github.com/onflow/flow-nft/lib/go/templates v0.0.0-00010101000000-000000000000
	github.com/stretchr/testify v1.8.0
)

replace github.com/onflow/flow-nft/lib/go/contracts => ../contracts

replace github.com/onflow/flow-nft/lib/go/templates => ../templates
