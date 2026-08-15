WEBSCAF_REPO ?= https://github.com/kodaimura/webscaf.git
WEBSCAF_REF ?= main

.PHONY: grant check test update_webscaf

grant:
	chmod +x bin/* lib/*.sh sh/*.sh vendor/webscaf/bin/* vendor/webscaf/setup.sh

check:
	@find bin lib sh vendor/webscaf/bin -type f \( -name '*.sh' -o -path '*/bin/*' \) -exec bash -n {} \;
	bash -n vendor/webscaf/setup.sh
	$(MAKE) test

test:
	bash test/cli.sh

update_webscaf:
	git subtree pull --prefix vendor/webscaf $(WEBSCAF_REPO) $(WEBSCAF_REF) --squash
