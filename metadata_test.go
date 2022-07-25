package main

import (
	"encoding/json"
	"testing"

	. "github.com/bjartek/overflow"
	"github.com/onflow/cadence"
	"github.com/stretchr/testify/assert"
)

func TestSetupRoyaltyReceiver(t *testing.T) {

	o, err := OverflowTesting()
	assert.NoError(t, err)

	setupRoyalty := o.TxFileNameFN("setup_account_to_receive_royalty")
	setupAccount := o.TxFileNameFN("setup_account")

	t.Run("Should not be able to setup a royalty receiver for a vault that doesn't exist", func(t *testing.T) {
		setupAccount(WithSigner("alice")).AssertSuccess(t)
		setupRoyalty(WithSigner("alice"), WithArg("vaultPath", "/storage/missingVault")).
			AssertFailure(t, "A vault for the specified fungible token path does not exist")
	})
}

func TestGetNFTMetadata(t *testing.T) {
	o, err := OverflowTesting()
	assert.NoError(t, err)

	setupAccount := o.TxFileNameFN("setup_account")
	setupFlowRoyalty := o.TxFileNameFN("setup_account_to_receive_royalty", WithArg("vaultPath", "/storage/flowTokenVault"))
	setupAccount(WithSigner("alice")).AssertSuccess(t)
	setupFlowRoyalty(WithSigner("alice")).AssertSuccess(t)

	setupAccount(WithSigner("bob")).AssertSuccess(t)
	setupFlowRoyalty(WithSigner("bob")).AssertSuccess(t)

	mintNft := o.TxFileNameFN("mint_nft", WithSignerServiceAccount(),
		WithArg("name", "Example NFT 0"),
		WithArg("description", "This is an example NFT"),
		WithArg("thumbnail", "example.jpeg"),
		WithArg("cuts", "[0.25, 0.40]"),
		WithArg("royaltyDescriptions", `["minter","creator"]`),
		WithAddresses("royaltyBeneficiaries", "alice", "bob"))

	id, err := mintNft(WithArg("recipient", "alice")).AssertSuccess(t).GetIdFromEvent("A.f8d6e0586b0a20c7.ExampleNFT.Deposit", "id")
	assert.NoError(t, err)

	t.Run("Should be able to verify the metadata of the minted NFT through the Display View", func(t *testing.T) {

		var metadata Metadata
		err := o.Script("get_nft_metadata", WithArg("address", "alice"), WithArg("id", id)).MarshalAs(&metadata)
		assert.NoError(t, err)

		//Here we could just assert on the values of the return type aswell if we want to
		for id, trait := range metadata.Traits.Traits {
			if trait.Name == "mintedTime" {
				metadata.Traits.Traits[id].Value = "mock_time"
			}
		}
		data, err := json.MarshalIndent(metadata, "", " ")
		assert.NoError(t, err)

		expectedMetadata := `
{
  "collectionBannerImage": "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg",
  "collectionDescription": "This collection is used as an example to help you develop your next Flow NFT.",
  "collectionExternalURL": "https://example-nft.onflow.org",
  "collectionName": "The Example Collection",
  "collectionProviderLinkedType": "\u0026A.f8d6e0586b0a20c7.ExampleNFT.Collection{A.f8d6e0586b0a20c7.ExampleNFT.ExampleNFTCollectionPublic,A.f8d6e0586b0a20c7.NonFungibleToken.CollectionPublic,A.f8d6e0586b0a20c7.NonFungibleToken.Provider,A.f8d6e0586b0a20c7.MetadataViews.ResolverCollection}",
  "collectionProviderPath": "/private/exampleNFTCollection",
  "collectionPublic": "\u0026A.f8d6e0586b0a20c7.ExampleNFT.Collection{A.f8d6e0586b0a20c7.ExampleNFT.ExampleNFTCollectionPublic}",
  "collectionPublicLinkedType": "\u0026A.f8d6e0586b0a20c7.ExampleNFT.Collection{A.f8d6e0586b0a20c7.ExampleNFT.ExampleNFTCollectionPublic,A.f8d6e0586b0a20c7.NonFungibleToken.CollectionPublic,A.f8d6e0586b0a20c7.NonFungibleToken.Receiver,A.f8d6e0586b0a20c7.MetadataViews.ResolverCollection}",
  "collectionPublicPath": "/public/exampleNFTCollection",
  "collectionSocials": {
   "twitter": "https://twitter.com/flow_blockchain"
  },
  "collectionSquareImage": "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg",
  "collectionStoragePath": "/storage/exampleNFTCollection",
  "description": "This is an example NFT",
  "edition": {
   "name": "Example NFT Edition",
   "number": 0
  },
  "externalURL": "https://example-nft.onflow.org/0",
  "name": "Example NFT 0",
  "owner": "0x01cf0e2f2f715450",
  "royalties": [
   {
    "cut": 0.25,
    "description": "minter",
    "receiver": "Capability\u003c\u0026AnyResource{A.ee82856bf20e2aa6.FungibleToken.Receiver}\u003e(address: 0x01cf0e2f2f715450, path: /public/GenericFTReceiver)"
   },
   {
    "cut": 0.4,
    "description": "creator",
    "receiver": "Capability\u003c\u0026AnyResource{A.ee82856bf20e2aa6.FungibleToken.Receiver}\u003e(address: 0x179b6b1cb6755e31, path: /public/GenericFTReceiver)"
   }
  ],
  "serialNumber": 0,
  "thumbnail": "example.jpeg",
  "traits": {
   "traits": [
    {
     "name": "minter",
     "value": "0x01cf0e2f2f715450",
     "rarity": {
      "description": "",
      "max": 0,
      "score": 0
     }
    },
    {
     "name": "mintedBlock",
     "value": 12,
     "rarity": {
      "description": "",
      "max": 0,
      "score": 0
     }
    },
    {
     "name": "mintedTime",
     "value": "mock_time",
     "displayType": "Date",
     "rarity": {
      "description": "",
      "max": 0,
      "score": 0
     }
    },
    {
     "name": "foo",
     "value": "bar",
     "rarity": {
      "description": "Common",
      "max": 100,
      "score": 10
     }
    }
   ]
  },
  "type": "A.f8d6e0586b0a20c7.ExampleNFT.NFT"
 }`
		assert.JSONEq(t, expectedMetadata, string(data))
	})
}

func TestSetupCollectionFromNFTReference(t *testing.T) {
	o, err := OverflowTesting()
	assert.NoError(t, err)

	setupAccount := o.TxFileNameFN("setup_account")
	setupFlowRoyalty := o.TxFileNameFN("setup_account_to_receive_royalty", WithArg("vaultPath", "/storage/flowTokenVault"))
	setupAccount(WithSigner("alice")).AssertSuccess(t)
	setupFlowRoyalty(WithSigner("alice")).AssertSuccess(t)

	mintNft := o.TxFileNameFN("mint_nft", WithSignerServiceAccount(),
		WithArg("name", "Example NFT 0"),
		WithArg("description", "This is an example NFT"),
		WithArg("thumbnail", "example.jpeg"),
		WithArg("cuts", "[0.25, 0.40]"),
		WithArg("royaltyDescriptions", `["minter","creator"]`),
		WithAddresses("royaltyBeneficiaries", "alice", "alice"))

	id, err := mintNft(WithArg("recipient", "alice")).AssertSuccess(t).GetIdFromEvent("A.f8d6e0586b0a20c7.ExampleNFT.Deposit", "id")
	assert.NoError(t, err)

	t.Run("Should be able to setup an account using the NFTCollectionData metadata view of a referenced NFT", func(t *testing.T) {

		o.Tx("setup_account_from_nft_reference",
			WithSigner("bob"),
			WithArg("address", "alice"),
			WithArg("publicPath", cadence.Path{Domain: "public", Identifier: "exampleNFTCollection"}),
			WithArg("id", id),
		).AssertSuccess(t)
	})

}

type Metadata struct {
	CollectionBannerImage        string `json:"collectionBannerImage"`
	CollectionDescription        string `json:"collectionDescription"`
	CollectionExternalURL        string `json:"collectionExternalURL"`
	CollectionName               string `json:"collectionName"`
	CollectionProviderLinkedType string `json:"collectionProviderLinkedType"`
	CollectionProviderPath       string `json:"collectionProviderPath"`
	CollectionPublic             string `json:"collectionPublic"`
	CollectionPublicLinkedType   string `json:"collectionPublicLinkedType"`
	CollectionPublicPath         string `json:"collectionPublicPath"`
	CollectionSocials            struct {
		Twitter string `json:"twitter"`
	} `json:"collectionSocials"`
	CollectionSquareImage string `json:"collectionSquareImage"`
	CollectionStoragePath string `json:"collectionStoragePath"`
	Description           string `json:"description"`
	Edition               struct {
		Name   string `json:"name"`
		Number int    `json:"number"`
	} `json:"edition"`
	ExternalURL string `json:"externalURL"`
	Name        string `json:"name"`
	Owner       string `json:"owner"`
	Royalties   []struct {
		Cut         float64 `json:"cut"`
		Description string  `json:"description"`
		Receiver    string  `json:"receiver"`
	} `json:"royalties"`
	SerialNumber int    `json:"serialNumber"`
	Thumbnail    string `json:"thumbnail"`
	Traits       struct {
		Traits []struct {
			Name        string      `json:"name"`
			Value       interface{} `json:"value"`
			DisplayType string      `json:"displayType,omitempty"`
			Rarity      struct {
				Description string `json:"description"`
				Max         int    `json:"max"`
				Score       int    `json:"score"`
			} `json:"rarity,omitempty"`
		} `json:"traits"`
	} `json:"traits"`
	Type string `json:"type"`
}
