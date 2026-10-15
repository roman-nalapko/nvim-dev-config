.PHONY: test test-shell test-nvim test-languages

test: test-shell test-nvim test-languages

test-shell:
	bash tests/test_repo.sh

test-nvim:
	bash tests/test_nvim.sh

test-languages:
	bash tests/test_languages.sh
