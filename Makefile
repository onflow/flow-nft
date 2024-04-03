.PHONY: test
test:
	$(MAKE) generate -C lib/go
	$(MAKE) test -C lib/go
	flow-c1 test --cover --covercode="contracts" tests/*.cdc

.PHONY: ci
ci:
	$(MAKE) ci -C lib/go
	flow-c1 test --cover --covercode="contracts" tests/*.cdc
