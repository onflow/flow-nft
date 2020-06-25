module github.com/onflow/flow-nft/lib/go/test

go 1.14

require (
	github.com/dapperlabs/flow-emulator v0.4.0
	github.com/onflow/cadence v0.4.0
	github.com/onflow/flow-go-sdk v0.4.1
	github.com/onflow/flow-nft/lib/go/contracts v0.0.0-00010101000000-000000000000
	github.com/onflow/flow-nft/lib/go/templates v0.0.0-00010101000000-000000000000
	github.com/onflow/flow/protobuf/go/flow v0.1.5-0.20200611205353-548107cc9aca // indirect
	github.com/stretchr/testify v1.5.1
)

replace github.com/onflow/flow-nft/lib/go/contracts => ../contracts
replace github.com/onflow/flow-nft/lib/go/templates => ../templates
