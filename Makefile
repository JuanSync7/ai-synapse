.PHONY: init

init:
	git config core.hooksPath .githooks
	git submodule update --init --recursive
	@echo "Git hooks configured. Submodules initialized."
