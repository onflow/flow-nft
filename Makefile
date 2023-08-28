.PHONY: test
test:
	$(MAKE) generate -C lib/go
	$(MAKE) test -C lib/go
	$(MAKE) test -C lib/js/test
	flow test --cover tests/test_example_nft.cdc

.PHONY: ci
ci:
	$(MAKE) ci -C lib/go
	$(MAKE) ci -C lib/js/test
	flow test --cover tests/test_example_nft.cdc
