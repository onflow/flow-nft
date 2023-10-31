.PHONY: test
test:
	$(MAKE) generate -C lib/go
	$(MAKE) test -C lib/go
	flow test --cover --covercode="contracts" tests/test_*.cdc

.PHONY: ci
ci:
	$(MAKE) ci -C lib/go
	flow test --cover --covercode="contracts" tests/test_*.cdc
