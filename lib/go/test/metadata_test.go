package main

import (
	"fmt"
	"path/filepath"
	"testing"

	. "github.com/bjartek/overflow"
	"github.com/stretchr/testify/require"
)

func TestSetupRoyaltyReceiver(t *testing.T) {

	path, err := filepath.Abs("../../..")
	fmt.Println(path)
	require.NoError(t, err)
	o, err := OverflowTesting(WithBasePath(path), WithFlowConfig(fmt.Sprintf("%s/flow.json", path)))
	require.NoError(t, err)

	o.Tx("setup_account",
		WithSigner("alice"),
	).AssertSuccess(t)

	o.Tx("setup_account_to_receive_royalty",
		WithSigner("alice"),
		WithArg("vaultPath", "/storage/missingVault"),
	).AssertFailure(t, "A vault for the specified fungible token path does not exist")

}
