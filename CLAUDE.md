# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Running Tests
```bash
# Full test suite (Cadence + Go)
make test

# CI verification (tidy checks + full tests)
make ci

# Cadence tests only
flow test --cover --covercode="contracts" tests/*.cdc

# Go tests only (all packages)
cd lib/go && make test

# Single Go package tests
cd lib/go/test && go test -v ./...
cd lib/go/contracts && go test ./...
cd lib/go/templates && go test ./...
```

### Code Generation
When Cadence contract files or transaction/script templates are modified, regenerate the embedded Go assets:
```bash
make generate              # From repo root
cd lib/go && make generate # From lib/go
```
This runs `go generate` in `lib/go/contracts` and `lib/go/templates`, which uses `go-bindata` to embed Cadence files into Go assets in `internal/assets/`.

### Go Module Maintenance
```bash
cd lib/go/contracts && go mod tidy
cd lib/go/templates && go mod tidy
cd lib/go/test && go mod tidy
```
Note: `lib/go/test/go.mod` pins `github.com/ethereum/go-ethereum` to v1.16.8→v1.17.0 due to a `trie/utils` package removal.

### Tests

All new tests should be written in Cadence unless an old Go test can be easily modified.

If any changes are made to any of the Cadence code, all the tests in `make test` should pass before finishing.

## Architecture

### Repository Structure
- **`contracts/`** — Cadence smart contracts (the NFT standard)
- **`transactions/`** — Cadence transaction and script templates for common operations
- **`tests/`** — Cadence test files (run via `flow test`)
- **`lib/go/`** — Three separate Go modules:
  - `contracts/` — Go package that embeds Cadence contract source code as assets
  - `templates/` — Go package that embeds transaction/script templates and provides code generation helpers
  - `test/` — Go integration tests using the flow-emulator; depends on both `contracts` and `templates`

### Contract Architecture
The NFT standard is defined in `contracts/NonFungibleToken.cdc` as a set of Cadence interfaces:
- `NFT` resource interface — base interface all NFTs must conform to
- `Collection` resource interface — holds multiple NFTs, provides withdraw/deposit/getIDs
- `Provider`, `Receiver`, `CollectionPublic` capability interfaces

Supporting standards:
- `ViewResolver.cdc` — Interface for metadata resolution
- `MetadataViews.cdc` — 16+ standardized metadata view types (Display, Serial, Royalties, NFTCollectionData, CrossVMNFT pointer, etc.)
- `CrossVMMetadataViews.cdc` — EVM cross-VM metadata support
- `ExampleNFT.cdc` — Full reference implementation showing correct usage

Utility contracts in `contracts/utility/`:
- `NFTForwarding.cdc` — Routes NFTs to another receiver/collection

### Go Package Relationships
The `lib/go/contracts` and `lib/go/templates` packages use `go:generate` directives to embed Cadence source files as Go byte slices. After any Cadence file change, `make generate` must be run before the Go tests will reflect the change. The `lib/go/test` package imports these and runs end-to-end tests against the flow-emulator.

### flow.json Contract Addresses
Contracts are deployed at different addresses per network:
| Contract | Emulator/Testing | Testnet | Mainnet |
|----------|-----------------|---------|---------|
| NonFungibleToken | `0xf8d6e0586b0a20c7` | `0x631e88ae7f1d7c20` | `0x1d7e57aa55817448` |
| MetadataViews | same | same | same |

The `flow.json` defines aliases mapping contract names to addresses for each network.

## Workflow Orchestration

### 1. Planning
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### 3. Self-Improvement Loop
- After ANY correction from the user: update 'tasks/lessons.md' with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes - don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fixing
- When fixing a big, point at logs, errors, failing tests -> then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management
1. **Plan First**: Write plan to 'tasks/todo.md' with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review to 'tasks/todo.md'
6. **Capture Lessons**: Update 'tasks/lessons.md' after corrections

## Core Principles
- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

