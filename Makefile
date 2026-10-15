.PHONY: test test-shell test-nvim

test: test-shell test-nvim

test-shell:
	bash tests/test_repo.sh

test-nvim:
	bash tests/test_nvim.sh
