.PHONY: test
test:
	go test ./...

.PHONY: generate
generate:
	go generate

.PHONY: check-generated
check-generated:
	git diff --exit-code

.PHONY: ci
ci: generate check-generated test