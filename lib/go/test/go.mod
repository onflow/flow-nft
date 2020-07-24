module github.com/onflow/flow-nft/lib/go/test

go 1.14

require (
	github.com/dapperlabs/flow-emulator v0.6.0
	github.com/onflow/cadence v0.6.0
	github.com/onflow/flow v0.1.4-0.20200601215056-34a11def1d6b // indirect
	github.com/onflow/flow-go-sdk v0.8.0
	github.com/onflow/flow-nft/lib/go/contracts v0.0.0-00010101000000-000000000000
	github.com/onflow/flow-nft/lib/go/templates v0.0.0-00010101000000-000000000000
	github.com/stretchr/testify v1.6.1
	github.com/vektra/mockery v1.1.2 // indirect
	github.com/zenazn/goji v0.9.0 // indirect
)

replace github.com/onflow/flow-nft/lib/go/contracts => ../contracts

replace github.com/onflow/flow-nft/lib/go/templates => ../templates
