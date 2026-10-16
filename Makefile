.PHONY: test test-shell test-update test-nvim test-languages test-docs

test: test-shell test-update test-nvim test-languages test-docs

test-shell:
	bash tests/test_repo.sh

test-update:
	bash tests/test_update.sh

test-nvim:
	bash tests/test_nvim.sh

test-languages:
	bash tests/test_languages.sh

test-docs:
	bash tests/test_docs.sh
