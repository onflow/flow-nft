module github.com/onflow/flow-nft/lib/go/test

go 1.17

require (
	github.com/onflow/cadence v0.21.3-0.20220419065337-d5202c162010
	github.com/onflow/flow-emulator v0.31.2-0.20220422152808-6c116a9d88b7
	github.com/onflow/flow-go-sdk v0.24.1-0.20220421152843-9ce4d554036e
	github.com/onflow/flow-nft/lib/go/contracts v0.0.0-20210915191154-12ee8c507a0e
	github.com/onflow/flow-nft/lib/go/templates v0.0.0-00010101000000-000000000000
	github.com/stretchr/testify v1.7.1-0.20210824115523-ab6dc3262822
)

replace github.com/onflow/flow-nft/lib/go/contracts => ../contracts

replace github.com/onflow/flow-nft/lib/go/templates => ../templates
