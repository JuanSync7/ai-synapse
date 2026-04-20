.PHONY: all init install agents list available clean zip

all:
	@echo "Usage: make <command> [args...]"
	@echo ""
	@echo "  make install              install all skills"
	@echo "  make install docs         install src/skills/docs only"
	@echo "  make install docs code    install src/skills/docs and src/skills/code"
	@echo "  make install meta/skill-creator  install one skill"
	@echo "  make list                 show installed skills"
	@echo "  make available            show all available skills"
	@echo "  make agents               install agent definitions"
	@echo "  make clean                remove all installed symlinks"
	@echo "  make zip                  package all skills as .zip for Claude Desktop"
	@echo "  make zip docs/patch-docs  package one skill (from src/skills/)"
	@echo "  make init                 configure git hooks + submodules (first-time)"

init:
	git config core.hooksPath .githooks
	git submodule update --init --recursive
	@echo "Git hooks configured. Submodules initialized."

# make install           → install everything
# make install docs      → install src/docs only
# make install docs code → install src/docs and src/code
_INSTALL_TARGETS := $(filter-out install, $(MAKECMDGOALS))
install:
	@if [ -z "$(_INSTALL_TARGETS)" ]; then \
		./scripts/install.sh install all; \
	else \
		./scripts/install.sh install $(addprefix src/skills/,$(_INSTALL_TARGETS)); \
	fi

agents:
	./scripts/install.sh agents

list:
	./scripts/install.sh list

available:
	./scripts/install.sh available

clean:
	./scripts/install.sh clean

# make zip                  → zip all skills
# make zip docs/patch-docs  → zip one skill
_ZIP_TARGETS := $(filter-out zip, $(MAKECMDGOALS))
zip:
	@if [ -z "$(_ZIP_TARGETS)" ]; then \
		./scripts/install.sh zip all; \
	else \
		./scripts/install.sh zip $(addprefix src/skills/,$(_ZIP_TARGETS)); \
	fi

# Prevent Make from erroring on unknown targets passed as install args (e.g. "docs", "code")
%:
	@:
