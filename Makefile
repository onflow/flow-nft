.PHONY: ci
ci:
	$(MAKE) -C test ci
	$(MAKE) -C contracts ci