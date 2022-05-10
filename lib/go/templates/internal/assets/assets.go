// Code generated by go-bindata. DO NOT EDIT.
// sources:
// ../../../transactions/destroy_nft.cdc (509B)
// ../../../transactions/mint_nft.cdc (2.637kB)
// ../../../transactions/scripts/borrow_nft.cdc (581B)
// ../../../transactions/scripts/get_collection_length.cdc (465B)
// ../../../transactions/scripts/get_nft_metadata.cdc (4.573kB)
// ../../../transactions/scripts/get_total_supply.cdc (118B)
// ../../../transactions/setup_account.cdc (928B)
// ../../../transactions/setup_account_from_nft_reference.cdc (1.42kB)
// ../../../transactions/setup_account_to_receive_royalty.cdc (1.484kB)
// ../../../transactions/transfer_nft.cdc (1.179kB)

package assets

import (
	"bytes"
	"compress/gzip"
	"crypto/sha256"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
	"time"
)

func bindataRead(data, name string) ([]byte, error) {
	gz, err := gzip.NewReader(strings.NewReader(data))
	if err != nil {
		return nil, fmt.Errorf("read %q: %w", name, err)
	}

	var buf bytes.Buffer
	_, err = io.Copy(&buf, gz)

	if err != nil {
		return nil, fmt.Errorf("read %q: %w", name, err)
	}

	clErr := gz.Close()
	if clErr != nil {
		return nil, clErr
	}

	return buf.Bytes(), nil
}

type asset struct {
	bytes  []byte
	info   os.FileInfo
	digest [sha256.Size]byte
}

type bindataFileInfo struct {
	name    string
	size    int64
	mode    os.FileMode
	modTime time.Time
}

func (fi bindataFileInfo) Name() string {
	return fi.name
}
func (fi bindataFileInfo) Size() int64 {
	return fi.size
}
func (fi bindataFileInfo) Mode() os.FileMode {
	return fi.mode
}
func (fi bindataFileInfo) ModTime() time.Time {
	return fi.modTime
}
func (fi bindataFileInfo) IsDir() bool {
	return false
}
func (fi bindataFileInfo) Sys() interface{} {
	return nil
}

var _destroy_nftCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x6c\x90\x41\x6f\xe2\x40\x0c\x85\xef\xf9\x15\x4f\x39\xec\x86\xc3\x26\x97\xd5\x1e\x22\xb6\x08\xd1\x22\x71\x41\x55\x4b\x7f\xc0\x30\x71\xc8\xa8\xc1\x8e\x1c\x47\x69\x55\xf1\xdf\xab\x40\x49\xa1\xc2\xa7\xd1\xf8\x7d\xef\xd9\x0e\xfb\x46\xd4\xb0\x16\x5e\x76\xbc\x0b\xdb\x9a\x36\xf2\x4a\x8c\x52\x65\x8f\x38\x4d\x33\x2f\x6c\xea\xbc\xb5\xd9\x4f\x4d\xea\x0b\x1f\x47\x5f\x06\x0f\x6f\x6e\xdf\xd4\xb4\x5e\x6e\x6e\xa1\xdf\xdd\x13\x14\x99\x3a\x6e\x9d\xb7\x20\x9c\x84\x22\xc7\xcb\x8a\xed\xdf\xdf\x09\x3e\x22\x00\x68\x94\x1a\xa7\x94\xb4\x61\xc7\xa4\x39\xe6\x9d\x55\x73\xef\xa5\x63\x3b\x4b\x86\xaa\xc9\xe0\xa5\xae\xe9\xe8\xf3\x44\x25\xfe\xe3\x84\xa4\x5b\x51\x95\x7e\xfa\xeb\x22\x78\x31\x2a\xef\x92\x61\xc4\x1c\x37\x9b\xcf\x26\xea\x76\xf4\xe8\xac\x9a\x8c\x49\x43\xcd\x66\x68\x1c\x07\x9f\xc4\x0b\xe9\xea\x02\x2c\x86\x53\x0c\x1c\x94\x4a\x52\x62\x4f\x30\x81\x55\x04\xe9\x99\xf4\x77\x7b\x31\x5f\x3c\x89\x46\xbf\x2c\x43\x1f\xac\x2a\xd4\xf5\x47\xf5\x78\xb6\xdb\xe8\xd5\xc6\x5c\x1a\xa6\x7f\xae\x17\x4f\xcf\x6e\xc9\xf9\xb1\xba\xcf\x11\x8a\x8b\xc8\x82\x5a\x53\x79\x1f\xf0\xe3\xdf\x21\x3a\x44\x9f\x01\x00\x00\xff\xff\xbd\x0b\x03\xcd\xfd\x01\x00\x00"

func destroy_nftCdcBytes() ([]byte, error) {
	return bindataRead(
		_destroy_nftCdc,
		"destroy_nft.cdc",
	)
}

func destroy_nftCdc() (*asset, error) {
	bytes, err := destroy_nftCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "destroy_nft.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0x24, 0x4f, 0x57, 0xb2, 0xc6, 0x27, 0xe0, 0x9e, 0xca, 0x4e, 0x50, 0xc7, 0xe3, 0xd1, 0xd3, 0xb1, 0x36, 0xe8, 0x38, 0x59, 0xb7, 0x69, 0x24, 0x74, 0x82, 0x70, 0x76, 0x1a, 0x11, 0x9c, 0xeb, 0x86}}
	return a, nil
}

var _mint_nftCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x84\x56\x4b\x6f\xe3\x36\x10\xbe\xeb\x57\xcc\xfa\x90\xca\xe8\x42\x6a\x81\xa2\x07\x63\x9d\x45\x92\xd6\x40\x0f\x09\x16\xbb\x6e\x2f\x81\x0f\x14\x35\x96\x88\xd0\xa4\x4a\x8e\xe2\x18\x86\xff\x7b\x41\x51\x2f\x7a\xb9\xa9\x0e\x7e\x90\xdf\x0c\xe7\xf1\xcd\x27\x8a\x43\xa3\x0d\xc1\x93\x56\x9b\x56\x55\xa2\x90\xb8\xd5\x2f\xa8\x60\x6f\xf4\x01\x16\x59\x96\x73\xad\xc8\x30\x4e\x36\xbf\xc6\x64\xbc\xe4\x8b\xa4\x77\xf0\xe7\x1b\x3b\x34\x12\x9f\x36\xdb\x98\xe9\xb4\x1b\x18\x3d\x22\xb1\x92\x11\xfb\x47\xe0\xd1\xc6\xec\x02\x40\x60\x1a\x8d\x36\x6f\x49\x48\x41\xa7\x3c\x12\x67\x92\xe7\xb0\xad\x85\x05\xcb\x8d\x68\x08\x5a\x8b\x16\xa8\x46\x78\xda\x6c\x1f\x85\x22\x34\x60\xd0\xea\xd6\x70\x04\xd2\x70\x10\x8a\x80\x81\xc2\xa3\x03\x38\xe3\xbf\x08\x0e\xad\x25\x28\x10\x4c\xab\xe0\x28\xa8\xee\xec\x19\xe7\xba\x55\x04\x54\x33\x82\x9a\x79\xa7\x87\xd0\xa3\xb3\xb7\xa4\x0d\x96\x20\x14\xe4\xee\x27\xab\x30\x1f\x8f\x4e\x12\x32\x4c\x59\xc6\x49\x68\x95\x26\x00\x00\x06\xb9\x68\x04\x2a\x5a\xc1\x5d\x59\x1a\xb4\xf6\x63\xb7\xae\xd8\x01\x57\xf0\x8d\x8c\x50\x95\x5f\x29\xd1\xa7\x24\xb4\x0a\x37\xa8\x6e\x0f\x85\x62\x42\x86\xcb\xbc\x25\xbb\x82\xe7\xbf\x37\xe2\xed\xf7\xdf\x76\x7e\xcd\xe8\x13\x93\x74\xfa\x63\x72\xe5\x20\xde\x2a\x84\xdc\xa3\xc2\xbd\xe0\x82\x19\x81\x0e\xd3\x07\xb7\x83\x64\x09\xe7\xa4\x43\xe6\x39\x48\xcd\x99\x84\x57\x66\x04\x2b\x24\xc2\x5e\x9b\x2e\x7f\xa1\xaa\xb0\x3c\x7b\x34\xa8\x38\x76\x66\x12\xa9\xdf\x58\xc1\xcd\x8c\x31\xb3\x2a\x0d\x30\x1f\x8b\x0f\x20\xe4\xc8\x57\x1f\xe5\x2e\xf1\xe0\xc6\x60\xc3\x0c\xa6\x56\x54\xca\xf9\xbd\x6b\xa9\xbe\xf3\x0d\x73\xe1\x42\xff\xe4\x39\x14\xda\x18\x7d\x04\x36\x05\xe5\x68\xf0\x03\x82\x08\x05\x7d\x0f\x47\x17\x16\xe5\x3e\xeb\xf3\x5a\x83\x3f\x2f\xf3\x4e\x3f\x45\xb3\xb9\x4d\x1d\x6b\x57\xb3\xc9\xc9\xfc\xc6\x37\xef\xf9\x0b\xa3\x7a\x39\xba\x77\xcf\xe7\xcf\xd0\x30\x25\x78\xba\x78\xd0\xad\x2c\x41\x69\x7a\x3f\xec\xbe\x9c\x8b\xc9\xcd\x3c\x63\x6e\x90\xd1\xd0\x91\xbe\xbb\x50\x22\x31\x21\xed\x88\x7b\x65\x06\x3c\xbf\xd7\xf0\x4b\x98\xec\xd8\x04\x58\xc3\xf3\x6e\xdc\x3b\xd6\x42\x62\x94\x2d\x99\x44\x55\x51\x0d\xb7\xbd\xc7\x73\x90\x9d\xeb\x6b\x31\xc2\x4f\xb0\x8e\xfa\x78\xee\x4c\x77\xef\x59\x3e\xb0\x86\x15\x9d\x0e\xc0\x1a\x2a\xa4\xbe\xdf\xe9\x0c\x12\xd6\x35\xab\x90\x26\xa3\x4f\x37\xe7\x50\x3e\xbe\x22\x47\xf1\x8a\xe6\x72\x9b\x86\x5c\xab\x90\x7a\xba\x0d\x90\x2f\x6d\x21\x05\x77\x9d\x4b\x97\xcb\x24\x38\x24\xcf\xe1\x91\xbd\x20\xd8\xd6\x60\x50\x71\x3e\x85\x2b\x2c\xbc\x32\x29\x4a\x28\x70\xaf\x8d\x1f\x93\xa1\x41\x4e\x85\xe6\xfe\xc4\x1e\x3e\x44\x93\xce\x78\x8d\xfc\x25\x5d\xc2\x79\x60\xcb\xfd\xac\xaa\xe1\x69\x8e\x41\xdd\x89\x1f\x16\x4b\xb8\x84\x01\x87\x3d\xce\x58\xd3\xa0\x2a\xd3\x00\xe2\x9e\xe8\xf8\x7d\x0f\x03\x2f\x69\x5d\x95\x56\xf1\x6e\x7d\x8c\x1a\xf1\x96\x56\x9d\x64\xf5\x9d\x8f\xa3\x02\x0d\x8c\x88\x59\x8c\x36\xee\x09\x89\x10\xfe\x1b\x68\xef\xbf\x7f\x86\x5f\xc7\xdd\x4b\xe2\x3f\x07\x89\x99\x31\xd9\x45\x3a\xf0\x7c\xbd\x8e\x85\x32\xec\xde\xdc\xfc\x00\x1c\x9b\x99\x15\x2c\xee\x8c\x61\x27\xe8\xd1\xb6\xee\x14\xa0\x40\xc0\x7f\x5b\x26\x3b\x81\x1d\x08\x65\x50\x32\xc2\x72\x18\xe5\xc5\x3c\x58\x7c\x43\xde\x12\x0e\x4a\x0d\x9e\x98\xf7\x5e\x44\x3a\x56\x0e\xaf\x9d\x9f\x2c\x34\x1d\x9b\x3b\x21\xe1\x5a\x4a\xec\xde\x4e\x57\xa2\x0d\x83\x22\xf7\xbd\x0d\x47\x6e\xf4\xf6\xde\xc0\xa5\x33\x05\x7c\x18\xcf\x99\x46\xe9\xca\x76\xd0\xd4\xf3\x77\xf7\x91\x6b\xe3\xcb\x6d\xfa\xff\x02\x5a\xcd\x83\x8f\x8a\xe8\xe4\x76\xb1\x0c\xca\xe6\xe4\x7a\x44\x31\xe5\x2a\xde\x68\x2b\x08\x04\x0d\xf6\xf3\x72\x4e\x35\x8c\xbd\x34\xba\xaf\xa7\xcd\x36\x1c\x9d\xd9\x2d\x60\x08\x32\x1c\x00\x7f\x1d\x70\x9f\xe1\x7a\x30\x10\xb3\x3f\x21\x6a\x76\x43\x18\x7f\x86\x88\xd9\x9b\x36\x14\x84\x24\x1c\x9a\x4b\x72\x49\xe0\xbf\x00\x00\x00\xff\xff\xa2\x1f\x14\xcb\x4d\x0a\x00\x00"

func mint_nftCdcBytes() ([]byte, error) {
	return bindataRead(
		_mint_nftCdc,
		"mint_nft.cdc",
	)
}

func mint_nftCdc() (*asset, error) {
	bytes, err := mint_nftCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "mint_nft.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0x5e, 0x32, 0xda, 0x65, 0xc3, 0x68, 0xb7, 0x49, 0x1b, 0x7a, 0x22, 0x99, 0x94, 0x8f, 0xcd, 0x6b, 0xc7, 0x64, 0x83, 0xfe, 0x40, 0x9b, 0xd0, 0xda, 0x12, 0xa0, 0xc7, 0x77, 0xd9, 0x8a, 0x66, 0xc6}}
	return a, nil
}

var _scriptsBorrow_nftCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x74\x90\x41\x6b\xe3\x30\x10\x85\xef\xfe\x15\x0f\x1f\x16\x1b\x16\xfb\xb2\xec\x21\x34\x0d\x69\x68\xa0\x97\x10\x8a\x7b\x2e\xf2\x78\x9c\x0c\x95\x25\x21\xcb\xb4\x25\xe4\xbf\x97\xc4\xb1\x9d\xa6\x54\x27\x09\xbd\x6f\xa4\xf7\x49\xe3\xac\x0f\xd8\x58\xb3\xee\xcc\x4e\x4a\xcd\x85\x7d\x63\x83\xda\xdb\x06\x71\x96\xe5\x59\x96\x93\x35\xc1\x2b\x0a\x6d\x7e\x1b\xcb\xa8\xa2\x38\xba\xcc\x78\xfc\x50\x8d\xd3\xbc\x59\x17\xbf\xd0\x53\xa0\xe7\xa2\x3c\x47\xb1\x97\x16\x2d\x79\x71\x01\xa5\xf5\xde\xbe\xb7\x50\x06\xe3\x10\x05\xb2\x5a\x33\x05\xb1\x26\x72\x5d\x89\xba\x33\x68\x94\x98\x44\x55\x95\xe7\xb6\x9d\x61\xd9\x6f\xfe\x42\xaa\x19\x5e\x9e\x4c\xf8\xff\x2f\xc5\x21\x02\x00\xcd\x01\x8a\xc8\x76\x26\x60\x8e\x1d\x87\x65\x7f\x18\xe0\x34\x1a\x63\xd3\x33\xcf\x5c\x63\x3e\x60\xe7\xfb\xd3\xca\x76\x1c\x56\xca\xa9\x52\xb4\x84\xcf\xe4\xaa\xcb\x6a\x24\xb7\x5d\xa9\x85\xb6\x2a\xec\xd3\x89\xeb\x5b\xdd\xfd\x39\xfc\x90\x77\x0b\x1e\xef\x93\x89\x5b\x2c\xe0\x94\x11\x4a\xe2\x95\xed\x74\x05\x63\x07\x41\xa0\xf1\x1b\xbd\x23\x77\xa6\xaf\x1a\xc4\x97\x5e\x79\x8e\x87\x1e\x51\xf0\x5c\xb3\x67\x43\x8c\x60\xa1\xd0\x3a\x26\xa9\x85\xce\xa6\xc5\x20\xec\xf9\xda\xf4\x60\xe5\x15\xf3\xef\x66\x2e\x75\x36\xeb\x22\x39\xe9\x96\x2a\x8d\x8e\xd1\x57\x00\x00\x00\xff\xff\x42\x5e\x85\x9f\x45\x02\x00\x00"

func scriptsBorrow_nftCdcBytes() ([]byte, error) {
	return bindataRead(
		_scriptsBorrow_nftCdc,
		"scripts/borrow_nft.cdc",
	)
}

func scriptsBorrow_nftCdc() (*asset, error) {
	bytes, err := scriptsBorrow_nftCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "scripts/borrow_nft.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0x6e, 0x35, 0x85, 0x35, 0xa5, 0x35, 0x7c, 0x4e, 0xec, 0x2f, 0xd1, 0x85, 0x20, 0x1, 0xe5, 0x41, 0x36, 0x46, 0x72, 0xa9, 0x90, 0x9b, 0x8e, 0xae, 0x8b, 0x7, 0x11, 0x8c, 0xbe, 0x9f, 0xe5, 0xe6}}
	return a, nil
}

var _scriptsGet_collection_lengthCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x74\x90\xc1\x6a\xc3\x30\x10\x44\xef\xfa\x8a\xc5\x87\x62\x5f\xe4\x7b\x68\x1a\x82\xdb\x40\x2e\x21\x94\xfc\x80\x2c\xcb\x8e\xa8\xbc\x2b\xe4\x15\x6d\x09\xf9\xf7\x12\xab\xb1\xd3\x94\xe8\x20\x24\x76\xde\xb0\x33\xb6\xf7\x14\x18\x76\x84\x9b\x88\x9d\xad\x9d\x39\xd0\x87\x41\x68\x03\xf5\x90\x49\x59\x4a\x59\x6a\x42\x0e\x4a\xf3\x50\xde\xcb\xa4\x6e\x74\x26\x7e\x3d\xde\xbe\x54\xef\x9d\xd9\x6d\x0e\x0f\xe8\x59\x90\x38\xe1\x63\x0d\x6d\x44\xe8\x95\xc5\x5c\x35\x4d\x30\xc3\xb0\x80\x75\x7a\x14\x0b\xd8\x22\xc3\x49\x00\x00\x38\xc3\xa0\xb4\xa6\x88\x0c\x4b\xe8\x0c\xaf\xd3\xe7\x4a\x15\x62\x92\x69\x72\xce\x68\xb6\x84\xef\xa6\x85\xe5\x15\x1b\xe7\x97\x23\x3b\xc3\x95\xf2\xaa\xb6\xce\xf2\x77\x7e\xb3\x54\x35\x91\xfb\x58\x3b\xab\xf7\x8a\x8f\xc5\xcc\xd5\x14\x02\x7d\x3e\x3f\x9d\xfe\xb5\x70\x0f\x9e\x5f\xf2\x99\x5b\xad\xc0\x2b\xb4\x3a\xcf\x2a\x8a\xae\x01\x24\x86\x64\x05\x7a\x5a\x23\x35\xe6\x47\xfa\x26\x41\x96\x6c\xc6\x2b\x18\x8e\x01\xff\xc6\xbb\x64\xd9\xbe\x0e\x79\x21\x9d\xc1\x8e\x8f\xe2\x2c\x7e\x02\x00\x00\xff\xff\xaa\x92\x4e\x73\xd1\x01\x00\x00"

func scriptsGet_collection_lengthCdcBytes() ([]byte, error) {
	return bindataRead(
		_scriptsGet_collection_lengthCdc,
		"scripts/get_collection_length.cdc",
	)
}

func scriptsGet_collection_lengthCdc() (*asset, error) {
	bytes, err := scriptsGet_collection_lengthCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "scripts/get_collection_length.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0xc0, 0x89, 0xcd, 0xef, 0x5d, 0x12, 0xb7, 0x51, 0x37, 0xc7, 0x80, 0x78, 0xf2, 0x33, 0x27, 0xa0, 0x48, 0xa5, 0xb7, 0x52, 0x63, 0x43, 0xcd, 0x14, 0xbe, 0x1b, 0x93, 0xd9, 0x22, 0x5f, 0x57, 0x8f}}
	return a, nil
}

var _scriptsGet_nft_metadataCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x94\x57\xc1\x6e\xe3\x36\x10\xbd\xfb\x2b\x26\x39\x14\x32\x50\xc8\x97\xa2\x07\x63\xb5\x8b\x6d\x92\x16\x0b\x6c\x83\x45\x92\xdd\x4b\xd1\x03\x2d\x8d\x1c\xa2\x32\xa9\x52\x23\x27\x46\x90\x7f\x2f\x24\xca\x22\x69\x0d\x6d\xd5\x97\x48\x9c\xf7\x66\x86\xe4\x23\xf5\x22\x77\xb5\x36\x04\x77\xaf\x62\x57\x57\x78\xff\xfb\x13\x94\x46\xef\xe0\x3a\x4d\x57\x69\xba\xca\xb5\x22\x23\x72\x6a\x56\x0e\x90\xe6\x45\x7e\xbd\x18\x78\x7f\x22\x89\x42\x90\xf8\x21\xf1\xa5\x89\x50\x03\x8c\x65\x2f\xea\x76\x03\x0d\x99\x36\x27\xe8\x6a\xbe\x2d\x00\x00\xba\xc1\x0a\x09\x94\xd8\xe1\x1a\x1e\xc9\x48\xb5\x0d\x02\x05\x36\xb9\x91\x35\x49\xad\xd8\x38\x3d\xb7\xbb\x8d\x12\xb2\x62\xa3\xfa\x45\xa1\x59\xc3\xe7\xa2\x30\xd8\x34\x21\xf1\x50\xf3\x15\x8d\x3e\x88\x8a\x24\x36\x6b\xf8\x2b\x9c\xc7\x43\x1f\x39\xfc\x1d\xc0\xf1\x95\xd0\x28\x51\x7d\x7f\xf8\xca\xa6\xcb\x75\x55\x61\xde\xf5\xff\xad\xdd\x54\x32\xff\x26\xe8\x79\x0d\xee\x39\x02\x7e\x24\x6d\xc4\x16\x2d\xda\x7b\x89\xe5\x36\x7a\x2f\x0b\x34\x43\x76\x23\xf7\x82\xce\xe2\xfb\xfa\xb3\x1a\xfe\x2a\xd5\x3f\x58\x3c\xc5\x96\x6b\xda\xc3\x6c\xc2\x7d\x6c\xd3\x1d\xe4\xf6\xc2\xf6\x3b\xe4\xdd\xec\x7d\x78\xfc\xb7\x15\x06\xbf\xec\xc4\xf6\x52\xf5\xdf\x84\x52\x68\x42\x64\x0f\x95\x4a\x52\xd2\x3f\x75\x3f\x5f\xbc\x3f\x8f\xa3\x8c\x72\x5d\x70\x22\x5b\x17\x0a\x35\xeb\xc6\x55\x49\xfe\x9a\xba\xc0\x65\xc1\x3a\x2c\xa3\x56\x17\xbc\x24\x55\x0e\x19\xd3\x29\x9b\x35\x26\xd2\x78\x0b\x97\x9b\x9c\xaa\xed\x5c\xe9\x79\xe8\x7b\x76\x43\xcf\xaa\x92\x83\x31\x92\x64\x97\x70\xaa\x47\x0e\xc6\x89\xb1\x43\x2c\x87\xab\xb4\xfb\x35\x58\x95\x69\x27\x47\xc8\x7a\x55\x86\x01\x4f\x91\x90\xf9\xfa\x0c\x61\xa3\x36\x21\x73\x3a\x0d\x21\xbd\x46\x21\xb3\x5a\x3d\x61\x1f\xea\xbe\xba\x55\x6b\x18\x1b\x95\x0a\x99\x53\x6d\x08\xf1\x04\x0a\x99\x2f\xd7\x10\xc6\x49\x15\x32\x56\xc1\x31\xa2\x27\xd6\x80\x79\x7a\xd9\x72\x35\x3d\x21\x87\x55\xbd\xc0\xf9\x86\x99\x66\xcf\x13\x9c\x72\x19\xaa\x0b\x5e\x6a\x39\x96\x66\x12\x8e\x25\xba\xb7\xea\x0a\x07\x62\xe0\xdb\x40\x71\xec\x78\x8c\x7a\x17\x08\x81\x1d\x8f\xee\xac\x3b\x50\xe1\xce\xba\xf1\x18\xd5\x3b\x64\x01\xd5\x1b\xef\xa9\xef\x8b\x77\xeb\x68\xca\x56\xc1\x4e\x48\x95\x08\x7b\x5f\xbb\x8b\x1b\x64\xb1\x86\xef\x5f\x14\xfd\xfa\xcb\x72\xed\x59\x9e\xee\x13\x23\xf2\x5c\xb7\x8a\x20\x83\x2d\xd2\x67\xfb\x72\xcc\xb0\x5c\x8c\x30\x57\x1f\xb2\x23\x67\xec\x3c\xdd\x22\xdd\x88\x5a\x6c\x64\x25\xe9\x90\x78\x6e\xed\x86\x39\x05\x4b\xc7\xdb\x68\x63\xf4\xcb\x87\x9f\xde\x3c\x8a\x7b\x3c\x25\xbf\x7f\x4c\x1c\xf7\xd3\x27\xa8\x85\x92\x79\x72\x7d\xa3\xdb\xaa\x00\xa5\x09\x6c\x3a\x10\x60\xb0\x44\x83\x2a\x47\x20\x0d\xf4\x8c\x5e\xfb\xd7\xde\xa4\x54\x49\xc1\xd2\x0e\xfd\xb8\x0e\x92\x6e\xe1\x64\xb1\xbc\xb2\x9c\xd5\x0a\xfe\xe8\x8d\x1e\xc2\x46\x34\x32\x87\x42\x36\x75\x25\x0e\x20\x55\xa9\xcd\x4e\xf4\xcb\x53\x6a\x03\xf4\x2c\x9b\x6e\x9d\xc7\x4a\x7b\x89\x2f\xf6\x2a\x4a\x0d\x36\xba\xda\x63\xf7\x59\x4c\x3a\x75\x7f\x08\x3f\x94\xb7\x36\xe5\xc7\x64\xc9\x54\xb5\x37\x15\x57\x0f\x61\x2b\xf7\xa8\x82\xa2\xf8\x5a\x63\x4e\x58\x0c\xdf\xde\x1f\xb3\x7b\x78\x38\x5e\x88\x5e\x17\xce\x8f\x1e\x13\x71\xe9\x45\x73\x05\x91\x5c\x2e\xcd\x71\xd5\x32\xbb\x2c\x53\xce\xb0\x06\x0b\x6f\x26\xfe\x09\x9c\x31\x03\xef\x68\xf6\x73\x60\x8a\x9c\x9e\xde\x13\xb7\x37\xf6\x38\xa3\x5a\xa0\x55\x7f\x03\x99\xb2\x1c\xd6\x17\xa4\x0b\xce\xdf\xaf\x30\xa7\x20\x31\xaf\xb8\x20\xd1\x57\x1e\xcb\x87\x7e\x6f\xa8\xdd\x0f\x5e\xa5\xc3\x95\x70\xe5\xf7\xfa\x34\x7e\x60\xbb\x1b\xa0\x7b\x4b\x86\xd3\x65\x90\x5a\xd3\xab\xf1\xd4\x9b\x0e\x9b\xdf\x5b\x83\x88\x43\x3d\x42\xbc\x41\xd6\xae\x1e\x71\xe3\x50\xda\x1a\x99\x2c\x27\xfe\xb5\xff\xc3\xb8\xd7\xe1\x21\x95\x05\x2a\x92\xa5\xf4\x41\x9e\x93\xf5\x54\xdf\x4d\x73\x14\xb4\x5f\x29\x30\xb3\xde\x4b\xda\x9a\xea\x92\xab\x9d\x6c\x7a\x5a\xcf\xf7\xb9\x53\x72\xf3\x7f\x9c\x2f\x53\xdb\x8b\x9f\x33\xc3\xb1\xae\xdd\x20\xbb\xae\xe7\x3c\x73\x2c\xa5\xc3\x5c\x4a\xc9\x58\xeb\xf8\x0c\x67\xa7\xb5\x1e\x7c\x72\x37\x9c\x48\x38\xe2\xc9\xa7\x34\x56\xd6\x11\xab\x3e\x65\xcf\x10\x57\xe0\xe2\xa7\x19\x1a\x17\x4e\x4b\x59\xe1\xe9\xa9\x89\xf8\xfc\x69\xa2\x8d\x0b\x7b\x89\xec\x7f\x02\x8b\xf7\xc5\x7f\x01\x00\x00\xff\xff\x6f\x89\xde\x8f\xdd\x11\x00\x00"

func scriptsGet_nft_metadataCdcBytes() ([]byte, error) {
	return bindataRead(
		_scriptsGet_nft_metadataCdc,
		"scripts/get_nft_metadata.cdc",
	)
}

func scriptsGet_nft_metadataCdc() (*asset, error) {
	bytes, err := scriptsGet_nft_metadataCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "scripts/get_nft_metadata.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0xa3, 0x12, 0xe8, 0xdc, 0x76, 0x9c, 0x31, 0x36, 0xe1, 0x79, 0x78, 0xc6, 0xf1, 0xc6, 0xf1, 0x2a, 0x4b, 0x10, 0xa6, 0xab, 0x53, 0x6f, 0x7b, 0x42, 0xab, 0xd9, 0x9c, 0x7c, 0xd3, 0xc5, 0x54, 0xb1}}
	return a, nil
}

var _scriptsGet_total_supplyCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x4c\xcc\x31\x0a\x42\x31\x0c\x06\xe0\x3d\xa7\xf8\x79\x93\x2e\xe9\x22\x0e\xee\x0a\x2e\x2e\xea\x01\x6a\x7d\x0f\x0a\x6d\x1a\x62\x02\x8a\x78\x77\x47\xdd\x3f\xbe\xda\x75\x98\x63\xff\xcc\x5d\xdb\x7c\x3a\x5c\xb0\xd8\xe8\x98\x98\x13\x73\x2a\x43\xdc\x72\xf1\x47\xfa\x01\x2e\xf7\x32\x11\x69\xdc\xb0\x84\xa0\xe7\x2a\xab\xf5\x0e\xd7\xa3\xf8\x76\x83\x37\x01\x80\xcd\x1e\x26\x7f\x2b\xfb\xf0\xdc\xce\xa1\xda\x5e\xf4\xa1\x6f\x00\x00\x00\xff\xff\xab\xdd\xb2\x0f\x76\x00\x00\x00"

func scriptsGet_total_supplyCdcBytes() ([]byte, error) {
	return bindataRead(
		_scriptsGet_total_supplyCdc,
		"scripts/get_total_supply.cdc",
	)
}

func scriptsGet_total_supplyCdc() (*asset, error) {
	bytes, err := scriptsGet_total_supplyCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "scripts/get_total_supply.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0x81, 0x9, 0x60, 0xa2, 0xa5, 0x58, 0x7b, 0xb8, 0xa2, 0x87, 0x3a, 0x50, 0x8b, 0x97, 0x82, 0xd3, 0xf7, 0x78, 0xfa, 0x17, 0x8a, 0xda, 0xc8, 0x54, 0x76, 0x3b, 0xe3, 0x9c, 0x92, 0x0, 0x29, 0x87}}
	return a, nil
}

var _setup_accountCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x8c\x52\xcd\x6e\xda\x40\x10\xbe\xfb\x29\xbe\xe6\x10\x19\x89\xe0\x7b\x44\x23\x45\x51\x38\xa2\xa8\xe5\x05\x86\x65\x8c\x57\x59\x76\xad\xd9\x71\x28\x42\xbc\x7b\xb5\x36\xb5\x0d\xb5\xd4\xee\xc9\x9a\xfd\x7e\x67\x6d\x0f\x75\x10\xc5\x3a\xf8\x55\xe3\xf7\x76\xeb\x78\x13\x3e\xd9\xa3\x94\x70\xc0\xc3\x62\x51\x98\xe0\x55\xc8\x68\x2c\xee\x31\x0b\xb3\x33\x0f\xd9\x55\xe0\xfd\x17\x1d\x6a\xc7\xeb\xd5\x66\x8a\x3a\xdc\x76\xa4\xac\x28\xb0\xa9\x6c\x84\x0a\xf9\x48\x46\x6d\xf0\xb0\x11\xc7\x8a\x14\xe4\x41\xc6\x84\xc6\x2b\x8e\xa1\x71\x3b\x48\xe3\x13\x41\x03\x22\x2b\xac\x46\x76\x25\x9a\x3a\x0d\x84\x0d\xdb\x2f\xc6\x7a\xb5\x89\x59\x36\x56\x3b\x67\x19\x00\xd4\xc2\x35\x09\xe7\xd1\xee\x3d\xcb\x33\x5e\x1b\xad\x5e\x3b\xf5\x19\xce\x2d\x24\x9d\xa2\xc0\x0f\xd6\x46\x3c\x98\xc4\x9d\x60\x4b\x68\xc5\x7d\x0e\x72\xc2\xb4\x3b\xa1\xa2\x08\x82\x09\xce\x71\xeb\xd2\xf3\x6d\x89\xce\x61\xb1\x0d\x22\xe1\xb8\x7c\x1c\x55\x7e\xeb\xf1\x2f\x79\x5a\xce\x33\x26\x2f\x7f\x6a\x10\xda\xf3\x07\x69\x35\xc3\xb7\xef\xf0\xd6\x8d\x12\xa6\x23\x6d\xc4\x7e\x74\xc9\xc6\xf9\xdf\x84\x49\x19\x04\xcf\x47\xf0\xa1\xd6\xd3\x54\x50\xc7\x3a\x1a\x63\xf9\x34\xce\x62\x5a\x89\xf7\xc4\x1d\x62\xe5\xb3\x1b\x9b\x48\x5f\x0c\xab\x69\xf9\xa3\x0d\xf5\x88\xeb\x16\x12\x2a\x5f\x3e\x0d\x4e\x73\x68\xf8\x8f\xde\x37\x56\xe6\x4f\xa3\xba\xd9\x3a\x6b\x60\xa8\xa6\xad\x75\x56\x4f\x28\x83\xb4\xf6\x13\x0d\xaf\x09\x9c\xf5\x9f\xcb\xc7\xf3\x5f\x3f\xed\xe0\xfb\xd1\xaa\xce\xc7\xa1\x86\xcf\x7b\xd8\xe5\x25\xbf\x79\x8a\xc9\x26\x1d\x34\x15\x99\xdf\x80\x95\x64\xcf\xfa\xef\xfa\x3d\x69\x96\x75\xef\x7b\xc9\x7e\x07\x00\x00\xff\xff\x73\xab\x6a\xaa\xa0\x03\x00\x00"

func setup_accountCdcBytes() ([]byte, error) {
	return bindataRead(
		_setup_accountCdc,
		"setup_account.cdc",
	)
}

func setup_accountCdc() (*asset, error) {
	bytes, err := setup_accountCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "setup_account.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0xf3, 0xd4, 0x97, 0x91, 0xe4, 0x73, 0xc5, 0x59, 0x21, 0xf4, 0x4e, 0x1d, 0xff, 0xc3, 0x43, 0xef, 0x32, 0xd2, 0x85, 0x28, 0xe3, 0x57, 0x89, 0x3e, 0x83, 0x20, 0x7, 0x87, 0x51, 0x45, 0x7c, 0x74}}
	return a, nil
}

var _setup_account_from_nft_referenceCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x8c\x54\x4d\x6f\xe2\x3a\x14\xdd\xe7\x57\x9c\xb2\x78\x4a\x24\x1a\x36\x4f\x6f\x81\x68\xab\x8a\x57\xa4\x59\x0c\xaa\x46\xcc\xec\x2f\xce\x05\xac\x06\x3b\xb2\x6f\xc8\x54\x15\xff\x7d\x14\x1c\x12\x0c\x95\x3a\x59\x59\xc9\xf9\xb8\xc7\x3e\x8e\xde\x57\xd6\x09\x96\xd6\x2c\x6a\xb3\xd5\xeb\x92\x57\xf6\x8d\x0d\x36\xce\xee\x31\xca\xf3\x89\xb2\x46\x1c\x29\xf1\x93\x6b\x4c\xae\x0a\x35\x4a\x3a\x81\xef\x2c\x54\x90\xd0\x2f\xcd\x8d\xff\x8c\x1d\x01\x22\xea\xcb\x6f\xda\x57\x25\x2f\x17\xab\xcf\x78\xc3\xd7\x40\x4a\x26\x13\xac\x76\xda\x43\x1c\x19\x4f\x4a\xb4\x35\xd0\x1e\xcd\x8e\x04\x64\x40\x4a\xd9\xda\x08\x1a\x5b\x97\x05\x5c\x6d\x5a\x82\x58\x78\x16\x68\xf1\x5c\x6e\x50\x57\xed\x0b\xc7\x8a\xf5\x81\xb1\x5c\xac\x7c\x1e\x24\x37\xb5\x39\xe9\xb5\x94\xda\xb3\xc7\xe1\x94\x46\x2c\xde\x8c\x6d\xd0\xec\xd8\xf1\x59\xab\x15\xd9\x31\x94\x2d\x4b\xee\x49\xda\xc0\x8b\x75\xb4\x65\x90\x29\x5a\xa8\x72\x4c\xc2\x27\x28\xef\x2b\x79\xbf\x20\xe4\x49\x72\x91\x21\xa5\xa2\x70\xec\xfd\x14\xcf\x61\x31\x46\x55\xaf\x4b\xad\x5e\x49\x76\x53\xbc\xf6\xeb\x31\x74\x31\xc5\xcf\x6f\x46\xfe\xfb\x37\xc3\x47\x92\x00\x40\xe5\xb8\x22\xc7\xa9\xd7\x5b\xc3\x6e\x8a\xe7\x5a\x76\xcf\x61\x27\x5a\x0c\xba\xa7\x64\xb9\x18\x00\x0f\xd8\xb2\x74\xb0\xb3\x7f\xd6\x83\xdb\x27\xdf\xb2\xcc\xa9\xa2\xb5\x2e\xb5\xbc\xa7\xc3\x44\x57\xb0\xb5\x75\xce\x36\xb3\x7f\x3e\x6e\x4a\x32\xef\xed\x42\x84\x71\x5c\x95\xfc\x07\x7b\x5b\x1e\xd8\x0d\xb8\xe3\x63\x1a\xab\x3f\x3d\xa1\x22\xa3\x55\x3a\x9a\x9f\x0e\xd5\x58\x41\x30\x04\xc1\xf1\x86\x1d\x1b\x75\x3a\x98\xf8\x44\x46\x59\x12\x25\x77\x9d\x15\x1e\x2e\x4f\x21\x28\xb5\xc3\x9c\x47\x49\xdb\x0d\xd6\x45\x76\x17\xb1\xcd\x46\x86\x19\x5b\x38\x1e\x7a\xc5\xbc\x5b\xb4\xaf\xd3\xd5\x7b\xc5\xb3\x38\xe4\x72\xb1\x1a\xb8\xff\x93\xd0\x63\x9a\x65\x77\x20\x7f\x87\x2f\x80\x43\x82\xc9\x04\xf3\x50\x26\x82\xe1\xe6\xa6\x4e\x3e\x9a\xf6\xf4\x75\x90\xc2\xec\xfe\x36\x40\x1e\xca\xf9\x12\x43\xd3\x2c\xf2\xf4\x74\x60\x68\x39\xef\x6e\x77\xbd\x7a\x44\x28\x5c\xde\xa2\xd2\xd9\xfd\x95\xeb\x18\x62\xa7\x9f\xf8\x76\x77\x24\xf4\xe8\xd2\x4c\x9d\x03\x86\xa2\x41\xf5\xd5\xc3\xc6\xba\xeb\x0b\x77\x35\x43\xa9\xcd\xdb\xdf\x35\xf0\xe2\x9f\x32\x2c\xaf\x61\xc7\xc7\x34\x6a\xe1\x6d\x8c\xe1\x36\x8c\x23\xa4\x90\xdb\xb2\x7c\x11\xbc\x67\x84\xae\x1f\x93\x63\xf2\x27\x00\x00\xff\xff\x6f\x16\xda\xf9\x8c\x05\x00\x00"

func setup_account_from_nft_referenceCdcBytes() ([]byte, error) {
	return bindataRead(
		_setup_account_from_nft_referenceCdc,
		"setup_account_from_nft_reference.cdc",
	)
}

func setup_account_from_nft_referenceCdc() (*asset, error) {
	bytes, err := setup_account_from_nft_referenceCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "setup_account_from_nft_reference.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0xd, 0xa4, 0x89, 0xe6, 0x14, 0xc4, 0xfa, 0x86, 0xe4, 0x4b, 0x54, 0xfe, 0x7f, 0xb0, 0x9c, 0x89, 0x4b, 0xce, 0x3e, 0xb, 0x18, 0xbc, 0x7d, 0x92, 0x73, 0x86, 0x67, 0xab, 0x53, 0x4a, 0xaf, 0xe}}
	return a, nil
}

var _setup_account_to_receive_royaltyCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x74\x53\xd1\x6a\xe3\x3a\x10\x7d\xcf\x57\x4c\xf3\xd0\x26\x10\xec\xf7\xd2\x16\xda\x5e\x0a\x17\x6e\xb9\xa5\xed\x76\x5f\x33\x91\xc7\xf6\x10\x45\x32\xd2\x38\xa9\x09\xf9\xf7\x45\x72\xec\x58\xcb\x6e\x20\x0f\x46\x67\xce\x9c\x39\x73\x66\x96\xe7\xf0\x59\xb3\x07\x71\x68\x3c\x2a\x61\x6b\x80\x3d\x20\x08\xed\x1a\x8d\x42\x50\x5a\x17\x3e\x2f\xef\xa1\x46\x2c\x28\x47\xe1\x19\xc1\xd0\x01\x34\x9b\x2d\xb0\x01\xa9\x89\x1d\xa0\x52\xb6\x35\x12\x50\x1b\x82\xd6\x53\x11\x59\x1c\x29\xe2\x3d\x9b\x0a\x9c\xed\x50\x0b\x93\xff\x63\x7f\x85\x26\xa9\x43\xd3\x41\xd9\x9a\x8a\x37\x9a\x40\xec\x96\xcc\x0a\x0e\x35\xab\x3a\x28\xf5\x0d\x29\x2e\x99\x0a\xd8\x74\xa1\x3d\xac\xf7\xd8\x6a\x79\x43\xa9\xd7\x80\xae\x6a\x77\x64\x24\xb4\x09\xff\x7f\xcb\x08\x19\xf4\x1d\xd0\x88\x0f\x2a\x7b\x65\x74\xd1\x15\x66\x79\xf9\xef\xff\x9f\xab\x80\xef\x6e\xb4\x0e\x6a\x60\x9d\x7b\xb1\x0e\x2b\xca\x4b\x6d\x0f\x9f\x41\xc9\x57\x68\xb6\xbe\x70\x77\x91\x74\xca\xc9\x12\xc8\x7e\x7c\xfc\xf3\xbc\x3a\x03\x6c\xab\x8b\xc8\xf7\xc2\x28\x91\x25\x8b\x34\x1f\x3d\x79\x90\x1e\x08\xd1\x14\xe0\x2d\x58\x93\x41\x6f\x13\x41\x83\x52\x5f\x7c\x09\xa3\x34\xed\x46\xb3\x3a\xfb\xef\xcf\xdb\x88\x30\xa9\x51\xce\x2b\x81\xb2\x95\xd6\xd1\x2a\x20\xe8\xbb\x21\x25\x54\x4c\x24\x0e\xcd\x2a\x32\xe4\x58\xa5\x16\xab\xa8\x76\x13\x73\x70\x40\x57\xf4\x95\xd1\xc5\xa6\x71\xb6\x71\x1c\x52\x10\x3d\x9f\xcd\x78\xd7\x58\x27\xf0\x72\x5e\x56\x9c\x0d\x4a\x67\x77\x30\xcf\xb2\x3c\xcb\x72\x65\x8d\x38\x54\xe2\xf3\x04\x93\xa9\x42\xcd\x87\xea\x57\x12\x2c\x50\xf0\x8b\xe9\xe0\xff\x52\x9d\x60\xfa\xea\xd9\x24\x42\x8b\x31\x03\xb7\x30\x71\x75\x09\xc7\xd9\x0c\x00\xa0\x71\xd4\xa0\xa3\x85\xe7\xca\x90\xbb\x85\xc7\x56\xea\xc7\x3e\x14\x23\x26\xfc\xf2\x1c\xde\x49\x5a\x67\x80\xd0\xe9\x0e\x38\xcd\x4f\x61\xc9\x9b\x1b\x81\x1a\xf7\xe1\x10\xd2\xb1\xe3\x4a\x47\x26\x2e\xa1\x6f\x96\x6d\xac\x73\xf6\x70\x77\x9d\x1a\x10\xd1\x0f\x8b\x30\xed\x2d\x8c\xea\x97\x70\x7f\x0f\x86\x35\x1c\x47\xa2\x28\x1f\x0d\xab\xc5\xfc\xb1\x07\x8e\x59\xb8\x9c\x42\x7a\x2d\x7d\x1e\x82\x58\x30\x56\x80\xbe\xd9\xcb\x7c\x39\x32\x9e\x92\x79\x9f\x87\xb3\x3e\x27\x4b\x61\x83\x1b\xd6\x2c\xdd\xb0\xf7\x28\xb5\x8f\x97\x35\xba\x0b\x89\xb2\x9e\xfc\x94\x24\xc0\x0a\x6a\xac\x67\x09\x5a\xfa\xb3\x96\xda\xd9\xb6\xaa\xe3\xe3\x7b\x9f\x3c\x07\x6c\x84\x5c\x89\x8a\xc6\x72\x4d\x32\x6d\x7a\x3f\xf8\x16\x22\x7e\x77\x7d\x4c\x6d\x1b\x78\x56\xa9\xf9\xd9\x13\x6a\x34\x8a\x4e\x0f\x8b\xc4\xb8\x34\x36\x15\xc9\x7b\x3c\xf8\x6e\xa0\x79\x8b\x33\x07\xe7\x17\xcb\x55\x52\x29\xe8\x2a\x92\xc9\x6a\xc6\xd7\xe5\x55\xe2\xdf\x2b\x6e\x09\x7c\xeb\x28\xce\x39\x19\x84\x3d\xec\x51\x73\x31\x8d\xc4\xd5\xe5\x3d\x53\x35\xa9\xed\x62\x09\xc7\x61\xbd\x4f\x64\xa8\x64\xc5\xe8\xba\xdf\x78\xc2\x16\x23\xd7\xd5\x7c\x09\xa7\x59\xbf\xc4\xd3\xaf\x00\x00\x00\xff\xff\x63\x96\x23\x11\xcc\x05\x00\x00"

func setup_account_to_receive_royaltyCdcBytes() ([]byte, error) {
	return bindataRead(
		_setup_account_to_receive_royaltyCdc,
		"setup_account_to_receive_royalty.cdc",
	)
}

func setup_account_to_receive_royaltyCdc() (*asset, error) {
	bytes, err := setup_account_to_receive_royaltyCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "setup_account_to_receive_royalty.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0xe6, 0xcf, 0x3a, 0x94, 0x39, 0xf7, 0x25, 0xc0, 0x62, 0x50, 0xd4, 0x63, 0x34, 0x85, 0x25, 0xfa, 0x8c, 0x6c, 0x60, 0x74, 0xb2, 0x3d, 0xfb, 0x50, 0x4c, 0xa7, 0x22, 0xb9, 0x1b, 0x6a, 0x6f, 0x10}}
	return a, nil
}

var _transfer_nftCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\xa4\x93\xc1\x6e\x9b\x40\x10\x86\xef\x3c\xc5\xc8\x87\x16\x4b\x0d\x5c\xaa\x1e\x90\x93\xc8\x72\x1a\x29\x97\x28\x6a\xdd\x07\x58\x96\x01\xb6\xc5\x33\x68\x76\xa8\x5b\x45\x7e\xf7\x0a\x83\xc1\xc4\xc4\x97\x72\x42\x30\xff\xff\xcf\x7c\xbb\xe3\x76\x35\x8b\xc2\x33\xd3\x63\x43\x85\x4b\x2b\xdc\xf2\x2f\x24\xc8\x85\x77\xb0\x88\xa2\xd8\x32\xa9\x18\xab\x3e\x7e\x5b\x13\xd9\xcc\x2e\x82\xde\xe0\xeb\x1f\xb3\xab\x2b\x7c\x7e\xdc\xce\x49\xc7\xbf\x9d\x28\x88\x63\xd8\x96\xce\x83\x8a\x21\x6f\xac\x3a\x26\x70\x1e\x72\x96\xee\x53\x8e\x22\x8e\x0a\x30\x94\xc1\xc9\xb3\x15\x31\x21\x18\x6b\xb9\x21\x05\x65\x30\xc4\x5a\xa2\x04\xc1\x99\x4f\x28\x68\x5d\xed\x90\x34\x81\x75\x96\x09\x7a\xff\x09\xf6\x4e\xcb\x4c\xcc\xfe\xe9\x21\x81\x1f\x4f\xa4\x5f\x3e\x2f\xe1\x35\x08\x00\x00\x6a\xc1\xda\x08\x86\xde\x15\x84\x92\xc0\xba\xd1\x72\xdd\x45\xb4\x35\xd0\x3f\x71\x0c\x05\x2a\x68\x89\x30\x04\x78\xa8\x9b\xb4\x72\x76\x68\x89\xd3\x9f\x68\x75\xd0\x54\xa8\x63\x31\xdc\xb6\x06\xbd\xf3\xd8\xe4\x32\x38\x8f\x48\x59\x84\xf7\x60\x40\x30\x47\x41\xb2\xd8\x8e\xd9\x86\x76\xed\x7d\xf4\x47\x1c\x96\xab\x0a\x8f\xd3\x4e\xb2\xc6\xcf\xdf\x30\x87\xdb\x5e\x33\x94\xb4\x4f\xd4\x25\xac\x3e\x9c\x1d\xc9\x66\x90\xdd\x85\x2d\xe8\x04\x66\x7f\x7e\x57\x16\x53\xe0\x8b\xd1\x72\x39\xf1\xbc\xbf\x87\xda\x90\xb3\xe1\x62\xc3\x4d\x95\x01\xb1\x5e\x19\x84\xf7\xdd\x1c\x63\xb3\x8b\x77\x18\xf4\x70\x2f\x1c\x04\x2d\xba\xdf\x28\xfe\x3d\x0e\x19\xd6\xec\x9d\x76\x10\x06\xd2\x53\x0e\x05\xea\xc6\xd4\x26\x75\x95\xd3\xbf\xe1\xec\xc0\x2f\xc7\xfc\xcb\x79\x07\x86\xaf\x17\x2b\xf1\x56\x7c\xb8\x0b\xff\x87\xd5\x69\xd2\x6b\xb8\x4e\x57\xfb\x28\x18\xf6\x6f\x9e\xf4\x84\x12\xe5\x0a\xab\x9b\xe9\xa5\x89\x4e\x6e\xe1\xf9\xc6\x8c\xef\xd3\xe8\x87\x8e\xf3\x90\xec\x68\xba\x1f\xf3\xd9\xe3\xe9\x44\xfd\x6b\xa8\x2d\xbc\x04\x56\x37\x94\x6b\xc7\xeb\x10\x1c\xfe\x05\x00\x00\xff\xff\xe4\xc8\xf9\xb9\x9b\x04\x00\x00"

func transfer_nftCdcBytes() ([]byte, error) {
	return bindataRead(
		_transfer_nftCdc,
		"transfer_nft.cdc",
	)
}

func transfer_nftCdc() (*asset, error) {
	bytes, err := transfer_nftCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "transfer_nft.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0x83, 0xaa, 0xe1, 0x14, 0x3d, 0xe6, 0x1f, 0xed, 0xd7, 0x9b, 0xa1, 0x31, 0xc3, 0xc6, 0x3a, 0xac, 0x67, 0x61, 0xc5, 0xdc, 0x5a, 0xf7, 0x8c, 0x67, 0x8d, 0x26, 0xc0, 0x51, 0x22, 0x8c, 0xb1, 0xf4}}
	return a, nil
}

// Asset loads and returns the asset for the given name.
// It returns an error if the asset could not be found or
// could not be loaded.
func Asset(name string) ([]byte, error) {
	canonicalName := strings.Replace(name, "\\", "/", -1)
	if f, ok := _bindata[canonicalName]; ok {
		a, err := f()
		if err != nil {
			return nil, fmt.Errorf("Asset %s can't read by error: %v", name, err)
		}
		return a.bytes, nil
	}
	return nil, fmt.Errorf("Asset %s not found", name)
}

// AssetString returns the asset contents as a string (instead of a []byte).
func AssetString(name string) (string, error) {
	data, err := Asset(name)
	return string(data), err
}

// MustAsset is like Asset but panics when Asset would return an error.
// It simplifies safe initialization of global variables.
func MustAsset(name string) []byte {
	a, err := Asset(name)
	if err != nil {
		panic("asset: Asset(" + name + "): " + err.Error())
	}

	return a
}

// MustAssetString is like AssetString but panics when Asset would return an
// error. It simplifies safe initialization of global variables.
func MustAssetString(name string) string {
	return string(MustAsset(name))
}

// AssetInfo loads and returns the asset info for the given name.
// It returns an error if the asset could not be found or
// could not be loaded.
func AssetInfo(name string) (os.FileInfo, error) {
	canonicalName := strings.Replace(name, "\\", "/", -1)
	if f, ok := _bindata[canonicalName]; ok {
		a, err := f()
		if err != nil {
			return nil, fmt.Errorf("AssetInfo %s can't read by error: %v", name, err)
		}
		return a.info, nil
	}
	return nil, fmt.Errorf("AssetInfo %s not found", name)
}

// AssetDigest returns the digest of the file with the given name. It returns an
// error if the asset could not be found or the digest could not be loaded.
func AssetDigest(name string) ([sha256.Size]byte, error) {
	canonicalName := strings.Replace(name, "\\", "/", -1)
	if f, ok := _bindata[canonicalName]; ok {
		a, err := f()
		if err != nil {
			return [sha256.Size]byte{}, fmt.Errorf("AssetDigest %s can't read by error: %v", name, err)
		}
		return a.digest, nil
	}
	return [sha256.Size]byte{}, fmt.Errorf("AssetDigest %s not found", name)
}

// Digests returns a map of all known files and their checksums.
func Digests() (map[string][sha256.Size]byte, error) {
	mp := make(map[string][sha256.Size]byte, len(_bindata))
	for name := range _bindata {
		a, err := _bindata[name]()
		if err != nil {
			return nil, err
		}
		mp[name] = a.digest
	}
	return mp, nil
}

// AssetNames returns the names of the assets.
func AssetNames() []string {
	names := make([]string, 0, len(_bindata))
	for name := range _bindata {
		names = append(names, name)
	}
	return names
}

// _bindata is a table, holding each asset generator, mapped to its name.
var _bindata = map[string]func() (*asset, error){
	"destroy_nft.cdc":                      destroy_nftCdc,
	"mint_nft.cdc":                         mint_nftCdc,
	"scripts/borrow_nft.cdc":               scriptsBorrow_nftCdc,
	"scripts/get_collection_length.cdc":    scriptsGet_collection_lengthCdc,
	"scripts/get_nft_metadata.cdc":         scriptsGet_nft_metadataCdc,
	"scripts/get_total_supply.cdc":         scriptsGet_total_supplyCdc,
	"setup_account.cdc":                    setup_accountCdc,
	"setup_account_from_nft_reference.cdc": setup_account_from_nft_referenceCdc,
	"setup_account_to_receive_royalty.cdc": setup_account_to_receive_royaltyCdc,
	"transfer_nft.cdc":                     transfer_nftCdc,
}

// AssetDebug is true if the assets were built with the debug flag enabled.
const AssetDebug = false

// AssetDir returns the file names below a certain
// directory embedded in the file by go-bindata.
// For example if you run go-bindata on data/... and data contains the
// following hierarchy:
//     data/
//       foo.txt
//       img/
//         a.png
//         b.png
// then AssetDir("data") would return []string{"foo.txt", "img"},
// AssetDir("data/img") would return []string{"a.png", "b.png"},
// AssetDir("foo.txt") and AssetDir("notexist") would return an error, and
// AssetDir("") will return []string{"data"}.
func AssetDir(name string) ([]string, error) {
	node := _bintree
	if len(name) != 0 {
		canonicalName := strings.Replace(name, "\\", "/", -1)
		pathList := strings.Split(canonicalName, "/")
		for _, p := range pathList {
			node = node.Children[p]
			if node == nil {
				return nil, fmt.Errorf("Asset %s not found", name)
			}
		}
	}
	if node.Func != nil {
		return nil, fmt.Errorf("Asset %s not found", name)
	}
	rv := make([]string, 0, len(node.Children))
	for childName := range node.Children {
		rv = append(rv, childName)
	}
	return rv, nil
}

type bintree struct {
	Func     func() (*asset, error)
	Children map[string]*bintree
}

var _bintree = &bintree{nil, map[string]*bintree{
	"destroy_nft.cdc": {destroy_nftCdc, map[string]*bintree{}},
	"mint_nft.cdc": {mint_nftCdc, map[string]*bintree{}},
	"scripts": {nil, map[string]*bintree{
		"borrow_nft.cdc": {scriptsBorrow_nftCdc, map[string]*bintree{}},
		"get_collection_length.cdc": {scriptsGet_collection_lengthCdc, map[string]*bintree{}},
		"get_nft_metadata.cdc": {scriptsGet_nft_metadataCdc, map[string]*bintree{}},
		"get_total_supply.cdc": {scriptsGet_total_supplyCdc, map[string]*bintree{}},
	}},
	"setup_account.cdc": {setup_accountCdc, map[string]*bintree{}},
	"setup_account_from_nft_reference.cdc": {setup_account_from_nft_referenceCdc, map[string]*bintree{}},
	"setup_account_to_receive_royalty.cdc": {setup_account_to_receive_royaltyCdc, map[string]*bintree{}},
	"transfer_nft.cdc": {transfer_nftCdc, map[string]*bintree{}},
}}

// RestoreAsset restores an asset under the given directory.
func RestoreAsset(dir, name string) error {
	data, err := Asset(name)
	if err != nil {
		return err
	}
	info, err := AssetInfo(name)
	if err != nil {
		return err
	}
	err = os.MkdirAll(_filePath(dir, filepath.Dir(name)), os.FileMode(0755))
	if err != nil {
		return err
	}
	err = ioutil.WriteFile(_filePath(dir, name), data, info.Mode())
	if err != nil {
		return err
	}
	return os.Chtimes(_filePath(dir, name), info.ModTime(), info.ModTime())
}

// RestoreAssets restores an asset under the given directory recursively.
func RestoreAssets(dir, name string) error {
	children, err := AssetDir(name)
	// File
	if err != nil {
		return RestoreAsset(dir, name)
	}
	// Dir
	for _, child := range children {
		err = RestoreAssets(dir, filepath.Join(name, child))
		if err != nil {
			return err
		}
	}
	return nil
}

func _filePath(dir, name string) string {
	canonicalName := strings.Replace(name, "\\", "/", -1)
	return filepath.Join(append([]string{dir}, strings.Split(canonicalName, "/")...)...)
}
