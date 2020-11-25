.PHONY: ci
ci:
	$(MAKE) -C lib/go/contracts ci
	$(MAKE) -C lib/go/test ci
