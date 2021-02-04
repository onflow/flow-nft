.PHONY: test
test:
	$(MAKE) test -C contracts
	$(MAKE) test -C test

.PHONY: generate
generate:
	$(MAKE) generate -C contracts
	$(MAKE) generate -C templates

.PHONY: ci
ci:
	$(MAKE) ci -C contracts
	$(MAKE) ci -C templates
	$(MAKE) ci -C test