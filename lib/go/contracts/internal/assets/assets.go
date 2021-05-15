// Code generated by go-bindata. DO NOT EDIT.
// sources:
// ../../../contracts/ExampleNFT.cdc (3.905kB)
// ../../../contracts/NonFungibleToken.cdc (4.832kB)
// ../../../contracts/TokenForwarding.cdc (1.607kB)

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

var _examplenftCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x94\x57\x4d\x8f\xdb\x36\x13\xbe\xeb\x57\xcc\x9b\x43\x5e\x09\xcd\x5a\x69\x51\xf4\x60\xec\x76\x53\xec\xc6\x80\x0f\x35\x82\xc4\x45\x0f\x41\x80\xd0\xe2\xd8\x26\x56\x22\x05\x92\xb2\xa3\x2e\xfc\xdf\x8b\x21\xa9\x6f\x39\x9b\x1a\x8b\xb5\x2d\xce\x0c\x9f\x79\xe6\xd3\x69\x0a\xdb\xa3\x30\x20\x0c\x30\x09\xf8\x8d\x15\x65\x8e\x20\xe8\x7f\x81\xd2\x32\x2b\x94\x04\xb5\x07\x06\xab\x5c\x9d\x61\xa3\xe4\xcd\xaa\x92\x07\xb1\xcb\x11\xb6\xea\x09\x65\x94\xa6\xb0\xb6\xa4\x2f\x95\x85\x92\x69\x4b\xe2\xf6\x88\xa0\xf6\x7b\x91\x09\x96\x83\xb1\x4c\x72\xa6\x39\xec\x2a\x0b\xc2\x02\x33\xa6\x2a\x90\x83\x55\xb0\x43\xd2\x3f\xa1\xae\xc1\x88\x42\xe4\x4c\xd3\xd3\xa3\x3a\x43\xc1\x64\x0d\x9b\xd5\xd6\xc0\x59\x55\x39\xef\x20\x39\xdb\x99\xd2\x08\xfb\x4a\x66\x84\x8f\xe5\xc2\xd6\x8b\x28\x12\x45\xa9\xb4\x25\x8c\x0d\x44\x87\x10\xf6\x5a\x15\xf0\xf6\xdb\xdb\x5f\xa2\xa8\xac\x76\x90\x29\x69\x35\xcb\x2c\xbc\xf7\xde\x6e\x56\xdb\xe5\x54\xe9\x39\x8a\x00\x00\x48\xe1\xe4\x50\x59\x96\x7f\xaa\xca\x32\xaf\x97\xf0\xd7\x5a\xda\xdf\x7e\xed\x04\xf0\x44\xb8\x1e\x82\xdd\xb5\x14\x56\xb0\x5c\xfc\x83\x3c\x4e\x46\x32\x7f\x0b\x7b\xe4\x9a\x9d\x63\xc1\x1b\x33\x6f\x1c\xbe\x25\xfc\xc1\xb9\x46\x63\xee\xc7\x2a\x8f\x58\x2a\x23\xec\x40\xc3\xaa\xbe\x7c\xab\xa0\xd1\xa8\x4a\x67\x08\xb3\x2e\x2d\xd6\x9b\xd5\x16\x9e\x9d\x74\xa3\x91\xa3\x85\xce\x70\x34\x38\x23\xb7\x0b\xb4\x8c\x33\xcb\x96\xf0\xfc\xc9\x6a\x21\x0f\x4b\xf0\xef\x97\x4e\x56\x48\x42\x27\x85\x5d\x3f\x36\x86\x92\xde\x35\xf4\x32\x98\xef\x17\x82\xc3\x1d\x78\xb9\xe9\x61\x73\x11\xdc\xc1\xf3\xa5\x3d\xf6\x9f\x2e\x33\x1e\x3e\xa8\x3c\x47\x17\xfd\x19\x47\x3f\x68\x75\x12\x1c\xf5\x9b\xe9\xd1\x47\xcc\x50\x9c\x66\x8f\x3a\x93\x1f\xaa\x5d\x2e\xb2\x9e\x0f\x69\x0a\x5c\xf8\x5c\xd3\x35\xe5\x37\x31\x99\x29\xb9\x57\xba\x10\xf2\x00\x96\x0c\x98\xbe\x38\x09\x50\x4d\x75\x88\x6d\x5d\x22\x9c\x85\x3d\x52\xa1\x7d\xf5\x3c\x7d\x85\xf5\x23\xec\x05\xe6\x7c\xc2\xbc\x3a\x4b\xe4\x94\xff\x4b\x78\xf7\xec\xa5\x67\x3c\xdd\xac\xb6\xa3\x48\x40\x3c\x4b\x7e\x6b\x0e\x6e\x6f\x86\x0c\xf7\x51\x9f\x43\x7a\x82\xc6\x42\x9d\xd0\xf5\x04\xf2\xc4\x55\x90\xaf\xbb\x86\x23\x60\x92\x83\x17\x12\x96\x8a\xd6\x1d\xb3\x3c\x47\x3d\xf0\x65\x5f\xc9\xd6\x6c\xdc\x7c\xe8\x65\xca\x12\xde\xcd\x79\x35\xf2\x81\xf2\xd4\x91\x4c\xf0\x87\x0e\x2d\x3c\xd6\xf8\x09\xeb\x25\x74\x17\x24\x70\x7f\x0f\x25\x93\x22\x8b\x5f\x15\xc2\x18\x0a\xd3\x66\xb5\x7d\x95\x44\x03\xc3\x58\x88\x51\x55\xba\x6b\x16\x82\x37\x75\xd9\xde\xa6\xef\x17\xcc\xd7\xdc\xc8\x86\x46\x5b\x69\x42\xe6\x54\xaf\x50\xcb\x7d\x19\x83\x65\x4f\xc4\xab\xa3\x95\x28\x64\x9c\x0f\x18\x6c\x09\x36\xbd\x94\xeb\x1b\x6a\x95\x48\x7c\xfd\xd8\x28\x0a\x0e\x4c\x6b\x56\x4f\xc8\x0f\x17\xc7\x0e\xdc\x15\xb6\xc7\x29\x33\xa0\xdb\x7f\x60\xe6\x7f\xf0\xae\xeb\x98\xa4\x15\x4d\x74\xba\x56\x02\x77\x2d\x91\x43\x31\xf2\x80\x73\x07\x59\xe2\x39\x18\x0f\x3e\xf4\x6a\xec\x7c\x14\xd9\xb1\x4d\x43\x37\x4e\x72\x0e\x4a\xe2\xe4\x4e\x95\xf3\xed\x7c\x66\x7c\x16\xfc\x4b\xeb\xc0\x4c\xd8\xfb\x9d\x95\xe2\x4d\x5d\xf5\xe5\x68\x73\x34\x56\xab\xba\xbd\xf7\x4a\xbc\x0f\x68\xd7\x8f\x26\xe4\x86\x2b\x24\x17\x9e\x66\x38\xd2\x99\x3d\x32\x0b\x4c\x23\x08\x39\x8a\xfd\x24\x88\xde\x5a\x9c\x2c\xe1\xb3\xe7\xf7\xcb\x28\x62\x21\x07\x47\xa5\xf1\x84\xb5\xb9\x82\x6f\xa7\xb4\x56\x67\xca\xc2\x03\x5a\xdf\xa8\xf6\xa8\x51\x52\xa7\x52\x4d\xdd\x5f\x07\x96\xa6\x60\x94\xf7\xa0\x2b\x7c\xc8\x98\x04\x8d\x8c\x83\xb0\xa6\x9d\x1d\x2e\x63\x49\xa0\x79\x7a\x54\xdc\x4c\x3c\x6c\xf1\xf4\x06\x5d\xb2\x84\xd7\x3f\xd0\x1c\x82\xef\xaf\x67\xa2\xcf\xcc\xbc\x85\x39\x52\x42\x60\x27\xfd\xb3\x09\xf8\xd0\xfc\xfc\x8c\x4a\x53\x72\x88\x86\x47\xb3\x9c\x84\x28\xcb\x5a\x49\x74\xfc\x38\x26\xac\x82\x4c\x23\xb3\x08\xcc\x95\x01\x16\xa5\xad\xc7\x3c\x37\xd4\x78\xc9\xf7\x24\xd2\xcd\xa8\x78\xb6\x73\x76\xe7\x3d\x27\xda\xfe\xd4\xdc\xd9\xb7\x32\x42\xff\xb1\x1d\x57\x1e\x36\x30\x5e\x08\x09\x4a\x83\x51\x14\x3a\x6a\xa3\xcd\xa6\xe6\x17\x33\x75\x96\x61\x93\x6b\xca\x9b\x76\x43\xab\xa0\x10\xd2\x3a\xe7\x5a\xba\xd2\x74\x76\x55\xf9\x53\x48\x8b\xba\xd9\xb8\x82\x15\xd2\xa6\x50\xd3\xbb\x09\x2c\xd1\x77\x3f\x41\xdd\xd7\xde\x1e\x11\xfa\x62\xd3\x64\xe9\xcf\xa7\xae\xc6\x4c\x94\x02\xc9\x46\x6f\x76\x55\x6e\x1c\xd8\x23\x0a\xdd\x7f\xdc\x96\xc0\x24\x3b\x03\x9a\xb8\x35\xb7\x84\xd7\xcf\x2f\x6e\x10\x97\xa4\xef\x54\xc0\x39\x88\x7b\x3f\x15\xe9\x45\x93\x5f\xa2\x2b\xcb\x2e\x5c\xae\x28\xc2\x7e\xd5\xeb\xc0\xbd\x95\x34\x99\xdc\xf2\x1d\x26\xfe\x6f\x80\x65\x99\xaa\xa4\x1d\xf0\x30\x75\xde\xe7\x4e\xd0\x5a\x8c\xe6\xc8\xed\x8d\xc7\x39\xba\x7a\x1e\x1f\xdc\x5d\x3b\xf8\x29\x94\x7a\xfc\x73\x32\x5f\x51\x6e\xbb\x4c\x86\xbb\x58\xb7\x61\x3b\xcf\x9c\x3d\x30\xce\x60\x2b\xe6\xaa\x75\x08\xe1\xed\x20\xc1\x1e\x9a\x38\x3c\xf4\x13\x20\x64\x25\x25\x93\x61\x27\x0c\x93\xd9\x58\xa5\xd9\xa1\x63\x86\xe6\x4e\x2f\x6f\xbe\x53\x59\x2d\x94\x40\xf9\x82\xac\xc6\xb7\x37\x9d\xb6\x9f\x3b\x69\xb8\x22\xdd\xac\xb6\x9d\x91\x64\x80\xb8\xcd\x9c\xd0\x62\x32\x56\xb2\x9d\xa0\x1f\x3f\xb0\x57\xfa\x5a\xa7\x1e\xdc\x9e\x0b\xf9\x74\xfb\x23\x99\xfb\x7b\x3c\xcc\x28\x7f\xe5\x10\xdd\x9b\x81\x88\x65\xfa\x80\xf6\x9a\x27\xad\x68\x32\x1f\x84\xd0\x03\xfe\x4b\x00\x0a\xaf\x32\xa8\x13\x6f\xe6\x05\xee\xbd\xe2\x94\x77\xaf\xdc\x03\xe8\xb6\x84\xeb\x3f\xeb\x2e\xd1\x25\x8a\xfe\x0d\x00\x00\xff\xff\x3e\x0c\xbe\x7b\x41\x0f\x00\x00"

func examplenftCdcBytes() ([]byte, error) {
	return bindataRead(
		_examplenftCdc,
		"ExampleNFT.cdc",
	)
}

func examplenftCdc() (*asset, error) {
	bytes, err := examplenftCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "ExampleNFT.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0x97, 0x7c, 0xed, 0x9f, 0x13, 0x32, 0xaa, 0x13, 0xe8, 0xde, 0x8, 0x25, 0x53, 0xab, 0x3f, 0x58, 0xc9, 0xe1, 0xcc, 0xbf, 0xc3, 0x21, 0x35, 0xc4, 0x75, 0xae, 0x6c, 0x12, 0xb0, 0xcd, 0x68, 0xba}}
	return a, nil
}

var _nonfungibletokenCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\xcc\x57\x41\x8f\xdb\xba\x11\xbe\xeb\x57\xcc\xcb\x03\x9a\xdd\xc0\x6b\xf7\x50\xf4\x60\x20\x68\xda\xb7\x6f\x01\x5f\xb6\x0f\x5b\x17\x3d\x04\x01\x4c\x8b\x23\x9b\x08\x45\x2a\x24\x65\xc7\x0d\xf6\xbf\x17\x33\x24\x25\xca\xf6\x26\x9b\x5b\x73\x89\x57\x22\xbf\x99\xf9\xe6\x9b\x8f\xd4\xe2\xdd\xbb\xaa\xfa\xf5\x57\x58\xef\x11\x1e\xb4\x3d\xc2\xa3\x35\x77\x0f\xbd\xd9\xa9\xad\x46\x58\xdb\xcf\x68\xc0\x07\x61\xa4\x70\x92\x17\x6e\x1e\xad\xc9\xef\xf9\xf5\x06\x6a\x6b\x82\x13\x75\x00\x65\x02\xba\x46\xd4\x58\x55\x84\x37\xfc\x09\x61\x2f\x02\x08\xad\xc1\x58\x73\xd7\x64\xf4\xc0\xe8\x79\xb7\x87\xda\xf6\x5a\xd2\xdf\x8d\x75\x2d\x04\x3b\xaf\x56\x0d\x08\xe8\x3d\x3a\x38\x0a\x13\x3c\x04\x0b\x12\x3b\x6d\x4f\x20\xc0\xe0\x11\x4c\x13\x86\xfd\x33\x08\x7b\x54\x6e\xcc\xe6\xc8\x70\x06\x51\x56\xc1\x82\x6a\x3b\x8d\x2d\x9a\x40\xcb\xe0\xbc\x88\x31\xd7\x39\xe7\x7e\x89\xb3\x17\x07\xca\x18\x1a\xab\x89\x26\x2a\x86\x80\x5c\xaf\xd1\x83\x30\x12\x8c\x68\x95\xd9\x55\x5c\x6a\x98\x54\xef\x3b\xac\x55\xa3\xd0\xcf\x13\x83\x0f\xeb\x0d\x38\xf4\xb6\x77\x99\xaa\xda\x3a\x1c\x1e\x41\x38\x75\x89\x33\x87\x9d\x43\x8f\x54\xbb\x30\xf0\xf8\xb0\x06\x65\x18\xdd\xb7\xc2\x8d\xb5\x27\xe0\xdf\xac\xd6\x58\x07\x65\xcd\x06\x9e\x26\xf8\x23\x34\xa1\xfa\x60\x1d\x65\xcd\xd4\xbe\xf5\x8c\x5b\x0f\x7b\xe7\xd5\x8a\x5a\x59\xeb\x5e\xf2\xa2\x06\x8f\xd0\xf4\x86\xdf\x71\x0b\x04\x33\x40\x59\xd8\xa3\x41\x47\x8f\x50\x78\xa5\x4f\x55\x6b\x0f\xa9\xad\x9e\x12\x25\x5a\x6c\x1f\xc0\x36\xbc\xba\x0c\xc1\xf9\xfe\xe1\xec\x41\x49\x74\x1b\x5e\xb9\x79\xc2\x1a\xd5\x81\xfe\x1c\xd2\x1d\x48\xf4\x5c\x87\x2f\x9f\x80\xc4\x5a\x0b\x87\x45\x72\x47\x15\xf6\xe0\x6d\x8b\xd0\x39\x64\xd0\xce\x7a\xa6\x49\x2a\x5e\x51\x25\x56\xbf\xf4\xca\x21\x27\x35\x72\x56\x74\xb7\x46\x17\x84\x32\xa9\xa7\x0c\xb4\xc5\xbd\x38\x28\xeb\x86\x69\xf0\x51\x29\x27\xa0\x14\x3c\x76\xc2\x89\x80\xb0\xc5\x5a\xf4\x94\x66\x80\x9d\x3a\xa0\xe7\x18\xac\x60\xfa\x21\xb6\x4a\xab\x70\xa2\x48\x7e\x4f\xfb\x04\x38\x6c\xd0\xa1\xa9\x91\x44\x1a\x15\x5c\xa6\x44\xe9\x5a\xa3\x4f\x80\x5f\x3b\xeb\x13\x5e\xa3\x50\xcb\xa8\xba\xb1\x76\x65\xc0\x1a\x04\xeb\xa0\xb5\x0e\xab\xc4\xf9\x48\xd7\x1c\x56\x34\x83\xde\xa6\xc4\x28\x29\x7f\x9e\x55\x2b\x3e\x23\xd4\xbd\x0f\xb6\x1d\x9a\x90\x48\x9b\x0c\xd0\xb4\x11\x34\x96\x16\x0e\xc2\x29\xdb\x13\xa4\x32\xbb\xd4\x0b\x82\x8f\x7a\x98\x57\xd5\x3f\x4e\xd0\x7b\xe2\x73\x40\xe6\x12\x46\xa0\x59\x4a\xca\x36\x2c\xc9\xa9\xc6\x3d\xd4\xc2\x80\x47\x23\x2b\xda\xe5\xa2\x58\xb2\xda\x3a\x44\x77\x17\xec\x1d\xfd\x3f\xe3\xd8\x24\x3c\x6a\x99\xd9\x51\x7e\x1c\x84\xa7\x99\xd2\x12\x50\x23\xa1\x6a\xd0\x28\x77\xe8\xaa\x8b\x71\x5a\x5b\x0e\x95\xa7\x8e\x54\x6f\x6c\xd8\xa3\xe3\x14\x67\x83\x2d\xb1\x37\x78\xe2\xe6\xc4\xd0\xd2\x89\x38\x1a\x8f\x0f\xeb\xaa\x71\xb6\xbd\xe8\x29\xfb\x94\x81\x3a\x3b\x88\xc4\xce\x7a\x15\x86\x4e\x82\x35\x93\x58\x6f\x7d\x35\xd5\x68\x6d\xa9\x13\x21\xca\x37\x38\x61\x7c\x83\x6e\x5e\x55\xef\x16\x55\xb5\x58\xb0\x93\xb7\x24\xde\x38\xd5\xe7\xd6\x3c\x87\x7f\x32\x74\xf9\x96\x9a\xa5\x35\x6d\x56\x6d\x67\x5d\x88\x6d\x29\xfa\xad\x7c\xe1\xed\x8b\x45\xd5\xf5\xdb\x2b\xd0\x97\xae\xfa\xad\xaa\x00\x00\x52\x56\xc1\x06\xa1\xc1\xf4\xed\x16\x1d\x7b\x42\x6c\x1d\x2b\x55\xf9\xe8\x7a\xca\x00\x7e\x55\x3e\xf0\x44\xd0\x5e\x0a\x75\x10\x2e\x6e\xfe\x57\xdf\x75\xfa\xb4\x84\x7f\xaf\x4c\xf8\xeb\x5f\x06\xf0\xdf\x0f\x31\x4d\x11\x00\x5b\x15\x02\x4a\x38\x12\xc7\xa9\x0f\x45\xaa\x54\x87\x0a\x4a\x68\xf5\x5f\x94\x69\xfb\x10\x06\x19\xe6\xb7\xb4\x78\x35\x2e\xbc\xb9\xbd\x16\x4a\xf9\x69\x34\x91\x0e\x34\xe5\x07\x25\x98\x59\xde\xa7\x8c\x54\xb5\x08\xac\xc6\xc1\x38\x2f\x7c\x31\x01\x07\x38\x8a\x02\x04\x48\x47\xf3\x32\xdb\xc5\x02\x56\x17\x7b\x95\x07\x63\x43\xf4\x5d\x10\x75\x6d\x7b\x13\xde\x7a\x36\x7b\xb1\xc3\x19\x6c\x08\x66\xc3\xad\x86\x2d\xc2\xc6\x28\xbd\x99\x5f\xe7\xe0\x3f\x29\xf4\x8d\x92\x99\xec\x19\x67\xb1\x84\xbf\x4b\xe9\xd0\xfb\xbf\x5d\xa5\xe4\x25\x3e\x92\xc6\x51\xf2\x20\x4d\x0e\x82\xb3\xaa\x42\x66\x2a\x59\xdd\x6b\x88\x2a\xd1\x5f\x28\xe8\x3e\x2e\x99\xd4\x13\xec\xb5\x6a\x56\xd3\x4b\x4b\x92\x90\x1f\xce\xff\xf1\x7a\x72\x1e\xe9\xf2\xd0\x82\x15\xa9\xef\x1b\xaf\x28\xe6\xa0\x37\xea\x4b\x8f\xb0\xba\x4f\xa4\x89\x7a\xcf\x32\xdd\x0b\x3f\x2c\x25\x40\x8d\x01\xc6\x84\xf9\xd5\xf3\x90\xe7\x53\x3c\xc3\xda\x81\x7b\xf2\x93\x94\x1c\xa9\xec\x9a\x81\x52\x0d\x79\x3f\x5f\xa5\x1a\x65\xe2\x19\x94\x32\x27\x53\x42\x19\x1d\x8f\x30\x13\x1e\x3b\x3c\xd5\x72\x59\xeb\xe3\xc3\x7a\x79\x5e\xe6\x0f\x73\x2f\x38\xb6\xd0\xa2\x54\x74\x72\x66\xb9\x7b\xc8\xb6\x59\x98\xe6\x2b\xb8\xce\x97\x89\x29\xdf\x83\x27\x3b\xa4\xcb\xc9\x70\x8d\x1a\x62\x14\x9a\x22\xd7\x8b\x8b\x54\x80\x78\x1a\x47\x46\xdc\xa4\xb4\xa6\x37\x03\xec\x4d\xfe\xb1\xba\xcf\xb5\xde\x2e\xe1\xc3\x94\x0f\xde\x48\xf7\x90\xe9\x23\xfa\xe7\xd0\xf7\x3a\xcc\x95\x84\xf7\xef\xa1\xc4\x7a\x43\x42\x59\xdd\x67\xe5\x8f\x5e\x10\x67\xaa\xed\x7d\xa0\x21\xe6\xab\xa0\x68\x11\x44\x1c\x17\xba\xd9\xa0\xa7\x51\x58\xdd\xbf\x99\x44\x7b\xae\xa6\xbf\x7e\xd0\x8d\x34\x53\x3e\xf3\xf0\x53\xad\xc8\x17\xb9\xec\xff\x29\x50\x3e\xe9\x82\xf8\x3c\x36\x42\xf0\x2f\xe1\x76\x3d\x4b\x99\x7a\x20\xa4\x2c\x5b\x70\x16\xba\x08\x5f\x76\x24\x81\xdf\x30\x3f\xb1\x05\xb7\x2f\x17\xca\x03\x33\xb8\x64\x3a\xc6\x6b\xdb\xb6\x7c\xd7\xca\x1b\xba\x7e\xab\x95\xdf\x43\x63\xdd\xf0\x71\x31\xc9\xe5\x85\xfa\xc7\x8c\xff\x20\x84\xfa\x6c\x36\xbe\x9b\x6e\xb9\x68\x87\x61\x75\xef\x6f\x6e\x97\xf0\x31\x6a\xeb\xd3\xc5\x92\xad\x75\xce\x1e\x1f\x1f\xd6\x85\xb5\xdd\x2e\xe1\x4f\x79\x58\xaf\x1b\x46\x2a\x28\x0d\x80\xa9\x1d\x5d\x27\x26\x9f\x1f\x85\x4d\x6c\x31\xdf\xb4\x65\xfe\xfa\x18\xee\x06\xe4\x34\xd9\x5f\x5e\x14\xc6\x48\xc7\x72\x98\xd2\xd9\x20\x92\xd9\x35\xba\x4a\xd9\xdc\x2b\x7e\x27\x1c\xdf\x50\xf7\x56\xcb\xd1\x95\x53\x3e\x57\x24\x92\xef\x0d\x74\x80\x48\x5a\xbb\x84\x0f\xdf\x22\x3f\x4b\xda\xfb\x5c\xfd\x5f\xd8\xc4\xf7\x06\x24\xce\xc7\xe5\x40\x8c\xb9\x78\x90\x03\x39\x25\xd0\xb0\x29\x44\x17\x49\x1b\x95\x04\xe1\x9c\x38\xbd\x4e\x8d\x25\x60\x54\x22\x38\x0c\xbd\x33\x69\x62\x9d\x38\x65\x7b\xa2\x77\x71\xa6\x1c\xe6\x9e\xd4\xd7\x7b\xf2\x82\xae\xcb\x60\x4f\x39\x4a\x52\x37\xca\xf1\x2b\x29\xde\xc4\xcb\x2f\xe1\x2b\x71\x16\x0b\xf0\x76\x3c\xbf\x63\x73\xf8\xf3\xc1\xa1\x90\x20\x45\x10\x4c\x11\xdf\xc1\x5b\x0c\x7b\x2b\xd3\xa9\xa3\xc2\xcf\x4c\xd8\xb9\xc7\x3b\xbc\x62\xf1\x1e\x75\x33\x1f\x54\xf8\x51\xc9\x4f\xf0\xcb\x7b\x30\x4a\x2f\xe1\x0d\x61\x48\x8b\xf1\xe2\xc6\xf7\xde\xcb\xaa\x7e\x79\xad\x8f\xd7\x0e\x45\xc0\xdf\xdb\x2e\x9c\x8a\x0f\x86\xf8\x94\x5b\x86\xf4\xea\xd2\xc9\x21\x7e\x4e\x45\xce\xcf\x25\x5d\x12\x79\x62\x0a\xed\x91\xe9\xf7\x55\x49\xd2\xd5\xd8\xd4\xe0\x0f\x45\x2a\x85\x0b\x5e\x9e\x86\xe9\x24\xcc\xd2\x98\x6b\x34\xbb\xb0\xa7\x63\xf1\xcf\xe9\x34\x8c\x31\x64\x39\x8a\xf9\x18\xe4\xca\x0a\xa2\x32\x35\xcf\xd5\xff\x02\x00\x00\xff\xff\x33\x4d\x81\x27\xe0\x12\x00\x00"

func nonfungibletokenCdcBytes() ([]byte, error) {
	return bindataRead(
		_nonfungibletokenCdc,
		"NonFungibleToken.cdc",
	)
}

func nonfungibletokenCdc() (*asset, error) {
	bytes, err := nonfungibletokenCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "NonFungibleToken.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0xdb, 0x61, 0xca, 0x9d, 0xaa, 0x66, 0x36, 0xdf, 0xbc, 0x51, 0xdb, 0x7b, 0x51, 0xd8, 0x3d, 0x6f, 0x4e, 0x9c, 0x8e, 0x50, 0x28, 0x7c, 0x18, 0x1d, 0x2, 0xb2, 0xc2, 0x2b, 0x26, 0xa1, 0xfe, 0x2d}}
	return a, nil
}

var _tokenforwardingCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\xac\x54\x5d\x8b\xda\x40\x14\x7d\x9f\x5f\x71\x77\x0b\x25\x91\x1a\x97\x52\xfa\x10\xb4\xbb\x45\x1a\xd8\x17\x1f\xc4\x3e\x97\x31\x73\xa3\x43\xe3\x4c\xb8\xb9\x31\x2d\xe2\x7f\x2f\x93\x2f\x13\xcd\x82\x85\xcd\x53\x0c\x73\xce\x3d\xe7\xdc\xe3\xcc\x26\x13\x21\x3e\xc0\xca\x9a\x69\x54\x98\x9d\xde\xa6\x08\x1b\xfb\x1b\x0d\x44\x96\x4a\x49\x4a\x9b\x1d\x2c\xad\x61\x92\x31\x0b\x31\x99\x09\xa1\x0f\x99\x25\x76\x90\x16\x51\x03\x12\xb2\x07\x78\xfa\xf3\xf4\x59\x88\xac\xd8\x42\xdc\x80\x60\x15\x6d\x7a\x5c\x27\x21\x00\x00\x66\x33\xf8\x71\x44\xc3\xc0\x7b\xc9\xa0\x73\xc0\x83\x66\x46\x05\xe5\x1e\x8d\x83\xe4\x20\x09\x21\xa9\x81\xa8\x80\x2d\xf0\x1e\x81\x25\xed\x90\x81\x30\x46\x7d\x44\xaa\xb8\xdc\x34\xac\xc8\xa2\xf6\x78\xa5\xc8\xd3\x2a\x84\x9f\xaf\x86\xbf\x7e\xf9\x54\xa9\x0b\xe1\xbb\x52\x84\x79\xfe\xec\x8b\x0e\x49\x98\xdb\x82\x62\xec\xc0\x14\xde\x78\x0b\xd6\xcd\xbc\x56\x7e\x63\x41\x61\xa2\x0d\x3a\xcd\x84\x95\xbc\x55\xb4\x81\x52\xa7\x29\x6c\x87\xda\x3b\x90\x8c\x63\xcc\x73\x2f\xc7\x34\xf1\xe1\x28\xc9\x39\xd1\x99\x46\xc3\x21\x2c\x65\x26\xb7\x3a\xd5\xfc\x77\x30\x44\x1f\xb2\x14\x0f\xce\x9e\xc2\xcc\xe6\x9a\x21\x29\x4c\xcc\xda\x1a\x37\x02\x3a\x69\xda\x30\x52\x22\x63\xec\xc0\xce\x5e\x52\x98\x16\xe7\xb1\xf3\x12\xc2\xcb\x8d\xbd\x55\xb4\xf1\xe1\xd4\xe1\xdc\x93\xf6\x52\x5e\x63\x02\x0b\x70\x9a\x83\x4e\x6e\xb0\xb5\x44\xb6\x9c\x7f\x3c\xbd\x19\xd6\xf9\x9b\xe7\x3f\xdc\x90\x56\x22\x5e\x15\x2c\xea\xb7\x40\xab\xc1\x91\xde\xcc\xe0\x4a\xf7\x7c\x5a\x43\x7c\x31\x40\xb8\xe6\x8c\x6d\xbe\x19\xd4\xae\xbe\x92\x6f\x4b\x83\xf4\x1c\xc8\xba\x06\x7e\xc7\x73\x1e\x24\x1e\xef\xa5\xd9\xe1\xba\xb5\x0a\x32\x4d\x6d\x99\x57\x0b\x4e\x2e\x4d\x6e\xaa\xc8\xd6\x2d\xbb\xc8\x94\x64\x54\x37\xd1\x5f\x51\x79\xbf\xc0\x60\xb9\x1e\xdb\xf9\xf5\x02\x32\xc2\xab\x2f\xee\xe9\xa3\xef\x5c\x01\x3c\x2c\xc0\xe8\x34\x84\xc7\xa5\x2d\x52\x05\xc6\x32\xd4\xc8\x91\xee\xd4\xff\x62\xe7\xf4\xa2\xec\x71\xa0\xe2\x3c\xf8\x35\x2c\x05\x2c\x06\x02\xc7\xe2\xd5\x46\xb3\x37\x5a\xfa\xfb\x02\xf8\xdf\x02\xde\xe3\x9e\x30\x41\x42\xf3\x0e\xee\x69\xc4\x7a\x2f\x00\xd7\x2d\x42\xc9\xb8\xc2\xb2\xbb\x6e\x9a\x4f\x39\x48\x17\xde\xe5\x1a\xea\xc9\x2a\x35\xef\x2b\x59\x19\xd9\xa3\x76\x57\xca\x70\x50\xd7\xb6\x1b\xf2\x37\xa2\x0e\xe1\xe5\x32\xe7\x12\x32\x21\x17\x64\x60\x3e\xad\x89\x60\x94\xa6\x7b\xf5\x1b\x6b\x67\x21\xfe\x05\x00\x00\xff\xff\x5b\xb5\x9c\xaf\x47\x06\x00\x00"

func tokenforwardingCdcBytes() ([]byte, error) {
	return bindataRead(
		_tokenforwardingCdc,
		"TokenForwarding.cdc",
	)
}

func tokenforwardingCdc() (*asset, error) {
	bytes, err := tokenforwardingCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "TokenForwarding.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0x5e, 0xde, 0x65, 0x34, 0x31, 0xf, 0xbd, 0xef, 0x83, 0xf4, 0x58, 0x6a, 0x28, 0x98, 0x13, 0x25, 0xd7, 0xf9, 0xe6, 0x12, 0x19, 0x55, 0x51, 0xf0, 0xd, 0xe8, 0xc5, 0x32, 0x55, 0xd8, 0x7a, 0x50}}
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
	"ExampleNFT.cdc":       examplenftCdc,
	"NonFungibleToken.cdc": nonfungibletokenCdc,
	"TokenForwarding.cdc":  tokenforwardingCdc,
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
	"ExampleNFT.cdc": {examplenftCdc, map[string]*bintree{}},
	"NonFungibleToken.cdc": {nonfungibletokenCdc, map[string]*bintree{}},
	"TokenForwarding.cdc": {tokenforwardingCdc, map[string]*bintree{}},
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
