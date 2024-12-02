#!/usr/bin/make -f

.DEFAULT_GOAL := help

.ONESHELL:

# ENV VARS
export SHELL := $(shell which sh)
export UNAME := $(shell uname -s)
export ASDF_VERSION := v0.13.1

# check commands and OS
ifeq ($(UNAME), Darwin)
	export XCODE := $(shell xcode-select -p 2>/dev/null)
	export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK := 1
else ifeq ($(UNAME), Linux)
	include /etc/os-release
endif

# colors
GREEN := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE := $(shell tput -Txterm setaf 7)
CYAN := $(shell tput -Txterm setaf 6)
RESET := $(shell tput -Txterm sgr0)

# Usage: $(call check_bin,command_name)
define check_bin
	$(shell command -v $(1) 2>/dev/null)
endef

# Usage: $(call brew_install,package_name)
# For packages where binary name differs from package name, add a mapping in the case statement
define brew_install
	@if [ "${UNAME}" = "Darwin" ] || [ "${UNAME}" = "Linux" ]; then \
		binary_name=""; \
		case "$(1)" in \
			"go-task") binary_name="task" ;; \
			*) binary_name="$(1)" ;; \
		esac; \
		if [ -z "$(call check_bin,$$binary_name)" ]; then \
			echo "Installing $(1)..."; \
			brew install $(1); \
		else \
			echo "$(1) already installed."; \
		fi \
	else \
		echo "$(1) not supported."; \
	fi
endef

# targets
.PHONY: all
all: help asdf xcode brew jq pre-commit sccache task ## run all targets

xcode: ## install xcode command line tools
ifeq ($(UNAME), Darwin)
	@if [ -z "${XCODE}" ]; then \
		echo "Installing Xcode command line tools..."; \
		xcode-select --install; \
	else \
		echo "xcode already installed."; \
	fi
else
	@echo "xcode not supported."
endif

brew: xcode ## install homebrew
ifeq ($(UNAME), Darwin)
	@if [ -z "$(call check_bin,brew)" ]; then \
		echo "Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	else \
		echo "brew already installed."; \
	fi
else ifeq ($(UNAME), Linux)
	@if [ -z "$(call check_bin,brew)" ] && [ "${ID_LIKE}" = "debian" ]; then \
		echo "Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	else \
		echo "brew already installed."; \
	fi
else
	@echo "brew not supported."
endif

asdf: xcode ## install asdf
	@if [ -z "$(call check_bin,asdf)" ]; then \
		echo "Installing asdf..."; \
		git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_VERSION}; \
		echo "To use asdf, add the following to your shell rc (.bashrc/.zshrc):"; \
		echo "export PATH=\"$$HOME/.asdf/shims:$$PATH\""; \
		echo ". $$HOME/.asdf/asdf.sh"; \
		echo ". $$HOME/.asdf/completions/asdf.bash"; \
	else \
		echo "asdf already installed."; \
	fi

jq: brew ## install jq
	$(call brew_install,jq)

pre-commit: brew ## install pre-commit
	$(call brew_install,pre-commit)

sccache: brew ## install sccache
	$(call brew_install,sccache)

task: brew ## install taskfile
	$(call brew_install,go-task)

install: xcode asdf brew jq pre-commit sccache task ## install dependencies

help: ## show this help
	@echo ''
	@echo 'Usage:'
	@echo '    ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)
