module github.com/onflow/flow-nft/lib/go/test

go 1.14

require (
	github.com/onflow/cadence v0.20.2
	github.com/onflow/flow-emulator v0.27.2
	github.com/onflow/flow-go-sdk v0.24.0
	github.com/onflow/flow-nft/lib/go/contracts v0.0.0-20210915191154-12ee8c507a0e
	github.com/onflow/flow-nft/lib/go/templates v0.0.0-00010101000000-000000000000
	github.com/stretchr/testify v1.7.0
)

replace github.com/onflow/flow-nft/lib/go/contracts => ../contracts

replace github.com/onflow/flow-nft/lib/go/templates => ../templates
